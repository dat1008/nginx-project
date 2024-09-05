FROM nginx:alpine

RUN mkdir -p /usr/share/nginx/html

COPY . /usr/share/nginx/html

RUN ls -lah /usr/share/nginx/html

RUN chmod -R 755 /usr/share/nginx/html
