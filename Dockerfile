FROM ubuntu 24:04
ARG DEBIAN_FRONTEND=noninteractive
ENV PGUSER postgres
ENV PGPORT 5432
ENV PGDATABASE postgres
RUN apt-get update -qq && apt-get install -y postgresql-client
CMD ["sh", "docker/checkenv.sh", "run"]