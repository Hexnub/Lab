
```powershell
nvim --version
```
### update
```powershell
winget upgrade Neovim.Neovim
```

# Git for PowerShell
https://git-scm.com/book/en/v2/Appendix-A:-Git-in-Other-Environments-Git-in-PowerShell
```powershell 
winget install --id Git.Git -e --source winget
```

Add Git to your PATH EV: in Settings > System > About > Advanced System Settings > Environmental Variables > Edit the System Variable called Path > New 
```
C:\Program Files\Git\cmd
```
### Telescope
https://github.com/nvim-telescope/telescope.**nvim**

Install these two programs:
###### rigrep
https://github.com/BurntSushi/ripgrep

```powershell
winget install -e --id BurntSushi.ripgrep.MSVC
```

```powershell
rg --version   
```

###### fd
http://github.com/sharkdp/fd
```powershell
winget install -e --id sharkdp.fd
```
```
fd --version
```

Add plugin spec file
C:\Users\{user}\AppData\Local\nvim\lua\plugins\telescope.lua
```
return {

  "nvim-telescope/telescope.nvim",

  version = "*",

  dependencies = {

    "nvim-lua/plenary.nvim",

    -- optional but recommended

    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

  },

}
```

Use Telescope as your default picker
lua/config/options.lua
```
vim.g.lazyvim_picker = "telescope"
```
after launching nvim check telescope's health status
```
:checkhealth telescope
```

If you launch nvim and and see this error: build failed 'make' is not recognized as an internal or external command, operable program or batch file.

Install Make with Choco
https://docs.chocolatey.org/en-us/choco/setup/
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

```powershell
choco upgrade chocolatey
```

```powershell
choco install make
```

```powershell
make --version
```

```powershell
make "$ENV:USERPROFILE\AppData\Local\nvim-data\lazy\telescope-fzf-native.nvim"
```

Here's a cool prebuilt version of telescope:
https://github.com/tsakirist/telescope-lazy.nvim

Optional: add nvim-web-devicons for nerd font icons
https://github.com/nvim-tree/nvim-web-devicons
```
return { "nvim-tree/nvim-web-devicons", opts = {} },
```
# LazyVim
clone repo
```
git clone https://github.com/LazyVim/starter "$ENV:USERPROFILE\AppData\Local\nvim"
```
delete .git to start your own repo
```
Remove-Item -Recurse -Force "$ENV:USERPROFILE\AppData\Local\nvim\.git"
```
your neovim config files are located in
```
C:\Users\YourUser\AppData\Local\nvim
```
### Start Neovim
```
nvim
```

Follow Setup instructions here:
https://www.lazyvim.org/

```
Get-Content "$ENV:USERPROFILE\AppData\Local\nvim\lua\config\options.lua"
```

### Help
I use this extensively to learn how to do things in neovim   
`<leader>` `s` `h`
