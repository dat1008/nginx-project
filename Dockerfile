FROM nginx:1.27.1-alpine

RUN adduser -D nonroot

COPY ./src /usr/share/nginx/html

RUN chown -R nonroot:nonroot /usr/share/nginx/html

USER nonroot

EXPOSE 80
