FROM cockroachdb/cockroach:v23.1.11

COPY start-insecure-local.sh start-secure.sh /cockroach/

ENTRYPOINT ["/cockroach/start-secure.sh"]
