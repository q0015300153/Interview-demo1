@ECHO OFF
REM 刪除所有容器與映像檔
FOR /f "tokens=*" %%i IN ('docker ps -qa') DO docker stop %%i
FOR /f "tokens=*" %%i IN ('docker ps -qa') DO docker rm %%i
FOR /f "tokens=*" %%i IN ('docker images -qa') DO docker image rmi -f %%i
docker-compose down --volumes
docker volume rm $(docker volume ls -q)
docker ps -a
docker images -a