// Simple 2D rendering from vertex buffer.
// Adapted from: https://github.com/floooh/sokol-samples/blob/master/sapp/triangle-sapp.c

package main

RENDERER :: #config(RENDERER, "metal");

import "core:fmt"
import sa "../sokol_app"
import sg "../sokol_gfx"

/* application state */
State :: struct {
	pip:         sg.Pipeline,
	bind:        sg.Bindings,
	pass_action: sg.Pass_Action,
}

state: State;

init :: proc() {
	sg.setup({
		mtl_device = sa.metal_get_device(),
		mtl_renderpass_descriptor_cb = sa.metal_get_renderpass_descriptor,
		mtl_drawable_cb = sa.metal_get_drawable,
	});

	/* a vertex buffer with 3 vertices */
	vertices := [?]f32{
		// positions         // colors
		 0.0,  0.5, 0.5,     1.0, 0.0, 0.0, 1.0,
		 0.5, -0.5, 0.5,     0.0, 1.0, 0.0, 1.0,
		-0.5, -0.5, 0.5,     0.0, 0.0, 1.0, 1.0,
	};
	state.bind.vertex_buffers[0] = sg.make_buffer({
		size = size_of(vertices),
		content = &vertices,
		label = "triangle-vertices",
	});

	when RENDERER == "glcore33" {
		shader_desc := sg.Shader_Desc {
			attrs = {
				ATTR_vs_position = { name = "position" },
				ATTR_vs_color0   = { name = "color0" },
			},	
			vs = {
				source = `
				#version 330
				in vec4 position;
				in vec4 color0;

				out vec4 color;

				void main() {
					gl_Position = position;
					color = color0;
				}
				`,
				},
				fs = {
					source = `
					#version 330
					in vec4 color;
					out vec4 frag_color;
					void main() {
						frag_color = color;
					}
					`,
				},
		};
	}
	else when RENDERER == "metal" {
		shader_desc := sg.Shader_Desc {
	        /*
	            The shader main() function cannot be called 'main' in 
	            the Metal shader languages, thus we define '_main' as the
	            default function. This can be override with the 
	            sg_shader_desc.vs.entry and sg_shader_desc.fs.entry fields.
	        */
	        vs = { source =`
	            #include <metal_stdlib>
	            using namespace metal;
	            struct vs_in {
	              float4 position [[attribute(0)]];
	              float4 color [[attribute(1)]];
	            };
	            struct vs_out {
	              float4 position [[position]];
	              float4 color;
	            };
	            vertex vs_out _main(vs_in inp [[stage_in]]) {
	              vs_out outp;
	              outp.position = inp.position;
	              outp.color = inp.color;
	              return outp;
	            }
	            `,
	        }, fs = { source = `
	            #include <metal_stdlib>
	            using namespace metal;
	            fragment float4 _main(float4 color [[stage_in]]) {
	              return color;
	            };
	            `
	        }
        };
	}
	else {
		#panic("Please define RENDERER to either \"metal\" or \"glcore33\"");
	}
	shd: sg.Shader = sg.make_shader(shader_desc);

	/* create a pipeline object (default render states are fine for triangle) */
	state.pip = sg.make_pipeline({
		shader = shd,
		/* if the vertex layout doesn't have gaps, don't need to provide strides and offsets */
		layout = {
			attrs = {
				ATTR_vs_position = { format = .FLOAT3 },
				ATTR_vs_color0   = { format = .FLOAT4 },
			},
		},
		label = "triangle-pipeline",
	});

	/* a pass action to framebuffer to black */
	state.pass_action = {
		colors = {
			0 = { action = .CLEAR, val = {0.0, 0.0, 0.0, 1.0} },
		},
	};
}

frame :: proc() {
	sg.begin_default_pass(state.pass_action, sa.width(), sa.height());
	sg.apply_pipeline(state.pip);
	sg.apply_bindings(state.bind);
	sg.draw(0, 3, 1);
	sg.end_pass();
	sg.commit();
}

cleanup :: proc() {
	sg.shutdown();
}

main :: proc() {
	sa.run({
		init_cb = init,
		frame_cb = frame,
		cleanup_cb = cleanup,
		width = 640,
		height = 480,
		window_title = "Triangle (sokol-app)",
	});
}

ATTR_vs_position :: 0;
ATTR_vs_color0   :: 1;
