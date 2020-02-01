package sokol_app

import "core:os"

when os.OS=="darwin" && RENDERER=="metal"    do foreign import sokol_lib "../sokol_impl_darwin_metal.dylib"
when os.OS=="darwin" && RENDERER=="glcore33" do foreign import sokol_lib "../sokol_impl_darwin_glcore33.dylib"

import "core:c"
import "core:strings"

////////////////////////////////////////////////////////////////////////////////
// sokol_app

MAX_TOUCHPOINTS  :: 8;
MAX_MOUSEBUTTONS :: 3;
MAX_KEYCODES     :: 512;

Event_Type :: enum u32 {
    INVALID,
    KEY_DOWN,
    KEY_UP,
    CHAR,
    MOUSE_DOWN,
    MOUSE_UP,
    MOUSE_SCROLL,
    MOUSE_MOVE,
    MOUSE_ENTER,
    MOUSE_LEAVE,
    TOUCHES_BEGAN,
    TOUCHES_MOVED,
    TOUCHES_ENDED,
    TOUCHES_CANCELLED,
    RESIZED,
    ICONIFIED,
    RESTORED,
    SUSPENDED,
    RESUMED,
    UPDATE_CURSOR,
    QUIT_REQUESTED,
    CLIPBOARD_PASTED,
};

/* key codes are the same names and values as GLFW */
Key_Code :: enum u32 {
    INVALID          = 0,
    SPACE            = 32,
    APOSTROPHE       = 39,  /* ' */
    COMMA            = 44,  /* , */
    MINUS            = 45,  /* - */
    PERIOD           = 46,  /* . */
    SLASH            = 47,  /* / */
    NUM_0            = 48,
    NUM_1            = 49,
    NUM_2            = 50,
    NUM_3            = 51,
    NUM_4            = 52,
    NUM_5            = 53,
    NUM_6            = 54,
    NUM_7            = 55,
    NUM_8            = 56,
    NUM_9            = 57,
    SEMICOLON        = 59,  /* ; */
    EQUAL            = 61,  /* = */
    A                = 65,
    B                = 66,
    C                = 67,
    D                = 68,
    E                = 69,
    F                = 70,
    G                = 71,
    H                = 72,
    I                = 73,
    J                = 74,
    K                = 75,
    L                = 76,
    M                = 77,
    N                = 78,
    O                = 79,
    P                = 80,
    Q                = 81,
    R                = 82,
    S                = 83,
    T                = 84,
    U                = 85,
    V                = 86,
    W                = 87,
    X                = 88,
    Y                = 89,
    Z                = 90,
    LEFT_BRACKET     = 91,  /* [ */
    BACKSLASH        = 92,  /* \ */
    RIGHT_BRACKET    = 93,  /* ] */
    GRAVE_ACCENT     = 96,  /* ` */
    WORLD_1          = 161, /* non-US #1 */
    WORLD_2          = 162, /* non-US #2 */
    ESCAPE           = 256,
    ENTER            = 257,
    TAB              = 258,
    BACKSPACE        = 259,
    INSERT           = 260,
    DELETE           = 261,
    RIGHT            = 262,
    LEFT             = 263,
    DOWN             = 264,
    UP               = 265,
    PAGE_UP          = 266,
    PAGE_DOWN        = 267,
    HOME             = 268,
    END              = 269,
    CAPS_LOCK        = 280,
    SCROLL_LOCK      = 281,
    NUM_LOCK         = 282,
    PRINT_SCREEN     = 283,
    PAUSE            = 284,
    F1               = 290,
    F2               = 291,
    F3               = 292,
    F4               = 293,
    F5               = 294,
    F6               = 295,
    F7               = 296,
    F8               = 297,
    F9               = 298,
    F10              = 299,
    F11              = 300,
    F12              = 301,
    F13              = 302,
    F14              = 303,
    F15              = 304,
    F16              = 305,
    F17              = 306,
    F18              = 307,
    F19              = 308,
    F20              = 309,
    F21              = 310,
    F22              = 311,
    F23              = 312,
    F24              = 313,
    F25              = 314,
    KP_0             = 320,
    KP_1             = 321,
    KP_2             = 322,
    KP_3             = 323,
    KP_4             = 324,
    KP_5             = 325,
    KP_6             = 326,
    KP_7             = 327,
    KP_8             = 328,
    KP_9             = 329,
    KP_DECIMAL       = 330,
    KP_DIVIDE        = 331,
    KP_MULTIPLY      = 332,
    KP_SUBTRACT      = 333,
    KP_ADD           = 334,
    KP_ENTER         = 335,
    KP_EQUAL         = 336,
    LEFT_SHIFT       = 340,
    LEFT_CONTROL     = 341,
    LEFT_ALT         = 342,
    LEFT_SUPER       = 343,
    RIGHT_SHIFT      = 344,
    RIGHT_CONTROL    = 345,
    RIGHT_ALT        = 346,
    RIGHT_SUPER      = 347,
    MENU             = 348,
};

Touch_Point :: struct {
    identifier: uintptr,
    pos_x:      f32,
    pos_y:      f32,
    changed:    bool,
};

Mouse_Button :: enum i32 {
    INVALID = -1,
    LEFT = 0,
    RIGHT = 1,
    MIDDLE = 2,
};

MODIFIER_SHIFT :: (1 << 0);
MODIFIER_CTRL  :: (1 << 1);
MODIFIER_ALT   :: (1 << 2);
MODIFIER_SUPER :: (1 << 3);

Event :: struct {
    frame_count:        u64,
    type:               Event_Type,
    key_code:           Key_Code,
    char_code:          u32,
    key_repeat:         bool,
    modifiers:          u32,
    mouse_button:       Mouse_Button,
    mouse_x:            f32,
    mouse_y:            f32,
    scroll_x:           f32,
    scroll_y:           f32,
    num_touches:        i32,
    touches:            [MAX_TOUCHPOINTS]Touch_Point,
    window_width:       i32,
    window_height:      i32,
    framebuffer_width:  i32,
    framebuffer_height: i32,
};

Desc :: struct {
	init_cb:    #type proc(),
	frame_cb:   #type proc(),
	cleanup_cb: #type proc(),
	event_cb:   #type proc(evt: Event),
	fail_cb:    #type proc(str: string),

    width: int,                          /* the preferred width of the window / canvas */
    height: int,                         /* the preferred height of the window / canvas */
    sample_count: int,                   /* MSAA sample count */
    swap_interval: int,                  /* the preferred swap interval (ignored on some platforms) */
    high_dpi: bool,                      /* whether the rendering canvas is full-resolution on HighDPI displays */
    fullscreen: bool,                    /* whether the window should be created in fullscreen mode */
    alpha: bool,                         /* whether the framebuffer should have an alpha channel (ignored on some platforms) */
    window_title: string,                /* the window title as UTF-8 encoded string */
    user_cursor: bool,                   /* if true, user is expected to manage cursor image in SAPP_EVENTTYPE_UPDATE_CURSOR */
    enable_clipboard: bool,              /* enable clipboard access, default is false */
    clipboard_size: int,                 /* max size of clipboard content in bytes */
 
    // TODO: html5_canvas_name: cstring,            /* the name (id) of the HTML5 canvas element, default is "canvas" */
    // TODO: html5_canvas_resize: c.bool,           /* if true, the HTML5 canvas size is set to sapp_desc.width/height, otherwise canvas size is tracked */
    // TODO: html5_preserve_drawing_buffer: c.bool, /* HTML5 only: whether to preserve default framebuffer content between frames */
    // TODO: html5_premultiplied_alpha: c.bool,     /* HTML5 only: whether the rendered pixels use premultiplied alpha convention */
    // TODO: html5_ask_leave_site: c.bool,          /* initial state of the internal html5_ask_leave_site flag (see sapp_html5_ask_leave_site()) */
    // TODO: ios_keyboard_resizes_canvas: c.bool,   /* if true, showing the iOS keyboard shrinks the canvas */
    // TODO: gl_force_gles2: c.bool,                /* if true, setup GLES2/WebGL even if GLES3/WebGL2 is available */
};

@private Internal_Desc :: struct {
	init_cb: #type proc "c" (),
	frame_cb: #type proc "c" (),
	cleanup_cb: #type proc "c" (),
	event_cb: #type proc "c" (evt: ^Event),
	fail_cb: #type proc "c" (str: cstring),

	user_data: rawptr,
    init_userdata_cb: #type proc "c" (user_data: rawptr),
    frame_userdata_cb: #type proc "c" (user_data: rawptr),
    cleanup_userdata_cb: #type proc "c" (user_data: rawptr),
    event_userdata_cb: #type proc "c" (evt: ^Event, user_data: rawptr),
    fail_userdata_cb: #type proc "c" (str: cstring, user_data: rawptr),

    width: c.int,                          /* the preferred width of the window / canvas */
    height: c.int,                         /* the preferred height of the window / canvas */
    sample_count: c.int,                   /* MSAA sample count */
    swap_interval: c.int,                  /* the preferred swap interval (ignored on some platforms) */
    high_dpi: c.bool,                      /* whether the rendering canvas is full-resolution on HighDPI displays */
    fullscreen: c.bool,                    /* whether the window should be created in fullscreen mode */
    alpha: c.bool,                         /* whether the framebuffer should have an alpha channel (ignored on some platforms) */
    window_title: cstring,                 /* the window title as UTF-8 encoded string */
    user_cursor: c.bool,                   /* if true, user is expected to manage cursor image in SAPP_EVENTTYPE_UPDATE_CURSOR */
    enable_clipboard: c.bool,              /* enable clipboard access, default is false */
    clipboard_size: c.int,                 /* max size of clipboard content in bytes */

    html5_canvas_name: cstring,            /* the name (id) of the HTML5 canvas element, default is "canvas" */
    html5_canvas_resize: c.bool,           /* if true, the HTML5 canvas size is set to sapp_desc.width/height, otherwise canvas size is tracked */
    html5_preserve_drawing_buffer: c.bool, /* HTML5 only: whether to preserve default framebuffer content between frames */
    html5_premultiplied_alpha: c.bool,     /* HTML5 only: whether the rendered pixels use premultiplied alpha convention */
    html5_ask_leave_site: c.bool,          /* initial state of the internal html5_ask_leave_site flag (see sapp_html5_ask_leave_site()) */
    ios_keyboard_resizes_canvas: c.bool,   /* if true, showing the iOS keyboard shrinks the canvas */
    gl_force_gles2: c.bool,                /* if true, setup GLES2/WebGL even if GLES3/WebGL2 is available */
};

@(link_prefix="sapp_", default_calling_convention="c")
foreign sokol_lib {
	isvalid                               :: proc()                         -> c.bool            --- ; /* returns true after sokol-app has been initialized */
	width                                 :: proc()                         -> c.int             --- ; /* returns the current framebuffer width in pixels */
	height                                :: proc()                         -> c.int             --- ; /* returns the current framebuffer height in pixels */
	high_dpi                              :: proc()                         -> c.bool            --- ; /* returns true when high_dpi was requested and actually running in a high-dpi scenario */
	dpi_scale                             :: proc()                         -> c.float           --- ; /* returns the dpi scaling factor (window pixels to framebuffer pixels) */
	show_keyboard                         :: proc(visible: c.bool)                               --- ; /* show or hide the mobile device onscreen keyboard */
	keyboard_shown                        :: proc()                         -> c.bool            --- ; /* return true if the mobile device onscreen keyboard is currently shown */
	show_mouse                            :: proc(visible: c.bool)                               --- ; /* show or hide the mouse cursor */
	mouse_shown                           :: proc()                         -> c.bool            --- ; /* show or hide the mouse cursor */
	userdata                              :: proc()                         -> rawptr            --- ; /* return the userdata pointer optionally provided in sapp_desc */
	query_desc                            :: proc()                         -> Internal_Desc     --- ; /* return a copy of the sapp_desc structure */
	request_quit                          :: proc()                                              --- ; /* initiate a "soft quit" (sends SAPP_EVENTTYPE_QUIT_REQUESTED) */
	cancel_quit                           :: proc()                                              --- ; /* cancel a pending quit (when SAPP_EVENTTYPE_QUIT_REQUESTED has been received) */
	quit                                  :: proc()                                              --- ; /* intiate a "hard quit" (quit application without sending SAPP_EVENTTYPE_QUIT_REQUSTED) */
	consume_event                         :: proc()                                              --- ; /* call from inside event callback to consume the current event (don't forward to platform) */
	frame_count                           :: proc()                         -> u64               --- ; /* get the current frame counter (for comparison with sapp_event.frame_count) */
	set_clipboard_string                  :: proc(str: cstring)                                  --- ; /* write string into clipboard */
	get_clipboard_string                  :: proc()                         -> cstring           --- ; /* read string from clipboard (usually during SAPP_EVENTTYPE_CLIPBOARD_PASTED) */

	@(private, link_name="sapp_run")
    _run                                  :: proc(desc: ^Internal_Desc)     -> c.int             --- ; /* special run-function for SOKOL_NO_ENTRY (in standard mode this is an empty stub) */

	gles2                                 :: proc()                         -> c.bool            --- ; /* GL: return true when GLES2 fallback is active (to detect fallback from GLES3) */
	html5_ask_leave_site                  :: proc(ask: c.bool)                                   --- ; /* HTML5: enable or disable the hardwired "Leave Site?" dialog box */
	metal_get_device                      :: proc()                         -> rawptr            --- ; /* Metal: get ARC-bridged pointer to Metal device object */
	metal_get_renderpass_descriptor       :: proc()                         -> rawptr            --- ; /* Metal: get ARC-bridged pointer to this frame's renderpass descriptor */
	metal_get_drawable                    :: proc()                         -> rawptr            --- ; /* Metal: get ARC-bridged pointer to current drawable */
	macos_get_window                      :: proc()                         -> rawptr            --- ; /* macOS: get ARC-bridged pointer to macOS NSWindow */
	ios_get_window                        :: proc()                         -> rawptr            --- ; /* iOS: get ARC-bridged pointer to iOS UIWindow */
	d3d11_get_device                      :: proc()                         -> rawptr            --- ; /* D3D11: get pointer to ID3D11Device object */
	d3d11_get_device_context              :: proc()                         -> rawptr            --- ; /* D3D11: get pointer to ID3D11DeviceContext object */
	d3d11_get_render_target_view          :: proc()                         -> rawptr            --- ; /* D3D11: get pointer to ID3D11RenderTargetView object */
	d3d11_get_depth_stencil_view          :: proc()                         -> rawptr            --- ; /* D3D11: get pointer to ID3D11DepthStencilView */
	win32_get_hwnd                        :: proc()                         -> rawptr            --- ; /* Win32: get the HWND window handle */
	android_get_native_activity           :: proc()                         -> rawptr            --- ; /* Android: get native activity handle */
}

run :: inline proc(desc: Desc) -> bool {
	desc := desc;

	init    :: proc "c" (u: rawptr)             { (cast(^Desc)u).init_cb(); }
	frame   :: proc "c" (u: rawptr)             { (cast(^Desc)u).frame_cb(); }
	cleanup :: proc "c" (u: rawptr)             { (cast(^Desc)u).cleanup_cb(); }
	event   :: proc "c" (e: ^Event, u: rawptr)  { (cast(^Desc)u).event_cb(e^); }
	fail    :: proc "c" (s: cstring, u: rawptr) { (cast(^Desc)u).fail_cb(string(s)); }

	internal_desc: Internal_Desc;
    internal_desc.user_data        = &desc;
    internal_desc.width            = cast(c.int)desc.width;
    internal_desc.height           = cast(c.int)desc.height;
    internal_desc.window_title     = strings.clone_to_cstring(desc.window_title, context.temp_allocator);
    internal_desc.sample_count     = cast(c.int)desc.sample_count;
    internal_desc.swap_interval    = cast(c.int)desc.swap_interval;
    internal_desc.high_dpi         = desc.high_dpi;
    internal_desc.fullscreen       = desc.fullscreen;
    internal_desc.alpha            = desc.alpha;
    internal_desc.user_cursor      = desc.user_cursor;
    internal_desc.enable_clipboard = desc.enable_clipboard;
    internal_desc.clipboard_size   = cast(c.int)desc.clipboard_size;

	if desc.init_cb != nil    do internal_desc.init_userdata_cb = init;
	if desc.frame_cb != nil   do internal_desc.frame_userdata_cb = frame;
	if desc.cleanup_cb != nil do internal_desc.cleanup_userdata_cb = cleanup;
	if desc.event_cb != nil   do internal_desc.event_userdata_cb = event;
	if desc.fail_cb != nil    do internal_desc.fail_userdata_cb = fail;

	return _run(&internal_desc) == 0;
}
