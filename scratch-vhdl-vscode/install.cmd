@echo off

call npm install
call npm install -g vsce

for /F "tokens=* USEBACKQ" %%F IN (`npx vsce package`) DO (
	set p=%%F
)

for /f "tokens=3" %%a in ("%p%") do (
	code --install-extension %%a
)