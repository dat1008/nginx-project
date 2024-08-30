FROM alpine:latest

RUN apk --no-cache add lighttpd

COPY ./html /var/www/localhost/htdocs
COPY ./lighttpd.conf /etc/lighttpd/lighttpd.conf

EXPOSE 80

CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]



