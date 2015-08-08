FROM debian
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -yq \
    wget \
    freetds-dev \
    libsqlite3-0
ENV DEB_FILE http://pgloader.io/files/pgloader_3.2.0+dfsg-1_amd64.deb
RUN wget -nv -O pgloader.deb $DEB_FILE \
    && dpkg -i pgloader.deb \
    && rm pgloader.deb
RUN mkdir /app
WORKDIR /app
COPY . /app/
ENTRYPOINT /app/entrypoint.sh
