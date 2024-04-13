FROM cockroachdb/cockroach:v23.2.4

COPY start-insecure-local.sh start-secure.sh /cockroach/

ENTRYPOINT ["/cockroach/start-secure.sh"]
