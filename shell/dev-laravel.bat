@ECHO OFF
FOR /F "tokens=1,2delims==" %%x IN (.env) DO (IF "%%y" neq "" (SET %%x=%%y))

FOR /F "delims=: tokens=2" %%a IN ('run.bat e ls "/var/www/html/%LaravelName%"') DO (SET f="%%a")
IF [%f%] neq [] (
	IF "%LaravelFrom%" equ "" (
		REM new Laravel project
		call shell/exec.bat composer create-project --prefer-dist laravel/laravel %LaravelName%
	) ELSE (
		REM git clone Laravel project
		call shell/exec.bat %LaravelFrom%
	)

	call shell/exec.bat chmod -R 757 %LaravelName%
	call shell/laravel.bat chown -R www-data:www-data storage
	call shell/laravel.bat chown -R www-data:www-data bootstrap/cache
	call shell/laravel.bat chmod -R 775 storage
	call shell/laravel.bat chmod -R 775 bootstrap/cache

	call shell/laravel.bat sed -i "s/APP_NAME=.*/APP_NAME=%Project%/g" .env
	call shell/laravel.bat sed -i "s/DB_USERNAME=.*/DB_USERNAME=%DBUserName%/g" .env
	call shell/laravel.bat sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=%DBUserPass%/g" .env
	call shell/laravel.bat sed -i "s/DB_DATABASE=.*/DB_DATABASE=%DBDataBase%/g" .env
	call shell/laravel.bat sed -i "s/APP_DEBUG=.*/APP_DEBUG=true/g" .env
	call shell/laravel.bat sed -i "s/APP_URL=.*/APP_URL=https:\/\/localhost/g" .env

	IF "%LaravelFrom%" equ "" (
		REM new Laravel project
		rem call shell/laravel.bat mkdir ./resources/js/Jetstream
		rem call shell/laravel.bat composer require laravel/jetstream
		rem call shell/laravel.bat php artisan jetstream:install inertia --teams
		call shell/laravel.bat mkdir ./resources/js/Pages
		call shell/laravel.bat mkdir ./resources/js/components
		call shell/laravel.bat composer require inertiajs/inertia-laravel
		call shell/laravel.bat php artisan inertia:middleware
		call shell/laravel.bat php artisan migrate
		call shell/laravel.bat npm install -g npm
		call shell/laravel.bat npm install
		call shell/laravel.bat npm install vue@next
		call shell/laravel.bat npm install vue-devtools --save-dev
		call shell/laravel.bat npm install @inertiajs/inertia @inertiajs/inertia-vue3
		call shell/laravel.bat npm install @inertiajs/progress
		rem call shell/laravel.bat npm install @babel/plugin-syntax-dynamic-import
		call shell/laravel.bat npm install -D tailwindcss@latest postcss@latest autoprefixer@latest
		call shell/laravel.bat npx tailwindcss init
		call shell/laravel.bat npm install vue-loader
		call shell/laravel.bat npm run dev
	) ELSE (
		REM git clone Laravel project
		call shell/laravel.bat composer install
		call shell/laravel.bat cp .env.example .env
		call shell/laravel.bat php artisan key:generate
		call shell/laravel.bat php artisan migrate
		call shell/laravel.bat npm install
		call shell/laravel.bat npm run dev
	)
)

start call shell/laravel.bat npm run watch-poll
start call shell/ngrok.bat