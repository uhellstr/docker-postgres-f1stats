FROM fedora 

# Maintainer
# ----------
LABEL Maintainer="Ulf Hellstrom <oraminute@gmail.com>"

RUN dnf -y module enable postgresql:12

RUN dnf -y install \
    procps-ng \
    sudo \
    wget \
    curl \
    python3 \
    python3-pip \
    bash \
    vim \
    langpacks-en \ 
    glibc-all-langpacks \
    postgresql-server \
    postgresql-plpython3 \
    postgresql-libs \ 
    && mkdir /scripts

COPY ./scripts/* /scripts/

RUN pip3 install urllib3 \
    requests \
    &&  chown -R postgres:postgres /scripts/* \
    &&  chown -R postgres:postgres /var/lib/pgsql \
    &&  chown -R postgres:postgres /var/lib/pgsql/data
 
EXPOSE 5432

USER postgres

CMD ["/scripts/startpostgres"] 
