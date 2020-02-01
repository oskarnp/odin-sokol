#!/bin/sh
clang -O2 -DNDEBUG -ObjC -fobjc-arc -dynamiclib -DSOKOL_METAL sokol_impl.c -o sokol_impl_darwin_metal.dylib -framework MetalKit -framework AppKit -framework Metal -framework Quartz
clang -O2 -DNDEBUG -ObjC -fobjc-arc -dynamiclib -DSOKOL_GLCORE33 sokol_impl.c -o sokol_impl_darwin_glcore33.dylib -framework OpenGL -framework AppKit
