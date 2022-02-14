FROM crystallang/crystal:1.2.2

ARG OVERMIND_VERSION=v2.2.2
ENV OVERMIND_VERSION=${OVERMIND_VERSION}

ARG USERNAME=lucky_app_user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV USERNAME=$USERNAME
ENV USER_UID=$USER_UID
ENV USER_GID=$USER_GID

ARG ASDF_VERSION=v0.9.0
ENV ASDF_VERSION=${ASDF_VERSION}

ARG NODE_VERSION=17.3.0
ENV NODE_VERSION=${NODE_VERSION}

ARG YARN_VERSION=1.22.17
ENV YARN_VERSION=${YARN_VERSION}

ARG LUCKY_VERSION=v0.29.0
ENV LUCKY_VERSION=${LUCKY_VERSION}

# install base dependencies
RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y apt-utils dialog

# Overmind
RUN apt-get install -y tmux wget && \
  cd /tmp && \
  wget https://github.com/DarthSim/overmind/releases/download/${OVERMIND_VERSION}/overmind-${OVERMIND_VERSION}-linux-amd64.gz && \
  gunzip -d overmind-${OVERMIND_VERSION}-linux-amd64.gz && \
  chmod a+x overmind-${OVERMIND_VERSION}-linux-amd64 && \
  mv overmind-${OVERMIND_VERSION}-linux-amd64 /usr/local/bin/overmind && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install chromedriver
RUN apt-get update && apt-get upgrade -y && \
  apt-get install -y chromium-chromedriver && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

# Copy minimum of app for now
COPY ./README.md /app

# Install asdf dependencies
RUN apt update && apt upgrade -y && \
    apt install -y curl git

# Install Node dependencies
RUN apt-get install -y dirmngr gpg curl gawk

# Cleanup re apt:
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create the user
RUN adduser --shell /bin/bash --home /home/$USERNAME --disabled-password $USERNAME

# Add sudo support
RUN apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

ENV PATH="${PATH}:/home/$USERNAME/.asdf/shims:/home/$USERNAME/.asdf/bin"
ENV NODEJS_CHECK_SIGNATURES=no

# Install postgres client
# RUN apt-get update && apt-get install -y postgresql postgresql-contrib
RUN apt-get update && apt-get install -y postgresql-client-12 postgresql-contrib

# Install Lucky system dependencies, as per https://luckyframework.org/guides/getting-started/installing#ubuntu
RUN apt-get install -y libc6-dev libevent-dev libpcre2-dev libpcre3-dev libpng-dev libssl-dev libyaml-dev zlib1g-dev

# Install Lucky cli
RUN mkdir -p /lucky && cd /lucky && \
    git clone https://github.com/luckyframework/lucky_cli && \
    cd lucky_cli && \
    git checkout v0.29.0 && \
    shards install && \
    crystal build src/lucky.cr && \
    mv lucky /usr/local/bin && \
    lucky -v

WORKDIR /app

RUN chown -R $USER_UID:$USER_GID /app

USER $USERNAME

RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git $HOME/.asdf && \
    echo '. $HOME/.asdf/asdf.sh' >> $HOME/.bashrc && \
    echo '. $HOME/.asdf/asdf.sh' >> $HOME/.profile

RUN asdf plugin-add nodejs
RUN asdf install nodejs $NODE_VERSION
RUN asdf global nodejs $NODE_VERSION

RUN asdf plugin-add yarn
RUN asdf install yarn $YARN_VERSION
RUN asdf global yarn $YARN_VERSION

# With Ubuntu 18.04, this works. With alpine, this fails with the error:
# /$USERNAME/.asdf/lib/commands/command-exec.bash: line 28: /$USERNAME/.asdf/installs/nodejs/17.3.0/bin/node: No such file or directory
# STDERR: The command '/bin/sh -c node --version' returned a non-zero code: 127
RUN node --version
RUN npm -v

# Set the default user.
USER $USERNAME

# SHELL ["bash", "-lc"]

ENV PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"



# Copy rest of app for now
COPY . /app

EXPOSE 3001
