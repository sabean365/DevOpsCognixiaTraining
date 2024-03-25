FROM ubuntu:24.04
ARG DEBIAN_FRONTEND=noninteractive
ENV PGUSER postgres
ENV PGPORT 5432
ENV PGDATABASE postgres
RUN apt-get update && apt-get install -y postgresql-client
COPY startup.sh .
CMD ["sh","startup.sh"]