# 使用 Ubuntu 22.04 做為基底映像檔
FROM ubuntu:22.04
LABEL maintainer="ASCDC <asdc.sinica@gmail.com>"

# 設定環境變數以避免在建構過程中出現交互式提示
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taipei
ENV LANG=zh_TW.UTF-8
ENV LC_ALL=zh_TW.UTF-8

# 複製本地腳本至映像檔
COPY entrypoint.sh /entrypoint.sh

# 複製本地腳本至映像檔
COPY run.sh /script/run.sh
COPY run.sh /backup/run.sh

# 確保腳本具有可執行的權限
RUN chmod +x /entrypoint.sh
RUN chmod +x /backup/run.sh

# 更新與安裝軟體套件
RUN chmod +x /script/*.sh && \
    sed -i -E 's/http:\/\/(.*\.)?(archive\.ubuntu\.com)/http:\/\/tw\.\2/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y install software-properties-common && \
    add-apt-repository -y ppa:ondrej/php && \
    add-apt-repository -y ppa:ondrej/apache2 && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install apache2 \
                       php8.2 \
                       php8.2-common \
                       php8.2-opcache \
                       php-uploadprogress \
                       php-memcache \
                       php8.2-zip \
                       php8.2-mysql \
                       php8.2-gd \
                       php8.2-imap \
                       php8.2-ldap \
                       php8.2-pgsql \
                       php8.2-pspell \
                       php8.2-tidy \
                       php8.2-dev \
                       php8.2-intl \
                       php8.2-curl \
                       php8.2-xmlrpc \
                       php8.2-xsl \
                       php8.2-bz2 \
                       php8.2-mbstring \
                       php8.2-maxminddb \
                       php8.2-lz4 \
                       php8.2-igbinary \
                       php8.2-redis \
                       php8.2-swoole \
                       php8.2-solr \
                       php8.2-imagick \
                       brotli \
                       jq \
                       git \
                       wget \
                       curl \
                       cron \
                       vim \
                       tzdata \
                       locales \
                       rsync \
                       sshpass \
                       language-pack-zh-hant \
                       language-pack-zh-hant-base \
                       apt-transport-https \
                       ca-certificates \
                       gnupg-agent \
                       build-essential \
                       pkg-config \
                       libmagickwand-dev \
                       gcc-multilib \
                       dkms \
                       make \
                       gcc \
                       g++ \
                       geoip-bin \
                       geoip-database && \
    echo "Asia/Taipei" > /etc/timezone && \
    rm /etc/localtime && \
    ln -s /usr/share/zoneinfo/Asia/Taipei /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    locale-gen zh_TW.UTF-8 && \
    echo "LANG=$LANG" > /etc/default/locale && \
    echo "export LANG=$LANG" >> ~/.bashrc && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 複製 MIME 類型文件至 Apache 配置
COPY custom-mime-types.conf /etc/apache2/conf-available/custom-mime-types.conf

# 複製 自訂好的000-default.conf 取代 Apache 預設站台配置
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# 設定 apache2
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar composer && \
    chmod +x composer && \
    mv composer /usr/local/bin && \
    composer require geoip2/geoip2:~2.0 && \
    a2enmod rewrite && \
    a2enmod brotli && \
    echo 'LogFormat "%{X-Client-IP}i %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" haproxy' > /etc/apache2/conf-available/custom-log-format.conf && \
    echo 'LogFormat "%v:%p %{X-Client-IP}i %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vhost_haproxy' >> /etc/apache2/conf-available/custom-log-format.conf && \
    a2enconf custom-log-format && \
    a2enconf custom-mime-types && \
    echo "SetEnv no-gzip 1" > /etc/apache2/conf-available/no-gzip.conf && \
    a2enconf no-gzip && \
    sed -i 's/;opcache.memory_consumption=.*/opcache.memory_consumption=256/' /etc/php/8.2/apache2/php.ini && \
    sed -i 's/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=16/' /etc/php/8.2/apache2/php.ini && \
    sed -i 's/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=7963/' /etc/php/8.2/apache2/php.ini && \
    sed -i 's/;opcache.revalidate_freq=.*/opcache.revalidate_freq=2/' /etc/php/8.2/apache2/php.ini && \
    sed -i 's/;opcache.fast_shutdown=.*/opcache.fast_shutdown=1/' /etc/php/8.2/apache2/php.ini && \
    sed -i 's/;opcache.enable_cli=.*/opcache.enable_cli=1/' /etc/php/8.2/apache2/php.ini && \
    sed -i 's/;opcache.enable=.*/opcache.enable=1/' /etc/php/8.2/apache2/php.ini && \
    sed -i 's/;date.timezone =/date.timezone = Asia\/Taipei/' /etc/php/8.2/cli/php.ini && \
    sed -i 's/;date.timezone =/date.timezone = Asia\/Taipei/' /etc/php/8.2/apache2/php.ini && \
    rsync -a /etc/apache2/ /backup/apache2/ && \
    rsync -a /etc/php/ /backup/php/

# 開放 80 號埠口以供 Apache 使用
EXPOSE 80

# 設定工作目錄
WORKDIR /var/www/html

# 容器啟動時執行的命令
ENTRYPOINT ["/entrypoint.sh"]
