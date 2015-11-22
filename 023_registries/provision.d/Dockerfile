FROM debian:jessie

ADD https://get.docker.com/builds/Linux/x86_64/docker-latest /usr/bin/docker
RUN chmod +x /usr/bin/docker \
  && apt-get update \
  && apt-get install -y \
  tree \
  vim \
  git \
  ca-certificates \
  --no-install-recommends

WORKDIR /root
RUN git clone -b trust-sandbox https://github.com/docker/notary.git
RUN cp /root/notary/fixtures/root-ca.crt /usr/local/share/ca-certificates/root-ca.crt
RUN update-ca-certificates

ENTRYPOINT ["bash"]
