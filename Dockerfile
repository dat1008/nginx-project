FROM nginx:alpine

COPY . /usr/share/nginx/html

RUN ls -lah /usr/share/nginx/html

RUN chmod -R 755 /usr/share/nginx/html
