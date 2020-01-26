#requires -module posh-git, oh-my-posh
Set-Theme Paradox

<# Custom prompt config
# Install modules
Install-Module -Name posh-git -Scope CurrentUser -AllowPrerelease
Install-Module -Name oh-my-posh -Scope CurrentUser
Install-Module -Name PSReadLine -Scope CurrentUser -AllowPrerelease-Force -SkipPublisherCheck
Get-Module -Name posh-git, oh-my-posh, PSReadLine -ListAvailable

# Download "Delugia.Nerd.Font.Complete.ttf" from:
https://github.com/adam7/delugia-code/releases?WT.mc_id=-blog-scottha

# Change font settings in VSCode (only for terminal, as rendering issues for backticks)
"editor.fontFamily": "'Consolas', 'Fira Code', 'Courier New', monospace",
"editor.fontLigatures": false,
"terminal.integrated.fontFamily": "'Delugia Nerd Font', 'Consolas', 'Fira Code', 'Courier New', monospace"

Blog post: https://www.hanselman.com/blog/HowToMakeAPrettyPromptInWindowsTerminalWithPowerlineNerdFontsCascadiaCodeWSLAndOhmyposh.aspx
#>
