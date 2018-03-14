FROM php:7.1.15-fpm-jessie

RUN apt-get update -y && apt-get install -y openssl git-ftp unixodbc zip unzip git wget libfreetype6-dev libjpeg62-turbo-dev libpng-dev libldb-dev libldap2-dev unixodbc-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN cd /tmp/ && wget https://github.com/Microsoft/msphpsql/raw/master/ODBC%2017%20binaries%20preview/Debian%208/msodbcsql_17.0.0.5-1_amd64.deb \
    && wget https://github.com/Microsoft/msphpsql/raw/master/ODBC%2017%20binaries%20preview/Debian%208/mssql-tools_17.0.0.5-1_amd64.deb
RUN yes | ACCEPT_EULA=Y dpkg -i /tmp/msodbcsql_17.0.0.5-1_amd64.deb
RUN yes | ACCEPT_EULA=Y dpkg -i /tmp/mssql-tools_17.0.0.5-1_amd64.deb
RUN pecl channel-update pecl.php.net
RUN docker-php-ext-install -j$(nproc) gd pdo mbstring ldap
RUN pecl install sqlsrv pdo_sqlsrv

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/cache/oracle-jdk8-installer


# Define default command.
CMD ["bash"]