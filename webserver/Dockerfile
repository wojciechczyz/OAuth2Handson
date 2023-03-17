ARG IMAGE=containers.intersystems.com/intersystems/webgateway:2022.2.0.372.0
#ARG IMAGE=containers.intersystems.com/intersystems/webgateway:2023.1.0.207.0-linux-arm64v8
FROM $IMAGE

# apache: enable ssl
RUN a2enmod ssl
COPY default-ssl.conf /etc/apache2/sites-available/default-ssl.conf

WORKDIR /etc/apache2/sites-enabled
RUN ln -s ../sites-available/default-ssl.conf default-ssl.conf

# ssl certificate
WORKDIR /etc/ssl
COPY ssl-cert.pem /etc/ssl/certs/ssl-cert.pem
COPY ssl-cert.key /etc/ssl/private/ssl-cert.key