FROM nginx:1.27.1-alpine

COPY ./src /usr/share/nginx/html

RUN addgroup -S nonroot \
    && adduser -S nonroot -G nonroot

USER nonroot

CMD ["id"]