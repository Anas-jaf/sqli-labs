FROM ubuntu:14.04

RUN /bin/sh -c echo '#!/bin/sh' > /usr/sbin/policy-rc.d 	&& echo 'exit 101' >> /usr/sbin/policy-rc.d 	&& chmod +x /usr/sbin/policy-rc.d 		&& dpkg-divert --local --rename --add /sbin/initctl 	&& cp -a /usr/sbin/policy-rc.d /sbin/initctl 	&& sed -i 's/^exit.*/exit 0/' /sbin/initctl 		&& echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup 		&& echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean 	&& echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean 	&& echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean 		&& echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages 		&& echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes

RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list

CMD ["/bin/bash"]

LABEL name="Anas"  maintainer="ansas4565@gmail.com"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update ;   apt-get -y install supervisor git apache2 libapache2-mod-php5 mysql-server php5-mysql pwgen php-apc php5-mcrypt ;   echo "ServerName localhost" >> /etc/apache2/apache2.conf

ADD ./start-apache2.sh /start-apache2.sh

ADD ./start-mysqld.sh /start-mysqld.sh

ADD ./run.sh /run.sh

RUN chmod 755 /*.sh

ADD ./my.cnf /etc/mysql/conf.d/my.cnf

ADD ./supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf

ADD ./supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

RUN rm -rf /var/lib/mysql/*

RUN a2enmod rewrite

RUN rm -fr /var/www/html

RUN git clone https://github.com/Audi-1/sqli-labs /var/www/html/

ENV PHP_UPLOAD_MAX_FILESIZE=10M

ENV PHP_POST_MAX_SIZE=10M

VOLUME [/etc/mysql /var/lib/mysql]

EXPOSE 3306/tcp 80/tcp

CMD ["/run.sh"]