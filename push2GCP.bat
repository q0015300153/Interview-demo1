@ECHO OFF
FOR /F "tokens=1,2delims==" %%x IN (.env) DO (IF NOT "%%y"=="" (SET %%x=%%y))

REM docker login -u _json_key --password-stdin https://asia.gcr.io < %JSONKEY%
REM docker build -t asia.gcr.io/%GCPID%/%LaravelName%:latest .
REM docker push asia.gcr.io/%GCPID%/%LaravelName%:latest