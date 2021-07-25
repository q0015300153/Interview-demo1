@ECHO OFF
FOR /F "tokens=1,2delims==" %%x IN (.env) DO (IF NOT "%%y"=="" (SET %%x=%%y))

FOR /F "delims=: tokens=2" %%a IN ('exec.bat ls "/var/www/html/%LaravelName%"') DO (SET f="%%a")
<<<<<<< HEAD
IF NOT %f%=="" (
	IF "%LaravelFrom%"=="" (
		REM 建立專案
		exec.bat composer create-project --prefer-dist laravel/laravel ${LaravelName}
		exec.bat chmod -R 757 ${LaravelName}
		exec.bat cd ${LaravelName} && chown -R \$USER:www-data storage
		exec.bat cd ${LaravelName} && chown -R \$USER:www-data bootstrap/cache
		exec.bat cd ${LaravelName} && chmod -R 775 storage
		exec.bat cd ${LaravelName} && chmod -R 775 bootstrap/cache
=======
IF NOT "%f%"=="" (
	IF "%LaravelFrom%"=="" (
		REM 建立專案
		exec.bat composer create-project --prefer-dist laravel/laravel %LaravelName%
		exec.bat chmod -R 757 %LaravelName%
		exec.bat "cd %LaravelName% && chown -R \$USER:www-data storage"
		exec.bat "cd %LaravelName% && chown -R \$USER:www-data bootstrap/cache"
		exec.bat "cd %LaravelName% && chmod -R 775 storage"
		exec.bat "cd %LaravelName% && chmod -R 775 bootstrap/cache"
>>>>>>> addVersion
	) ELSE (
		REM 克隆專案
		./exec.bat %LaravelFrom%
	)
)