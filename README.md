# copy-image.yazi

A [yazi](https://yazi-rs.github.io/) plugin to store an image in the system clipboard. 
Tested with Yazi 25.5.28 

## Dependencies

[wl-clipboard](https://github.com/bugaevc/wl-clipboard) 
    
## Installation
```sh
ya pkg add vsadrn/copy-image
```

## Usage
Add this to your `~/.config/yazi/keymap.toml`:
```toml
[[mgr.prepend_keymap]]
on = [ "c", "c" ]
run = "plugin copy-image"
desc = "copy file content to system clipboard"
```
Make sure the <kbd>c</kbd> + <kbd>c</kbd> keybind is not used elsewhere.

## TODO
- Add X11 support
- Add MacOS support

## License

This plugin is MIT-licensed. For more information check the [LICENSE](LICENSE) file.

