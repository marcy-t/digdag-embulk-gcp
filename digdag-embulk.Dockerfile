FROM openjdk:8-alpine

# install curl
RUN apk --update add --no-cache curl && \
    apk --update add tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apk del tzdata && \
    rm -rf /var/cache/apk/*s

# install embulk
RUN curl -o /bin/embulk --create-dirs -L "http://dl.embulk.org/embulk-latest.jar" && chmod +x /bin/embulk

# install embulk plugin
RUN apk add --no-cache libc6-compat \
  && embulk gem install embulk-output-command \
  && embulk gem install embulk-output-gcs \
  && embulk gem install embulk-output-bigquery \
  && embulk gem install embulk-input-postgresql \ 
  && embulk gem install embulk-input-mysql

# install digdag
RUN curl -o /usr/local/bin/digdag --create-dirs -L "https://dl.digdag.io/digdag-latest" && \
    chmod +x /usr/local/bin/digdag

RUN mkdir /work

COPY mysql-to-bigquery.yml /work/
COPY run.dig /work/
COPY retry.dig /work/
COPY table.json /work/
COPY startup.sh /work/

WORKDIR /work
 
CMD ["java", "-jar", "/usr/local/bin/digdag", "scheduler"]
