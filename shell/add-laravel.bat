@ECHO OFF
FOR /F "tokens=1,2delims==" %%x IN (.env) DO (IF "%%y" neq "" (SET %%x=%%y))

FOR /F "delims=: tokens=2" %%a IN ('run.bat e ls "/var/www/html/%LaravelName%"') DO (SET f="%%a")
IF [%f%] neq [] (
	IF "%LaravelFrom%" equ "" (
		run.bat e composer create-project --prefer-dist laravel/laravel %LaravelName%
	) ELSE (
		run.bat e %LaravelFrom%
		run.bat l composer install
		run.bat l cp .env.example .env
		run.bat l php artisan key:generate
	)

	run.bat e chmod -R 757 %LaravelName%
	run.bat l chown -R www-data:www-data storage
	run.bat l chown -R www-data:www-data bootstrap/cache
	run.bat l chmod -R 775 storage
	run.bat l chmod -R 775 bootstrap/cache
)