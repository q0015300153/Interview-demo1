@ECHO OFF
FOR /F "tokens=1,2delims==" %%x IN (.env) DO (IF NOT "%%y"=="" (SET %%x=%%y))
FOR /F "tokens=1,*delims= " %%a IN ("%*") DO (SET all=%%b)

IF [%~1] equ []            (call shell/run.bat)
IF [%~1] equ [s]           (call shell/stop.bat)
IF [%~1] equ [stop]        (call shell/stop.bat)
IF [%~1] equ [e]           (call shell/exec.bat %all%)
IF [%~1] equ [exec]        (call shell/exec.bat %all%)
IF [%~1] equ [d]           (call shell/dev-laravel.bat)
IF [%~1] equ [dev-laravel] (call shell/dev-laravel.bat)
IF [%~1] equ [l]           (call shell/laravel.bat %all%)
IF [%~1] equ [laravel]     (call shell/laravel.bat %all%)