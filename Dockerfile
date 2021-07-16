FROM ubuntu:latest
MAINTAINER q0015300153@gmail.com

# 參數設定
# 資料庫 root 密碼
ARG DBRootPass="admin"
# 資料庫新使用者名稱
ARG DBUserName="user"
# 資料庫新使用者密碼
ARG DBUserPass="test"
# 新資料庫名稱
ARG DataBase="home"
# Laravel 專案名稱
ARG LaravelName="demo-1"
# Laravel 專案來源，空白則新增，否則 git clone
ARG LaravelFrom=""

# 時區設定
RUN TZ=Asia/Taipei && \
    DEBIAN_FRONTEND=noninteractive && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends tzdata 

# 安裝軟體 NginX、MariaDB
RUN apt-get install -y git curl libnss3-tools wget python3-pip nginx mariadb-server && \
	# 安裝 nodejs
	curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
	apt install -y nodejs && \
	# 安裝 php
	apt install -y software-properties-common && \
	add-apt-repository ppa:ondrej/php && \
	apt update -y && \
	apt install -y php8.0-fpm openssl php-common php-curl php-json php-mbstring php-mysql php-xml php-zip && \
	# 安裝 composer
	wget -O composer-setup.php https://getcomposer.org/installer && \
	php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
	# 安裝 supervisor
	pip3 install supervisor

# 設定資料庫 mariadb
RUN /etc/init.d/mysql start && \
	# 設定 mariadb root 密碼
	mysqladmin -u root password ${DBRootPass} && \
	## 設定 mariadb 新資料庫與使用者
	mysql -uroot -p${DBRootPass} -e "CREATE DATABASE ${DataBase};" && \
	mysql -uroot -p${DBRootPass} -e "CREATE USER '${DBUserName}'@'localhost' IDENTIFIED BY '${DBUserPass}';" && \
	mysql -uroot -p${DBRootPass} -e "GRANT ALL PRIVILEGES ON ${DataBase}.* TO '${DBUserName}'@'localhost';"

# 安裝 go
ADD https://golang.org/dl/go1.16.6.linux-amd64.tar.gz go.tar.gz
RUN tar zxvf go.tar.gz
ENV PATH=/go/bin:$PATH

# 安裝開發用 localhost SSL 憑證 mkcert
RUN git clone https://github.com/FiloSottile/mkcert && \
	cd mkcert && \
	go build -ldflags "-X main.Version=$(git describe --tags)"
ENV PATH=/mkcert:$PATH
RUN mkcert -install

## 安裝 laravel
#WORKDIR /var/www/html
#RUN if [ ! -d "/var/www/html/${LaravelName}" ]; then\
#		if [-z "${LaravelFrom}"]; then\
#			composer global require laravel/installer && \
#			laravel new ${LaravelName};\
#		fi\
#	fi

## 安裝 laravel
#RUN if [ ! -d "/var/www/html/${LaravelName}" ]; then\
#		if [[ "${LaravelFrom}" == "" ]]; then\
#			composer global require laravel/installer && \
#			laravel new ${LaravelName};\
#		else\
#			git clone ${LaravelFrom};\
#		fi\
#	fi

# 設定 SSL 憑證與 PHP-fpm
WORKDIR /var/www
COPY ./conf/default /etc/nginx/sites-available/default
RUN sed -i "s#\${LaravelName}#${LaravelName}#g" /etc/nginx/sites-available/default
RUN mkcert localhost 127.0.0.1

## 建立 supervisor 設定檔
#RUN echo -e '\
#[program:nginx]\n\
#command=nginx -g\n\
#numprocs=1\n\
#autostart=true\n\
#autorestart=true\n\
#user=root\
#' > /etc/supervisor/conf.d/nginx.conf
#
#RUN echo -e '\
#[program:mariadb]\n\
#command=/etc/init.d/mysql start\n\
#numprocs=1\n\
#autostart=true\n\
#autorestart=true\n\
#user=root\
#' > /etc/supervisor/conf.d/mariadb.conf
#
#RUN supervisorctl update

VOLUME ["/var/www/html", "/var/lib/mysql"]
EXPOSE 80 443
STOPSIGNAL SIGTERM
#CMD ["sh", "-c", "nginx -g daemon off; && mysql start"]
#CMD ["nginx", "-g", "daemon off;"]
#CMD ["supervisorctl", "start", "all"]