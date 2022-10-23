@echo off
curl https://github.com/house-of-abbey/scratch_vhdl/releases/latest/download/scratch-vhdl-vscode.vsix --output ./scratch-vhdl-vscode.vsix
code --install-extension ./scratch-vhdl-vscode.vsix
