FROM cockroachdb/cockroach:v22.2.6

ADD start-insecure-local.sh start-secure.sh /cockroach/

ENTRYPOINT ["/cockroach/start-secure.sh"]
