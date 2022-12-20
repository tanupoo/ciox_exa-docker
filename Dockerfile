# NOTE: use build.sh instead of docker build.
#     e.g. build.sh --build-arg VER=0.6
FROM arm64v8/python:3.9-slim-bullseye

ARG VER
WORKDIR /opt/ciox
ADD build/ciox_exa-${VER}.tgz /opt/ciox
ADD build/slmpclient.tgz /opt/ciox/ciox_exa-${VER}
RUN ln -s /opt/ciox/ciox_exa-${VER} /opt/ciox/ciox_exa
WORKDIR /opt/ciox/ciox_exa
RUN ln -s PySLMPClient-0.0.1/pyslmpclient pyslmpclient
RUN pip install -r reqs.txt

CMD [ "/bin/sh" ]
