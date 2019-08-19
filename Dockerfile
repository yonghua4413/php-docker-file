FROM centos:7
MAINTAINER hxai.net
ENV TIME_ZOME Asia/Shanghai
ENV PHP_VERSION 7.2.4

#安装基本环境
RUN yum install -y gcc autoconf gcc-c++ make libxml2 libxml2-devel openssl openssl-devel \
                   bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng \
                   libpng-devel freetype freetype-devel gmp gmp-devel readline readline-devel \
                   libxslt libxslt-devel systemd-devel openjpeg-devel libicu-devel

#复制到容器 /opt 下，自动解压
ADD php-${PHP_VERSION}.tar.gz /opt/

RUN cd /opt/php-${PHP_VERSION} && \
    ./configure --prefix=/usr/local/php \
    --prefix=/usr/local/php \
    --with-config-file-path=/usr/local/php/etc \
    --with-config-file-scan-dir=/usr/local/php/conf.d \
    --enable-fpm \
    --with-fpm-systemd \
    --enable-mysqlnd \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --with-iconv-dir \
    --with-freetype-dir=/usr/local/freetype \
    --with-jpeg-dir --with-png-dir \
    --with-zlib \
    --with-libxml-dir=/usr \
    --enable-xml \
    --disable-rpath \
    --enable-bcmath \
    --enable-shmop \
    --enable-sysvsem \
    --enable-inline-optimization \
    --with-curl --enable-mbregex \
    --enable-mbstring \
    --enable-intl \
    --enable-ftp \
    --with-gd \
    --with-openssl \
    --with-mhash \
    --enable-pcntl \
    --enable-sockets \
    --with-xmlrpc \
    --enable-zip \
    --enable-soap \
    --with-gettext \
    --disable-fileinfo \
    --enable-opcache \
    --with-xsl && \
    make && \
    make install

RUN cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf && \
    cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf && \
    cp /opt/php-${PHP_VERSION}/php.ini-production /usr/local/php/etc/php.ini && \
    sed -i 's/127.0.0.1/0.0.0.0/g' /usr/local/php/etc/php-fpm.conf && \
    sed -i 's/;daemonize = yes/daemonize=no/g' /usr/local/php/etc/php-fpm.conf && \
    echo "${TIME_ZOME}" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/${TIME_ZOME} /etc/localtime

#添加到环境变量
RUN ln -s /usr/local/php/bin/php /usr/bin/php \
    ln -s /usr/local/php/bin/phpize /usr/bin/phpize \
    ln -s /usr/local/php/sbin/php-fpm /usr/bin/php-fpm

RUN rm -rf /opt/php* && yum clean all
WORKDIR /usr/local/php/
EXPOSE 9000
CMD ["./sbin/php-fpm","-c","/usr/local/php/etc/php-fpm.conf"]
