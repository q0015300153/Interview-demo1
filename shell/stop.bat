@ECHO OFF
FOR /F "tokens=1,2delims==" %%x IN (.env) DO (IF NOT "%%y"=="" (SET %%x=%%y))

docker stop %Project%
docker container rm %Project%