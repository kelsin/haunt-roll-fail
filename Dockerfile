ARG sbt=sbtscala/scala-sbt:eclipse-temurin-17.0.13_11_1.10.7_2.13.15

FROM $sbt AS base

ENV JAVA_OPTS="-Xmx2g -Xss4M -XX:+UseG1GC"
RUN mkdir -p /hrf
WORKDIR /hrf

FROM base AS js

COPY scala-js-dom-reduced /hrf/scala-js-dom-reduced/
WORKDIR /hrf/scala-js-dom-reduced/
RUN sbt publishLocal

COPY haunt-roll-fail /hrf/haunt-roll-fail/
WORKDIR /hrf/haunt-roll-fail/
RUN sbt fullLinkJS

FROM base AS assets

ADD assets.tar.gz /
WORKDIR /assets

COPY haunt-roll-fail/index.html /assets/
COPY --from=js /hrf/haunt-roll-fail/target/scala-2.13/hrf-opt/main.js /assets/main.js

FROM base AS app

COPY good-game /hrf/good-game/
WORKDIR /hrf/good-game/
RUN sbt assembly

FROM $sbt AS hrf
ARG URL=https://hrf.kels.in

RUN mkdir -p /db
RUN mkdir -p /assets

COPY --from=assets /assets /assets/
COPY --from=app ["/hrf/good-game/target/scala-2.13/HRF Good Game-assembly-17.0.jar", "/hrf.jar"]
COPY start.sh /

VOLUME /db
ENV HRF_URL=${URL}
EXPOSE $PORT

RUN java -jar /hrf.jar create /db/hrf /assets ${URL} ${URL}/hrf/ 7070
CMD ["/start.sh"]
