 ARG IMAGE=containers.intersystems.com/intersystems/iris-community:2023.1.0.207.0
#ARG IMAGE=containers.intersystems.com/intersystems/iris-community:2023.1.0.207.0-linux-arm64v8
FROM $IMAGE

USER root

# change ownership
RUN mkdir -p /opt/irisapp
RUN chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp
WORKDIR /opt/irisapp

USER ${ISC_PACKAGE_MGRUSER}

# copy source
COPY iris.script iris.script
COPY src src
COPY install install

# run iris.script
RUN iris start IRIS \
    && iris session IRIS < /opt/irisapp/iris.script \
    && iris stop IRIS quietly