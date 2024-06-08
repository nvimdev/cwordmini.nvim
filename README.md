# cwordmini.nvim

A very minimal less than 80 lines plugin used for highlight all cursor words on
buffer. support multiple-bytes characters, no any autocmd event binding.

Notic it works on neovim redraw circly, so if not trigger redraw this plugin will
not works correctly.


## Usage

```lua
    require('cwordmini').setup() -- use default config or setup({exclude = {..} })
```

Option in setup param table just `exclude` filetype or buftype list table

Please config highlight group 'CursorWord' after setup or in your colorscheme 


## Licenses MIT
