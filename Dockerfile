FROM caddy:alpine

COPY . /usr/share/caddy

RUN ls -lah /usr/share/caddy

RUN chmod -R 755 /usr/share/caddy
