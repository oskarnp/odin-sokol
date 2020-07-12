package sokol_gfx

import "core:os"

RENDERER :: #config(RENDERER, "metal");

when os.OS=="darwin" && RENDERER=="metal"    do foreign import sokol_lib "../sokol_impl_darwin_metal.dylib"
when os.OS=="darwin" && RENDERER=="glcore33" do foreign import sokol_lib "../sokol_impl_darwin_glcore33.dylib"

import "core:c"


// wrapper procs to get rid of pointer parameter.
setup                        :: proc (desc: Desc)                                     { desc := desc;                      _setup(&desc);                                    } 
install_trace_hooks          :: proc (trace_hooks: Trace_Hooks) -> Trace_Hooks        { trace_hooks := trace_hooks; return _install_trace_hooks(&trace_hooks);               } 
make_buffer                  :: proc (desc: Buffer_Desc) -> Buffer                    { desc := desc;               return _make_buffer(&desc);                              }
make_image                   :: proc (desc: Image_Desc) -> Image                      { desc := desc;               return _make_image(&desc);                               }

make_shader :: proc (desc: Shader_Desc) -> Shader {
    desc := desc;
    return _make_shader(&desc);
}

make_pipeline                :: proc (desc: Pipeline_Desc) -> Pipeline                { desc := desc;               return _make_pipeline(&desc);                            }
make_pass                    :: proc (desc: Pass_Desc) -> Pass                        { desc := desc;               return _make_pass(&desc);                                }
update_image                 :: proc (img: Image, data: Image_Content)                { data := data;                      _update_image(img, &data);                        }
begin_default_pass           :: proc (pass_action: Pass_Action, width, height: c.int) { pass_action := pass_action;        _begin_default_pass(&pass_action, width, height); }
begin_pass                   :: proc (pass: Pass, pass_action: Pass_Action)           { pass_action := pass_action;        _begin_pass(pass, &pass_action);                  }
apply_bindings               :: proc (bindings: Bindings)                             { bindings := bindings;              _apply_bindings(&bindings);                       }
query_pixelformat            :: proc (fmt: Pixel_Format) -> Pixel_Format_Info         { fmt := fmt;                 return _query_pixelformat(&fmt);                         }
query_buffer_defaults        :: proc (desc: Buffer_Desc) -> Buffer_Desc               { desc := desc;               return _query_buffer_defaults(&desc);                    }
query_image_defaults         :: proc (desc: Image_Desc) -> Image_Desc                 { desc := desc;               return _query_image_defaults(&desc);                     }
query_shader_defaults        :: proc (desc: Shader_Desc) -> Shader_Desc               { desc := desc;               return _query_shader_defaults(&desc);                    }
query_pipeline_defaults      :: proc (desc: Pipeline_Desc) -> Pipeline_Desc           { desc := desc;               return _query_pipeline_defaults(&desc);                  }
query_pass_defaults          :: proc (desc: Pass_Desc) -> Pass_Desc                   { desc := desc;               return _query_pass_defaults(&desc);                      }
init_buffer                  :: proc (buf_id: Buffer, desc: Buffer_Desc)              { desc := desc;                      _init_buffer(buf_id, &desc);	                     }
init_image                   :: proc (img_id: Image, desc: Image_Desc)                { desc := desc;                      _init_image(img_id, &desc);	                     }
init_shader                  :: proc (shd_id: Shader, desc: Shader_Desc)              { desc := desc;                      _init_shader(shd_id, &desc);	                     }
init_pipeline                :: proc (pip_id: Pipeline, desc: Pipeline_Desc)          { desc := desc;                      _init_pipeline(pip_id, &desc);                    }
init_pass                    :: proc (pass_id: Pass, desc: Pass_Desc)                 { desc := desc;                      _init_pass(pass_id, &desc);                       }

@(private, link_prefix="sg", default_calling_convention="c")
foreign sokol_lib {
	_setup                   :: proc (desc: ^Desc)                                                          ---;
	_install_trace_hooks     :: proc (trace_hooks: ^Trace_Hooks)                       -> Trace_Hooks       ---;
	_make_buffer             :: proc (desc: ^Buffer_Desc)                              -> Buffer            ---;
	_make_image              :: proc (desc: ^Image_Desc)                               -> Image             ---;
	_make_shader             :: proc (desc: ^Shader_Desc)                              -> Shader            ---;
	_make_pipeline           :: proc (desc: ^Pipeline_Desc)                            -> Pipeline          ---;
	_make_pass               :: proc (desc: ^Pass_Desc)                                -> Pass              ---;
	_update_image            :: proc (img: Image, data: ^Image_Content)                                     ---;
	_begin_default_pass      :: proc (pass_action: ^Pass_Action, width, height: c.int)                      ---;
	_begin_pass              :: proc (pass: Pass, pass_action: ^Pass_Action)                                ---;
	_apply_bindings          :: proc (bindings: ^Bindings)                                                  ---;
	_query_pixelformat       :: proc (fmt: ^Pixel_Format)                              -> Pixel_Format_Info ---;
	_query_buffer_defaults   :: proc (desc: ^Buffer_Desc)                              -> Buffer_Desc       ---;
	_query_image_defaults    :: proc (desc: ^Image_Desc)                               -> Image_Desc        ---;
	_query_shader_defaults   :: proc (desc: ^Shader_Desc)                              -> Shader_Desc       ---;
	_query_pipeline_defaults :: proc (desc: ^Pipeline_Desc)                            -> Pipeline_Desc     ---;
	_query_pass_defaults     :: proc (desc: ^Pass_Desc)                                -> Pass_Desc         ---;
	_init_buffer             :: proc (buf_id: Buffer, desc: ^Buffer_Desc)                                   ---;
	_init_image              :: proc (img_id: Image, desc: ^Image_Desc)                                     ---;
	_init_shader             :: proc (shd_id: Shader, desc: ^Shader_Desc)                                   ---;
	_init_pipeline           :: proc (pip_id: Pipeline, desc: ^Pipeline_Desc)                               ---;
	_init_pass               :: proc (pass_id: Pass, desc: ^Pass_Desc)                                      ---;
}

@(link_prefix="sg_", default_calling_convention="c")
foreign sokol_lib {
	shutdown                 :: proc ()                                                                     ---;
	isvalid                  :: proc ()                                                -> bool              ---;
	reset_state_cache        :: proc ()                                                                     ---;
	push_debug_group         :: proc (name: cstring)                                                        ---;
	pop_debug_group          :: proc ()                                                                     ---;
	destroy_buffer           :: proc (buf: Buffer)                                                          ---;
	destroy_image            :: proc (img: Image)                                                           ---;
	destroy_shader           :: proc (shd: Shader)                                                          ---;
	destroy_pipeline         :: proc (pip: Pipeline)                                                        ---;
	destroy_pass             :: proc (pass: Pass)                                                           ---;
	update_buffer            :: proc (buf: Buffer, data_ptr: rawptr, data_size: c.int)                      ---;
	append_buffer            :: proc (buf: Buffer, data_ptr: rawptr, data_size: c.int) -> c.int             ---;
	query_buffer_overflow    :: proc (buf: Buffer)                                     -> c.bool            ---;
	apply_viewport           :: proc (x, y, width, height: c.int, origin_top_left: c.bool)                  ---;
	apply_scissor_rect       :: proc (x, y, width, height: c.int, origin_top_left: c.bool)                  ---;
	apply_pipeline           :: proc (pip: Pipeline)                                                        ---;
	apply_uniforms           :: proc (stage: Shader_Stage, ub_index: c.int, data: rawptr, num_bytes: c.int) ---;
	draw                     :: proc (base_element, num_elements, num_instances: c.int)                     ---;
	end_pass                 :: proc ()                                                                     ---;
	commit                   :: proc ()                                                                     ---;
	query_desc               :: proc ()                                                -> Desc              ---;
	query_backend            :: proc ()                                                -> Backend           ---;
	query_features           :: proc ()                                                -> Features          ---;
	query_limits             :: proc ()                                                -> Limits            ---;
	query_buffer_state       :: proc (buf: Buffer)                                     -> Resource_State    ---;
	query_image_state        :: proc (img: Image)                                      -> Resource_State    ---;
	query_shader_state       :: proc (shd: Shader)                                     -> Resource_State    ---;
	query_pipeline_state     :: proc (pip: Pipeline)                                   -> Resource_State    ---;
	query_pass_state         :: proc (pass: Pass)                                      -> Resource_State    ---;
	query_buffer_info        :: proc (buf: Buffer)                                     -> Buffer_Info       ---;
	query_image_info         :: proc (img: Image)                                      -> Image_Info        ---;
	query_shader_info        :: proc (shd: Shader)                                     -> Shader_Info       ---;
	query_pipeline_info      :: proc (pip: Pipeline)                                   -> Pipeline_Info     ---;
	query_pass_info          :: proc (pass: Pass)                                      -> Pass_Info         ---;
	alloc_buffer             :: proc ()                                                -> Buffer            ---;
	alloc_image              :: proc ()                                                -> Image             ---;
	alloc_shader             :: proc ()                                                -> Shader            ---;
	alloc_pipeline           :: proc ()                                                -> Pipeline          ---;
	alloc_pass               :: proc ()                                                -> Pass              ---;
	fail_buffer              :: proc (buf_id: Buffer)                                                       ---;
	fail_image               :: proc (img_id: Image)                                                        ---;
	fail_shader              :: proc (shd_id: Shader)                                                       ---;
	fail_pipeline            :: proc (pip_id: Pipeline)                                                     ---;
	fail_pass                :: proc (pass_id: Pass)                                                        ---;
	setup_context            :: proc ()                                                -> Context           ---;
	activate_context         :: proc (ctx_id: Context)                                                      ---;
	discard_context          :: proc (ctx_id: Context)                                                      ---;
}
