# odin-sokol

[Sokol](https://github.com/floooh/sokol) bindings for the Odin programming language.

## Status

Only MacOS Catalina and Metal+GL3.3 currently supported out-of-the-box since that is what I use personally, but should be easy to create build scripts for other platforms (PR:s welcome.) Sokol itself supports the following:

- platforms: MacOS, iOS, HTML5, Win32, Linux, Android (TODO: RaspberryPi)
- 3D-APIs: Metal, D3D11, GL3.2, GLES2, GLES3, WebGL, WebGL2

## Examples

From root directory:
```sh
$ odin run examples/<name>.odin -define:RENDERER=\"metal\"
$ odin run examples/<name>.odin -define:RENDERER=\"glcore33\"
```
Replace `<name>` with the name of the example to run.
