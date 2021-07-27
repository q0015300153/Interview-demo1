@ECHO OFF
FOR /F "tokens=1,2delims==" %%x IN (.env) DO (IF NOT "%%y"=="" (SET %%x=%%y))

call run.bat stop
call run.bat
call run.bat stop
docker login -u _json_key --password-stdin https://asia.gcr.io < %JSONKEY%
docker build -t asia.gcr.io/%GCPID%/%LaravelName%:latest .
docker push asia.gcr.io/%GCPID%/%LaravelName%:latest