package sokol_gfx

import "core:c"

/*
    Resource id typedefs:

    sg_buffer:      vertex- and index-buffers
    sg_image:       textures and render targets
    sg_shader:      vertex- and fragment-shaders, uniform blocks
    sg_pipeline:    associated shader and vertex-layouts, and render states
    sg_pass:        a bundle of render targets and actions on them
    sg_context:     a 'context handle' for switching between 3D-API contexts

    Instead of pointers, resource creation functions return a 32-bit
    number which uniquely identifies the resource object.

    The 32-bit resource id is split into a 16-bit pool index in the lower bits,
    and a 16-bit 'unique counter' in the upper bits. The index allows fast
    pool lookups, and combined with the unique-mask it allows to detect
    'dangling accesses' (trying to use an object which no longer exists, and
    its pool slot has been reused for a new object)

    The resource ids are wrapped into a struct so that the compiler
    can complain when the wrong resource type is used.
*/
Buffer   :: distinct u32;
Image    :: distinct u32;
Shader   :: distinct u32;
Pipeline :: distinct u32;
Pass     :: distinct u32;
Context  :: distinct u32;

/*
    various compile-time constants

    FIXME: it may make sense to convert some of those into defines so
    that the user code can override them.
*/
INVALID_ID              :: 0;
NUM_SHADER_STAGES       :: 2;
NUM_INFLIGHT_FRAMES     :: 2;
MAX_COLOR_ATTACHMENTS   :: 4;
MAX_SHADERSTAGE_BUFFERS :: 8;
MAX_SHADERSTAGE_IMAGES  :: 12;
MAX_SHADERSTAGE_UBS     :: 4;
MAX_UB_MEMBERS          :: 16;
MAX_VERTEX_ATTRIBUTES   :: 16;    /* NOTE: actual max vertex attrs can be less on GLES2, see sg_limits! */
MAX_MIPMAPS             :: 16;
MAX_TEXTUREARRAY_LAYERS :: 128;


/*
    sg_pass_action

    The sg_pass_action struct defines the actions to be performed
    at the start of a rendering pass in the functions sg_begin_pass()
    and sg_begin_default_pass().

    A separate action and clear values can be defined for each
    color attachment, and for the depth-stencil attachment.

    The default clear values are defined by the macros:

    - SG_DEFAULT_CLEAR_RED:     0.5f
    - SG_DEFAULT_CLEAR_GREEN:   0.5f
    - SG_DEFAULT_CLEAR_BLUE:    0.5f
    - SG_DEFAULT_CLEAR_ALPHA:   1.0f
    - SG_DEFAULT_CLEAR_DEPTH:   1.0f
    - SG_DEFAULT_CLEAR_STENCIL: 0
*/
Color_Attachment_Action :: struct {
    action: Action,
    val:    [4]f32,
}

Depth_Attachment_Action :: struct {
    action: Action,
    val:    f32,
}

Stencil_Attachment_Action :: struct {
    action: Action,
    val:    u8,
}

Pass_Action :: struct {
    _start_canary: u32,
    colors:        [MAX_COLOR_ATTACHMENTS]Color_Attachment_Action,
    depth:         Depth_Attachment_Action,
    stencil:       Stencil_Attachment_Action,
    _end_canary:   u32,
}

/*
    sg_bindings

    The sg_bindings structure defines the resource binding slots
    of the sokol_gfx render pipeline, used as argument to the
    sg_apply_bindings() function.

    A resource binding struct contains:

    - 1..N vertex buffers
    - 0..N vertex buffer offsets
    - 0..1 index buffers
    - 0..1 index buffer offsets
    - 0..N vertex shader stage images
    - 0..N fragment shader stage images

    The max number of vertex buffer and shader stage images
    are defined by the SG_MAX_SHADERSTAGE_BUFFERS and
    SG_MAX_SHADERSTAGE_IMAGES configuration constants.

    The optional buffer offsets can be used to group different chunks
    of vertex- and/or index-data into the same buffer objects.
*/
Bindings :: struct {
    _start_canary:         u32,
    vertex_buffers:        [MAX_SHADERSTAGE_BUFFERS] Buffer,
    vertex_buffer_offsets: [MAX_SHADERSTAGE_BUFFERS] c.int,
    index_buffer:          Buffer,
    index_buffer_offset:   c.int,
    vs_images:             [MAX_SHADERSTAGE_IMAGES] Image,
    fs_images:             [MAX_SHADERSTAGE_IMAGES] Image,
    _end_canary:           u32,
}

/*
    sg_buffer_desc

    Creation parameters for sg_buffer objects, used in the
    sg_make_buffer() call.

    The default configuration is:

    .size:      0       (this *must* be set to a valid size in bytes)
    .type:      SG_BUFFERTYPE_VERTEXBUFFER
    .usage:     SG_USAGE_IMMUTABLE
    .content    0
    .label      0       (optional string label for trace hooks)

    The dbg_label will be ignored by sokol_gfx.h, it is only useful
    when hooking into sg_make_buffer() or sg_init_buffer() via
    the sg_install_trace_hook

    ADVANCED TOPIC: Injecting native 3D-API buffers:

    The following struct members allow to inject your own GL, Metal
    or D3D11 buffers into sokol_gfx:

    .gl_buffers[SG_NUM_INFLIGHT_FRAMES]
    .mtl_buffers[SG_NUM_INFLIGHT_FRAMES]
    .d3d11_buffer

    You must still provide all other members except the .content member, and
    these must match the creation parameters of the native buffers you
    provide. For SG_USAGE_IMMUTABLE, only provide a single native 3D-API
    buffer, otherwise you need to provide SG_NUM_INFLIGHT_FRAMES buffers
    (only for GL and Metal, not D3D11). Providing multiple buffers for GL and
    Metal is necessary because sokol_gfx will rotate through them when
    calling sg_update_buffer() to prevent lock-stalls.

    Note that it is expected that immutable injected buffer have already been
    initialized with content, and the .content member must be 0!

    Also you need to call sg_reset_state_cache() after calling native 3D-API
    functions, and before calling any sokol_gfx function.
*/
Buffer_Desc :: struct {
    _start_canary: u32,
    size:          c.int,
    type:          Buffer_Type,
    usage:         Usage,
    content:       rawptr,
    label:         cstring,
    buffers:       [NUM_INFLIGHT_FRAMES] u32,     /* GL specific */
    mtl_buffers:   [NUM_INFLIGHT_FRAMES] rawptr,  /* Metal specific */
    d3d11_buffer:  rawptr,                        /* D3D11 specific */
    _end_canary:   u32,
}

/*
    sg_subimage_content

    Pointer to and size of a subimage-surface data, this is
    used to describe the initial content of immutable-usage images,
    or for updating a dynamic- or stream-usage images.

    For 3D- or array-textures, one sg_subimage_content item
    describes an entire mipmap level consisting of all array- or
    3D-slices of the mipmap level. It is only possible to update
    an entire mipmap level, not parts of it.
*/
Subimage_Content :: struct {
    ptr:  rawptr,    /* pointer to subimage data */
    size: c.int,     /* size in bytes of pointed-to subimage data */
}

/*
    sg_image_content

    Defines the content of an image through a 2D array
    of sg_subimage_content structs. The first array dimension
    is the cubemap face, and the second array dimension the
    mipmap level.
*/
Image_Content :: struct {
    subimage: [len(Cube_Face)][MAX_MIPMAPS] Subimage_Content,
}

/*
    sg_image_desc

    Creation parameters for sg_image objects, used in the
    sg_make_image() call.

    The default configuration is:

    .type:              SG_IMAGETYPE_2D
    .render_target:     false
    .width              0 (must be set to >0)
    .height             0 (must be set to >0)
    .depth/.layers:     1
    .num_mipmaps:       1
    .usage:             SG_USAGE_IMMUTABLE
    .pixel_format:      SG_PIXELFORMAT_RGBA8 for textures, backend-dependent
                        for render targets (RGBA8 or BGRA8)
    .sample_count:      1 (only used in render_targets)
    .min_filter:        SG_FILTER_NEAREST
    .mag_filter:        SG_FILTER_NEAREST
    .wrap_u:            SG_WRAP_REPEAT
    .wrap_v:            SG_WRAP_REPEAT
    .wrap_w:            SG_WRAP_REPEAT (only SG_IMAGETYPE_3D)
    .border_color       SG_BORDERCOLOR_OPAQUE_BLACK
    .max_anisotropy     1 (must be 1..16)
    .min_lod            0.0f
    .max_lod            FLT_MAX
    .content            an sg_image_content struct to define the initial content
    .label              0       (optional string label for trace hooks)

    SG_IMAGETYPE_ARRAY and SG_IMAGETYPE_3D are not supported on
    WebGL/GLES2, use sg_query_features().imagetype_array and
    sg_query_features().imagetype_3d at runtime to check
    if array- and 3D-textures are supported.

    Images with usage SG_USAGE_IMMUTABLE must be fully initialized by
    providing a valid .content member which points to
    initialization data.

    ADVANCED TOPIC: Injecting native 3D-API textures:

    The following struct members allow to inject your own GL, Metal
    or D3D11 textures into sokol_gfx:

    .gl_textures[SG_NUM_INFLIGHT_FRAMES]
    .mtl_textures[SG_NUM_INFLIGHT_FRAMES]
    .d3d11_texture

    The same rules apply as for injecting native buffers
    (see sg_buffer_desc documentation for more details).
*/
Image_Desc :: struct {
     _start_canary:         u32,
    type:                   Image_Type,
    render_target:          c.bool,
    width:                  c.int,
    height:                 c.int,
    using _: struct #raw_union {
        depth:  c.int,
        layers: c.int,
    },
    num_mipmaps:            c.int,
    usage:                  Usage,
    pixel_format:           Pixel_Format,
    sample_count:           c.int,
    min_filter, mag_filter: Filter,
    wrap_u, wrap_v, wrap_w: Wrap,
    border_color:           Border_Color,
    max_anisotropy:         u32,
    min_lod, max_lod:       f32,
    content:                Image_Content,
    label:                  rawptr,
    gl_textures:            [NUM_INFLIGHT_FRAMES] u32, /* GL specific */
    mtl_textures:           [NUM_INFLIGHT_FRAMES] rawptr, /* Metal specific */
    d3d11_texture:          rawptr, /* D3D11 specific */
    _end_canary:            u32,
}

/*
    sg_shader_desc

    The structure sg_shader_desc defines all creation parameters
    for shader programs, used as input to the sg_make_shader() function:

    - reflection information for vertex attributes (vertex shader inputs):
        - vertex attribute name (required for GLES2, optional for GLES3 and GL)
        - a semantic name and index (required for D3D11)
    - for each vertex- and fragment-shader-stage:
        - the shader source or bytecode
        - an optional entry function name
        - reflection info for each uniform block used by the shader stage:
            - the size of the uniform block in bytes
            - reflection info for each uniform block member (only required for GL backends):
                - member name
                - member type (SG_UNIFORMTYPE_xxx)
                - if the member is an array, the number of array items
        - reflection info for the texture images used by the shader stage:
            - the image type (SG_IMAGETYPE_xxx)
            - the name of the texture sampler (required for GLES2, optional everywhere else)

    For all GL backends, shader source-code must be provided. For D3D11 and Metal,
    either shader source-code or byte-code can be provided.

    For D3D11, if source code is provided, the d3dcompiler_47.dll will be loaded
    on demand. If this fails, shader creation will fail.
*/
Shader_Attr_Desc :: struct {
    name:      cstring,       /* GLSL vertex attribute name (only required for GLES2) */
    sem_name:  cstring,       /* HLSL semantic name */
    sem_index: c.int,         /* HLSL semantic index */
}

Shader_Uniform_Desc :: struct {
    name:        cstring,
    type:        Uniform_Type,
    array_count: c.int,
}

Shader_Uniform_Block_Desc :: struct {
    size:     c.int,
    uniforms: [MAX_UB_MEMBERS] Shader_Uniform_Desc,
}

Shader_Image_Desc :: struct {
    name: cstring,
    type: Image_Type,
}

Shader_Stage_Desc :: struct {
    source:         cstring,
    byte_code:      ^u8,
    byte_code_size: c.int,
    entry:          cstring,
    uniform_blocks: [MAX_SHADERSTAGE_UBS] Shader_Uniform_Block_Desc,
    images:         [MAX_SHADERSTAGE_IMAGES] Shader_Image_Desc,
}

Shader_Desc :: struct {
    _start_canary: u32,
    attrs:         [MAX_VERTEX_ATTRIBUTES] Shader_Attr_Desc,
    vs, fs:        Shader_Stage_Desc,
    label:         cstring,
    _end_canary:   u32,
}

/*
    sg_pipeline_desc

    The sg_pipeline_desc struct defines all creation parameters
    for an sg_pipeline object, used as argument to the
    sg_make_pipeline() function:

    - the vertex layout for all input vertex buffers
    - a shader object
    - the 3D primitive type (points, lines, triangles, ...)
    - the index type (none, 16- or 32-bit)
    - depth-stencil state
    - alpha-blending state
    - rasterizer state

    If the vertex data has no gaps between vertex components, you can omit
    the .layout.buffers[].stride and layout.attrs[].offset items (leave them
    default-initialized to 0), sokol will then compute the offsets and strides
    from the vertex component formats (.layout.attrs[].offset). Please note
    that ALL vertex attribute offsets must be 0 in order for the the
    automatic offset computation to kick in.

    The default configuration is as follows:

    .layout:
        .buffers[]:         vertex buffer layouts
            .stride:        0 (if no stride is given it will be computed)
            .step_func      SG_VERTEXSTEP_PER_VERTEX
            .step_rate      1
        .attrs[]:           vertex attribute declarations
            .buffer_index   0 the vertex buffer bind slot
            .offset         0 (offsets can be omitted if the vertex layout has no gaps)
            .format         SG_VERTEXFORMAT_INVALID (must be initialized!)
    .shader:            0 (must be intilized with a valid sg_shader id!)
    .primitive_type:    SG_PRIMITIVETYPE_TRIANGLES
    .index_type:        SG_INDEXTYPE_NONE
    .depth_stencil:
        .stencil_front, .stencil_back:
            .fail_op:               SG_STENCILOP_KEEP
            .depth_fail_op:         SG_STENCILOP_KEEP
            .pass_op:               SG_STENCILOP_KEEP
            .compare_func           SG_COMPAREFUNC_ALWAYS
        .depth_compare_func:    SG_COMPAREFUNC_ALWAYS
        .depth_write_enabled:   false
        .stencil_enabled:       false
        .stencil_read_mask:     0
        .stencil_write_mask:    0
        .stencil_ref:           0
    .blend:
        .enabled:               false
        .src_factor_rgb:        SG_BLENDFACTOR_ONE
        .dst_factor_rgb:        SG_BLENDFACTOR_ZERO
        .op_rgb:                SG_BLENDOP_ADD
        .src_factor_alpha:      SG_BLENDFACTOR_ONE
        .dst_factor_alpha:      SG_BLENDFACTOR_ZERO
        .op_alpha:              SG_BLENDOP_ADD
        .color_write_mask:      SG_COLORMASK_RGBA
        .color_attachment_count 1
        .color_format           SG_PIXELFORMAT_RGBA8
        .depth_format           SG_PIXELFORMAT_DEPTHSTENCIL
        .blend_color:           { 0.0f, 0.0f, 0.0f, 0.0f }
    .rasterizer:
        .alpha_to_coverage_enabled:     false
        .cull_mode:                     SG_CULLMODE_NONE
        .face_winding:                  SG_FACEWINDING_CW
        .sample_count:                  1
        .depth_bias:                    0.0f
        .depth_bias_slope_scale:        0.0f
        .depth_bias_clamp:              0.0f
    .label  0       (optional string label for trace hooks)
*/
Buffer_Layout_Desc :: struct {
    stride:    c.int,
    step_func: Vertex_Step,
    step_rate: c.int,
}

Vertex_Attr_Desc :: struct {
    buffer_index: c.int,
    offset:       c.int,
    format:       Vertex_Format,
}

Layout_Desc :: struct {
    buffers: [MAX_SHADERSTAGE_BUFFERS] Buffer_Layout_Desc,
    attrs:   [MAX_VERTEX_ATTRIBUTES] Vertex_Attr_Desc,
}

Stencil_State :: struct {
    fail_op, depth_fail_op, pass_op: Stencil_Op,
    compare_func:                    Compare_Func,
}

Depth_Stencil_State :: struct {
    stencil_front, stencil_back: Stencil_State,
    depth_compare_func:          Compare_Func,
    depth_write_enabled:         c.bool,
    stencil_enabled:             c.bool,
    stencil_read_mask:           u8,
    stencil_write_mask:          u8,
    stencil_ref:                 u8,
}

Blend_State :: struct {
    enabled:                            c.bool,
    src_factor_rgb, dst_factor_rgb:     Blend_Factor,
    op_rgb:                             Blend_Op,
    src_factor_alpha, dst_factor_alpha: Blend_Factor,
    op_alpha:                           Blend_Op,
    color_write_mask:                   u8,
    color_attachment_count:             c.int,
    color_format, depth_format:         Pixel_Format,
    blend_color:                        [4]f32,
}

Rasterizer_State :: struct {
    alpha_to_coverage_enabled: c.bool,
    cull_mode:                 Cull_Mode,
    face_winding:              Face_Winding,
    sample_count:              c.int,
    depth_bias:                f32,
    depth_bias_slope_scale:    f32,
    depth_bias_clamp:          f32,
}

Pipeline_Desc :: struct {
    _start_canary:  u32,
    layout:         Layout_Desc,
    shader:         Shader,
    primitive_type: Primitive_Type,
    index_type:     Index_Type,
    depth_stencil:  Depth_Stencil_State,
    blend:          Blend_State,
    rasterizer:     Rasterizer_State,
    label:          cstring,
    _end_canary:    u32,
}

/*
    sg_pass_desc

    Creation parameters for an sg_pass object, used as argument
    to the sg_make_pass() function.

    A pass object contains 1..4 color-attachments and none, or one,
    depth-stencil-attachment. Each attachment consists of
    an image, and two additional indices describing
    which subimage the pass will render: one mipmap index, and
    if the image is a cubemap, array-texture or 3D-texture, the
    face-index, array-layer or depth-slice.

    Pass images must fulfill the following requirements:

    All images must have:
    - been created as render target (sg_image_desc.render_target = true)
    - the same size
    - the same sample count

    In addition, all color-attachment images must have the same
    pixel format.
*/
Attachment_Desc :: struct {
    image:     Image,
    mip_level: c.int,
    using _: struct #raw_union {
        face:  c.int,
        layer: c.int,
        slice: c.int,
    },
}

Pass_Desc :: struct {
    _start_canary:            u32,
    color_attachments:        [MAX_COLOR_ATTACHMENTS] Attachment_Desc,
    depth_stencil_attachment: Attachment_Desc,
    label:                    cstring,
    _end_canary:              u32,
}

/*
    sg_trace_hooks

    Installable callback functions to keep track of the sokol_gfx calls,
    this is useful for debugging, or keeping track of resource creation
    and destruction.

    Trace hooks are installed with sg_install_trace_hooks(), this returns
    another sg_trace_hooks struct with the previous set of
    trace hook function pointers. These should be invoked by the
    new trace hooks to form a proper call chain.
*/
Trace_Hooks :: struct {
    user_data: rawptr,
    reset_state_cache:           #type proc "c" (user_data: rawptr),
    make_buffer:                 #type proc "c" (desc: ^Buffer_Desc, result: Buffer, user_data: rawptr),
    make_image:                  #type proc "c" (desc: ^Image_Desc, result: Image, user_data: rawptr),
    make_shader:                 #type proc "c" (desc: ^Shader_Desc, result: Shader, user_data: rawptr),
    make_pipeline:               #type proc "c" (desc: ^Pipeline_Desc, result: Pipeline, user_data: rawptr),
    make_pass:                   #type proc "c" (desc: ^Pass_Desc, result: Pass, user_data: rawptr),
    destroy_buffer:              #type proc "c" (buf: Buffer, user_data: rawptr),
    destroy_image:               #type proc "c" (img: Image, user_data: rawptr),
    destroy_shader:              #type proc "c" (shd: Shader, user_data: rawptr),
    destroy_pipeline:            #type proc "c" (pip: Pipeline, user_data: rawptr),
    destroy_pass:                #type proc "c" (pass: Pass, user_data: rawptr),
    update_buffer:               #type proc "c" (buf: Buffer, data_ptr: rawptr, data_size: c.int, user_data: rawptr),
    update_image:                #type proc "c" (img: Image, data: ^Image_Content, user_data: rawptr),
    append_buffer:               #type proc "c" (buf: Buffer, data_ptr: rawptr, data_size: c.int, result: c.int, user_data: rawptr),
    begin_default_pass:          #type proc "c" (pass_action: ^Pass_Action, width, height: c.int, user_data: rawptr),
    begin_pass:                  #type proc "c" (pass: Pass, pass_action: ^Pass_Action, user_data: rawptr),
    apply_viewport:              #type proc "c" (x, y, width, height: c.int, origin_top_left: c.bool, user_data: rawptr),
    apply_scissor_rect:          #type proc "c" (x, y, width, height: c.int, origin_top_left: c.bool, user_data: rawptr),
    apply_pipeline:              #type proc "c" (pip: Pipeline, user_data: rawptr),
    apply_bindings:              #type proc "c" (bindings: ^Bindings, user_data: rawptr),
    apply_uniforms:              #type proc "c" (stage: Shader_Stage, ub_index: c.int, data: rawptr, num_bytes: c.int, user_data: rawptr),
    draw:                        #type proc "c" (base_element: c.int, num_elements: c.int, num_instances: c.int, user_data: rawptr),
    end_pass:                    #type proc "c" (user_data: rawptr),
    commit:                      #type proc "c" (user_data: rawptr),
    alloc_buffer:                #type proc "c" (result: Buffer, user_data: rawptr),
    alloc_image:                 #type proc "c" (result: Image, user_data: rawptr),
    alloc_shader:                #type proc "c" (result: Shader, user_data: rawptr),
    alloc_pipeline:              #type proc "c" (result: Pipeline, user_data: rawptr),
    alloc_pass:                  #type proc "c" (result: Pass, user_data: rawptr),
    init_buffer:                 #type proc "c" (buf_id: Buffer, desc: ^Buffer_Desc, user_data: rawptr),
    init_image:                  #type proc "c" (img_id: Image, desc: ^Image_Desc, user_data: rawptr),
    init_shader:                 #type proc "c" (shd_id: Shader, desc: ^Shader_Desc, user_data: rawptr),
    init_pipeline:               #type proc "c" (pip_id: Pipeline, desc: ^Pipeline_Desc, user_data: rawptr),
    init_pass:                   #type proc "c" (pass_id: Pass, desc: ^Pass_Desc, user_data: rawptr),
    fail_buffer:                 #type proc "c" (buf_id: Buffer, user_data: rawptr),
    fail_image:                  #type proc "c" (img_id: Image, user_data: rawptr),
    fail_shader:                 #type proc "c" (shd_id: Shader, user_data: rawptr),
    fail_pipeline:               #type proc "c" (pip_id: Pipeline, user_data: rawptr),
    fail_pass:                   #type proc "c" (pass_id: Pass, user_data: rawptr),
    push_debug_group:            #type proc "c" (name: cstring, user_data: rawptr),
    pop_debug_group:             #type proc "c" (user_data: rawptr),
    err_buffer_pool_exhausted:   #type proc "c" (user_data: rawptr),
    err_image_pool_exhausted:    #type proc "c" (user_data: rawptr),
    err_shader_pool_exhausted:   #type proc "c" (user_data: rawptr),
    err_pipeline_pool_exhausted: #type proc "c" (user_data: rawptr),
    err_pass_pool_exhausted:     #type proc "c" (user_data: rawptr),
    err_context_mismatch:        #type proc "c" (user_data: rawptr),
    err_pass_invalid:            #type proc "c" (user_data: rawptr),
    err_draw_invalid:            #type proc "c" (user_data: rawptr),
    err_bindings_invalid:        #type proc "c" (user_data: rawptr),
}

/*
    sg_buffer_info
    sg_image_info
    sg_shader_info
    sg_pipeline_info
    sg_pass_info

    These structs contain various internal resource attributes which
    might be useful for debug-inspection. Please don't rely on the
    actual content of those structs too much, as they are quite closely
    tied to sokol_gfx.h internals and may change more frequently than
    the other public API elements.

    The *_info structs are used as the return values of the following functions:

    sg_query_buffer_info()
    sg_query_image_info()
    sg_query_shader_info()
    sg_query_pipeline_info()
    sg_query_pass_info()
*/
Slot_Info :: struct {
    state:  Resource_State,  /* the current state of this resource slot */
    res_id: u32,             /* type-neutral resource if (e.g. sg_buffer.id) */
    ctx_id: u32,             /* the context this resource belongs to */
}

Buffer_Info :: struct {
    slot:               Slot_Info,  /* resource pool slot info */
    update_frame_index: u32,        /* frame index of last sg_update_buffer() */
    append_frame_index: u32,        /* frame index of last sg_append_buffer() */
    append_pos:         c.int,      /* current position in buffer for sg_append_buffer() */
    append_overflow:    c.bool,     /* is buffer in overflow state (due to sg_append_buffer) */
    num_slots:          c.int,      /* number of renaming-slots for dynamically updated buffers */
    active_slot:        c.int,      /* currently active write-slot for dynamically updated buffers */
}

Image_Info :: struct {
    slot:            Slot_Info,   /* resource pool slot info */
    upd_frame_index: u32,         /* frame index of last sg_update_image() */
    num_slots:       c.int,       /* number of renaming-slots for dynamically updated images */
    active_slot:     c.int,       /* currently active write-slot for dynamically updated images */
}

Shader_Info :: struct {
    slot: Slot_Info,              /* resoure pool slot info */
}

Pipeline_Info :: struct {
    slot: Slot_Info,              /* resource pool slot info */
}

Pass_Info :: struct {
    slot: Slot_Info,              /* resource pool slot info */
}

/*
    sg_desc

    The sg_desc struct contains configuration values for sokol_gfx,
    it is used as parameter to the sg_setup() call.

    The default configuration is:

    .buffer_pool_size:      128
    .image_pool_size:       128
    .shader_pool_size:      32
    .pipeline_pool_size:    64
    .pass_pool_size:        16
    .context_pool_size:     16

    GL specific:
    .gl_force_gles2
        if this is true the GL backend will act in "GLES2 fallback mode" even
        when compiled with SOKOL_GLES3, this is useful to fall back
        to traditional WebGL if a browser doesn't support a WebGL2 context

    Metal specific:
        (NOTE: All Objective-C object references are transferred through
        a bridged (const void*) to sokol_gfx, which will use a unretained
        bridged cast (__bridged id<xxx>) to retrieve the Objective-C
        references back. Since the bridge cast is unretained, the caller
        must hold a strong reference to the Objective-C object for the
        duration of the sokol_gfx call!

    .mtl_device
        a pointer to the MTLDevice object
    .mtl_renderpass_descriptor_cb
        a C callback function to obtain the MTLRenderPassDescriptor for the
        current frame when rendering to the default framebuffer, will be called
        in sg_begin_default_pass()
    .mtl_drawable_cb
        a C callback function to obtain a MTLDrawable for the current
        frame when rendering to the default framebuffer, will be called in
        sg_end_pass() of the default pass
    .mtl_global_uniform_buffer_size
        the size of the global uniform buffer in bytes, this must be big
        enough to hold all uniform block updates for a single frame,
        the default value is 4 MByte (4 * 1024 * 1024)
    .mtl_sampler_cache_size
        the number of slots in the sampler cache, the Metal backend
        will share texture samplers with the same state in this
        cache, the default value is 64

    D3D11 specific:
    .d3d11_device
        a pointer to the ID3D11Device object, this must have been created
        before sg_setup() is called
    .d3d11_device_context
        a pointer to the ID3D11DeviceContext object
    .d3d11_render_target_view_cb
        a C callback function to obtain a pointer to the current
        ID3D11RenderTargetView object of the default framebuffer,
        this function will be called in sg_begin_pass() when rendering
        to the default framebuffer
    .d3d11_depth_stencil_view_cb
        a C callback function to obtain a pointer to the current
        ID3D11DepthStencilView object of the default framebuffer,
        this function will be called in sg_begin_pass() when rendering
        to the default framebuffer
*/
Desc :: struct {
    _start_canary:                  u32,
    buffer_pool_size:               c.int,
    image_pool_size:                c.int,
    shader_pool_size:               c.int,
    pipeline_pool_size:             c.int,
    pass_pool_size:                 c.int,
    context_pool_size:              c.int,
    /* GL specific */
    gl_force_gles2:                 c.bool,
    /* Metal-specific */
    mtl_device:                     rawptr,
    mtl_renderpass_descriptor_cb:   #type proc "c" () -> rawptr,
    mtl_drawable_cb:                #type proc "c" () -> rawptr,
    mtl_global_uniform_buffer_size: c.int,
    mtl_sampler_cache_size:         c.int,
    /* D3D11-specific */
    d3d11_device:                   rawptr,
    d3d11_device_context:           rawptr,
    d3d11_render_target_view_cb:    #type proc "c" () -> rawptr,
    d3d11_depth_stencil_view_cb:    #type proc "c" () -> rawptr,
    _end_canary:                    u32,
}

/*
    Runtime information about a pixel format, returned
    by sg_query_pixelformat().
*/
Pixel_Format_Info :: struct {
    sample: bool,          /* pixel format can be sampled in shaders */
    filter: bool,          /* pixel format can be sampled with filtering */
    render: bool,          /* pixel format can be used as render target */
    blend:  bool,          /* alpha-blending is supported */
    msaa:   bool,          /* pixel format can be used as MSAA render target */
    depth:  bool,          /* pixel format is a depth format */
}

/*
    Runtime information about available optional features,
    returned by sg_query_features()
*/
Features :: struct {
    instancing:              bool,
    origin_top_left:         bool,
    multiple_render_targets: bool,
    msaa_render_targets:     bool,
    imagetype_3d:            bool,  /* creation of SG_IMAGETYPE_3D images is supported */
    imagetype_array:         bool,  /* creation of SG_IMAGETYPE_ARRAY images is supported */
    image_clamp_to_border:   bool,  /* border color and clamp-to-border UV-wrap mode is supported */
}

/*
    Runtime information about resource limits, returned by sg_query_limit()
*/
Limits :: struct {
    max_image_size_2d:      u32,       /* max width/height of SG_IMAGETYPE_2D images */
    max_image_size_cube:    u32,       /* max width/height of SG_IMAGETYPE_CUBE images */
    max_image_size_3d:      u32,       /* max width/height/depth of SG_IMAGETYPE_3D images */
    max_image_size_array:   u32,
    max_image_array_layers: u32,
    max_vertex_attrs:       u32,       /* <= SG_MAX_VERTEX_ATTRIBUTES (only on some GLES2 impls) */
}
