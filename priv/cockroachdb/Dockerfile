FROM cockroachdb/cockroach:v24.3.18

COPY start-insecure-local.sh start-secure.sh /cockroach/

ENTRYPOINT ["/cockroach/start-secure.sh"]
