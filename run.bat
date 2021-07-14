@ECHO OFF
docker build -t test:latest .
docker run test:latest nodejs version
REM docker run -itd -p 80:80 -p 443:443 test:latest