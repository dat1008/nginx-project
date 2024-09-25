FROM nginx:1.27.1-alpine

RUN addgroup -S nonroot \
    && adduser -S nonroot -G nonroot

USER nonroot

COPY ./src /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
