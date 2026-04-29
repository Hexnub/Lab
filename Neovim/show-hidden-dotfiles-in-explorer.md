# plugin spec file

Windows
C:\Users\{user}\AppData\Local\nvim\lua\plugins\snacks.lua

Linux
~/.config/nvim/lua/plugins/snacks.lua

```
return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        hidden = true,
        sources = {
          files = {
            hidden = true,  -- Show hidden/dotfiles
            ignored = true, -- Show gitignored files
          },
        },
      },
    },
  },
}
```
