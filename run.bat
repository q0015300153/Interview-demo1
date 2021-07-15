@ECHO OFF
docker build -t test:latest .
docker run -itd --name test -p 80:80 -p 443:443 -v ./html:/var/www/html -v ./database:/var/lib/mysql test:latest
rem docker cp test:/etc/nginx/sites-available/default ./conf/default
rem docker exec -it test ls -l /etc/nginx/sites-available
docker exec -it test /bin/bash
docker stop test
docker container rm test