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

# 時區設定
RUN TZ=Asia/Taipei && \
    DEBIAN_FRONTEND=noninteractive && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends tzdata 

# 安裝軟體 NginX、MariaDB supervisor
RUN apt-get install -y git curl libnss3-tools wget nginx mariadb-server supervisor && \
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

# 設定資料庫 mariadb
RUN /etc/init.d/mysql start && \
	# 設定 mariadb root 密碼
	mysqladmin -u root password ${DBRootPass} && \
	## 設定 mariadb 新資料庫與使用者
	mysql -uroot -p${DBRootPass} -e "CREATE DATABASE ${DBDataBase};" && \
	mysql -uroot -p${DBRootPass} -e "CREATE USER '${DBUserName}'@'localhost' IDENTIFIED BY '${DBUserPass}';" && \
	mysql -uroot -p${DBRootPass} -e "GRANT ALL PRIVILEGES ON ${DBDataBase}.* TO '${DBUserName}'@'localhost';"

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

# 設定 SSL 憑證與 PHP-fpm
WORKDIR /var/www
COPY ./conf/default /etc/nginx/sites-available/default
RUN sed -i "s#\${LaravelName}#${LaravelName}#g" /etc/nginx/sites-available/default && \
	sed -i "s#\${PHPVersion}#${PHPVersion}#g" /etc/nginx/sites-available/default && \
	mkcert localhost 127.0.0.1

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
user=root\
' > /etc/supervisor/conf.d/nginx.conf

# 建立 supervisor 的 php 設定檔
RUN echo '\
[program:php]\n\
command=/etc/init.d/php'${PHPVersion}'-fpm start\n\
numprocs=1\n\
autostart=true\n\
autorestart=true\n\
user=root\
' > /etc/supervisor/conf.d/php.conf

# 建立 supervisor 的 mariadb 設定檔
RUN echo '\
[program:mariadb]\n\
command=/etc/init.d/mysql start\n\
numprocs=1\n\
autostart=true\n\
autorestart=true\n\
user=root\
' > /etc/supervisor/conf.d/mariadb.conf

VOLUME ["/var/www/html", "/var/lib/mysql"]
EXPOSE 80 443
STOPSIGNAL SIGTERM
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisor.conf"]