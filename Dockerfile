FROM httpd:alpine

COPY . /usr/local/apache2/htdocs/

RUN ls -lah /usr/local/apache2/htdocs

RUN chmod -R 755 /usr/local/apache2/htdocs
