@ECHO OFF
FOR /F "tokens=1,2delims==" %%x IN (.env) DO (IF NOT "%%y"=="" (SET %%x=%%y))

docker build -t %Project%:latest ^
	--build-arg DBRootPass=%DBRootPass% ^
	--build-arg DBRootPass=%DBRootPass% ^
	--build-arg DBUserName=%DBUserName% ^
	--build-arg DBUserPass=%DBUserPass% ^
	--build-arg DBDataBase=%DBDataBase% ^
	--build-arg LaravelName=%LaravelName% ^
	--build-arg PHPVersion=%PHPVersion% ^
	--build-arg GoVersion=%GoVersion% ^
	 .

docker run -itd --name %Project% ^
	-p 80:80 -p 443:443 ^
	-v %~dp0/../html:/var/www/html ^
	-v %~dp0/../database:/var/lib/mysql ^
	%Project%:latest