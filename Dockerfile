FROM traefik:v2.5

COPY traefik.yml /etc/traefik/traefik.yml

EXPOSE 80 443

ENTRYPOINT ["traefik"]
CMD ["--configFile=/etc/traefik/traefik.yml"]

