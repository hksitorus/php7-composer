FROM php:7.1.15-fpm-jessie

RUN apt-get update -y && apt-get install -y nano openssl unixodbc zip unzip git wget libfreetype6-dev libjpeg62-turbo-dev libpng-dev libldb-dev libldap2-dev unixodbc-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN cd /tmp/ && wget https://github.com/Microsoft/msphpsql/raw/master/ODBC%2017%20binaries%20preview/Debian%208/msodbcsql_17.0.0.5-1_amd64.deb \
    && wget https://github.com/Microsoft/msphpsql/raw/master/ODBC%2017%20binaries%20preview/Debian%208/mssql-tools_17.0.0.5-1_amd64.deb
RUN yes | ACCEPT_EULA=Y dpkg -i /tmp/msodbcsql_17.0.0.5-1_amd64.deb
RUN yes | ACCEPT_EULA=Y dpkg -i /tmp/mssql-tools_17.0.0.5-1_amd64.deb

ADD oracle/instantclient-basic-linux.x64-11.2.0.4.0.zip /tmp/instantclient-basic-linux.x64-11.2.0.4.0.zip
ADD oracle/instantclient-sdk-linux.x64-11.2.0.4.0.zip /tmp/instantclient-sdk-linux.x64-11.2.0.4.0.zip
ADD oracle/instantclient-sqlplus-linux.x64-11.2.0.4.0.zip /tmp/instantclient-sqlplus-linux.x64-11.2.0.4.0.zip

RUN unzip /tmp/instantclient-basic-linux.x64-11.2.0.4.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-11.2.0.4.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sqlplus-linux.x64-11.2.0.4.0.zip -d /usr/local/
RUN ln -s /usr/local/instantclient_11_2 /usr/local/instantclient
RUN ln -s /usr/local/instantclient/libclntsh.so.11.1 /usr/local/instantclient/libclntsh.so
RUN ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus

RUN docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient \
    && docker-php-ext-install oci8

RUN pecl channel-update pecl.php.net
RUN docker-php-ext-install -j$(nproc) gd pdo mbstring ldap zip
RUN pecl install sqlsrv pdo_sqlsrv
RUN docker-php-ext-enable sqlsrv pdo_sqlsrv

RUN cd /tmp && git clone https://github.com/git-ftp/git-ftp.git && cd git-ftp \
    && tag="$(git tag | grep '^[0-9]*\.[0-9]*\.[0-9]*$' | tail -1)" \
    && git checkout "$tag" \
    && mv git-ftp /usr/local/bin && chmod +x /usr/local/bin

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/cache/oracle-jdk8-installer


# Define default command.
CMD ["bash"]