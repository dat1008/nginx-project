FROM lighttpd:alpine

COPY . /var/www/localhost/htdocs/

RUN chmod -R 755 /var/www/localhost/htdocs

EXPOSE 80

CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]


