FROM centos:8

RUN dnf -y install epel-release \
    sudo \
    wget \
    curl \
    python3 \
    bash \
    vim \
    langpacks-en \ 
    glibc-all-langpacks

RUN dnf -y module enable postgresql:12
RUN dnf -y install postgresql-server \
    postgresql-plpython3 \
    postgresql-libs 

RUN pip3 install urllib3 \
    requests \
    && mkdir scripts

COPY ./scripts/* /scripts 

EXPOSE 5432

USER root

RUN chown -R postgres:postgres /scripts/*

USER postgres

CMD ["/scripts/startpostgres"] 
