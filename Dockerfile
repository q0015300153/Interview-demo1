FROM ubuntu:latest
MAINTAINER q0015300153@gmail.com

# 時區設定
RUN TZ=Asia/Taipei && \
    DEBIAN_FRONTEND=noninteractive && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends tzdata 

# 安裝軟體
RUN apt-get install -y git curl libnss3-tools && \
	# 安裝 nodejs
 	curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
	apt-get install -y nodejs && \
	# 安裝 php
	apt-get install -y php-fpm openssl php-common php-curl php-json php-mbstring php-mysql php-xml php-zip && \
	# 安裝伺服器 NginX
	apt-get install -y nginx && \
	# 安裝資料庫 mariadb
	apt-get install -y mariadb-server && \
	# 設定 mariadb root 密碼
	mysqladmin -u root password 00153 && \
	# 設定 mariadb 新資料庫與使用者
	mysql -uroot -p00153 -e "CREATE DATABASE home;" && \
	mysql -uroot -p00153 -e "CREATE USER 'pi'@'localhost' IDENTIFIED BY '00153';" && \
	mysql -uroot -p00153 -e "GRANT ALL PRIVILEGES ON home.* TO 'pi'@'localhost';"

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

# 設定 SSL 憑證與 PHP-fpm
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
WORKDIR /var/www
RUN mkcert localhost 127.0.0.1



EXPOSE 80 443
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]