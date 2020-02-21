FROM opensuse/leap

RUN zypper -n in jq wget curl tar gzip which zip aws-cli git
RUN curl -L https://git.io/get_helm.sh | bash
RUN wget https://github.com/mikefarah/yq/releases/download/2.4.0/yq_linux_amd64 -O /usr/local/bin/yq && chmod +x /usr/local/bin/yq

ADD assets/ /opt/resource/
RUN chmod +x /opt/resource/{check,in,out}
