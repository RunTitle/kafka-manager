FROM openjdk:8
MAINTAINER Alex Hearn <ahearn@runtitle.com>

ENV SBT_VERSION 0.13.9
ENV SCALA_VERSION 2.12.4
ENV KAFKA_MANAGER_VERSION 1.3.3.15

RUN \
  curl -fsL http://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo 'export PATH=~/scala-$SCALA_VERSION/bin:$PATH' >> /root/.bashrc

RUN \
  curl -L -o sbt-$SBT_VERSION.deb https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install sbt && \
  sbt sbtVersion

COPY . /opt/app
WORKDIR /opt/app

# This command sometimes non-deterministically fails if there's a momentary issue with the Maven repo.
# Because this project apparently requires roughly 80% of all jars every built, it happens more regularly
# than you might expect.
RUN ./sbt clean dist

# Find the zip file at /opt/app/target/universal/kafka-manager-$KAFKA_MANAGER_VERSION.zip
RUN yes | unzip /opt/app/target/universal/kafka-manager-$KAFKA_MANAGER_VERSION.zip


ENTRYPOINT ["/opt/app/docker-entrypoint.sh"]
CMD ["web"]
