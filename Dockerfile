FROM ubuntu:latest
MAINTAINER q0015300153@gmail.com

# 參數設定
ARG DBRootPass
ARG DBUserName
ARG DBUserPass
ARG DBDataBase
ARG LaravelName
ARG PHPVersion
ARG GoVersion
ARG NgrokToken

# 時區設定
RUN TZ=Asia/Taipei && \
    DEBIAN_FRONTEND=noninteractive && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends tzdata 

# 安裝軟體 NginX、MariaDB supervisor
RUN apt-get install -y git curl libnss3-tools wget zip unzip nginx mariadb-server supervisor && \
	# 安裝 nodejs
	curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
	apt install -y nodejs && \
	# 安裝 php
	apt install -y software-properties-common && \
	add-apt-repository ppa:ondrej/php && \
	apt update -y && \
	apt install -y php${PHPVersion}-fpm openssl php-common php-curl php-json php-mbstring php-mysql php-xml php-zip && \
	# 安裝 composer
	wget -O composer-setup.php https://getcomposer.org/installer && \
	php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# 安裝 go
ADD https://golang.org/dl/go${GoVersion}.linux-amd64.tar.gz go.tar.gz
RUN tar zxvf go.tar.gz
ENV PATH=/go/bin:$PATH

# 安裝開發用 localhost SSL 憑證 mkcert
RUN git clone https://github.com/FiloSottile/mkcert && \
	cd mkcert && \
	go build -ldflags "-X main.Version=$(git describe --tags)"
ENV PATH=/mkcert:$PATH
RUN mkcert -install

# 安裝 Ngrok 用於測試外網 Https
ADD https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip ngrok.zip
RUN unzip ngrok.zip && cp ngrok /usr/local/bin/ngrok && \
	ngrok authtoken ${NgrokToken}

# 設定 SSL 憑證與 PHP-fpm
WORKDIR /var/www
COPY ./conf/default /etc/nginx/sites-available/default
RUN sed -i "s#\${LaravelName}#${LaravelName}#g" /etc/nginx/sites-available/default && \
	sed -i "s#\${PHPVersion}#${PHPVersion}#g" /etc/nginx/sites-available/default && \
	mkcert localhost 127.0.0.1

# 複製 Laravel 專案
COPY ./html ./html
RUN if [ -d "/var/www/html/${LaravelName}" ]; then\
	cd /var/www/html/${LaravelName};\
	composer install;\
	chmod -R 757 %LaravelName%;\
	chown -R www-data:www-data storage;\
	chown -R www-data:www-data bootstrap/cache;\
	chmod -R 775 storage;\
	chmod -R 775 bootstrap/cache;\
	npm install;\
	npm run prod;\
	sed -i "s/APP_DEBUG=*/APP_DEBUG=false/g" .env;\
fi

# 建立 supervisor 設定檔
RUN echo '\
[unix_http_server]\n\
file=/dev/shm/supervisor.sock\n\
chmod=0700\n\
\n\
[supervisord]\n\
nodaemon=true\n\
logfile=/var/log/supervisor/supervisord.log\n\
pidfile=/var/run/supervisord.pid\n\
childlogdir=/var/log/supervisor\n\
\n\
[rpcinterface:supervisor]\n\
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface\n\
\n\
[supervisorctl]\n\
serverurl=unix:///dev/shm/supervisor.sock\n\
\n\
[include]\n\
files = /etc/supervisor/conf.d/*.conf\n\
' > /etc/supervisor/supervisor.conf

# 建立 supervisor 的 nginx 設定檔
RUN echo '\
[program:nginx]\n\
command=nginx -c /etc/nginx/nginx.conf\n\
numprocs=1\n\
autostart=true\n\
autorestart=true\n\
user=root\n\
#stdout_logfile_maxbytes=20MB\n\
#stdout_logfile_backups=20\n\
#stdout_logfile = /var/www/html/nginx.log\n\
' > /etc/supervisor/conf.d/nginx.conf

# 建立 supervisor 的 php 設定檔
RUN echo '\
[program:php]\n\
command=/etc/init.d/php'${PHPVersion}'-fpm start\n\
numprocs=1\n\
autostart=true\n\
autorestart=true\n\
user=root\n\
#stdout_logfile_maxbytes=20MB\n\
#stdout_logfile_backups=20\n\
#stdout_logfile = /var/www/html/php.log\n\
' > /etc/supervisor/conf.d/php.conf

# 建立 supervisor 的 mariadb 設定檔
RUN echo '\
[program:mariadb]\n\
command=/etc/init.d/mysql start\n\
numprocs=1\n\
autostart=true\n\
autorestart=true\n\
user=root\n\
#stdout_logfile_maxbytes=20MB\n\
#stdout_logfile_backups=20\n\
#stdout_logfile = /var/www/html/mariadb.log\n\
' > /etc/supervisor/conf.d/mariadb.conf

VOLUME ["/var/www/html", "/var/lib/mysql"]
EXPOSE 80 443
STOPSIGNAL SIGTERM
COPY ./shell/init.sh /var/www/init.sh
RUN sed -i "s#\${DBRootPass}#${DBRootPass}#g" /var/www/init.sh && \
	sed -i "s#\${DBDataBase}#${DBDataBase}#g" /var/www/init.sh && \
	sed -i "s#\${DBUserName}#${DBUserName}#g" /var/www/init.sh && \
	sed -i "s#\${DBUserPass}#${DBUserPass}#g" /var/www/init.sh
CMD ["/var/www/init.sh"]