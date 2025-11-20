FROM cockroachdb/cockroach:v25.4.0

COPY start-insecure-local.sh start-secure.sh /cockroach/

ENTRYPOINT ["/cockroach/start-secure.sh"]
