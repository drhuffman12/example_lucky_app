# FROM crystallang/crystal:1.0.0
FROM crystallang/crystal:1.2.2
# WORKDIR /data
# WORKDIR /app

# ARG CRYSTAL_VERSION=1.0.0
# ENV CRYSTAL_VERSION=${CRYSTAL_VERSION}

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

ARG LUCKY_VERSION=v0.29.0
ENV LUCKY_VERSION=${LUCKY_VERSION}

# install base dependencies
RUN apt-get update && apt-get upgrade -y
# && \

RUN apt-get install -y apt-utils dialog
# && \

# RUN apt-get install -y lsb-core curl libgconf-2-4 curl libreadline-dev gnupg2 wget ca-certificates vim libicu66 sysstat
  # # postgres 11 installation
  # # wget -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
  # sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
  # curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
  # # echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" | tee /etc/apt/sources.list.d/postgres.list && \
  # apt-get update && apt-get upgrade -y && \
  # # apt-get install -y gnupg && \
  # # apt-get install -y postgresql-11 && \
  # sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
  # apt -y update && \
  # apt-get autoremove && \
  # apt-cache search postgresql | grep postgresql && \
  # # wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \ 
  # apt-get install -y postgresql postgresql-contrib && \

  # postgres latest installation as per https://www.postgresql.org/download/linux/ubuntu/
# RUN apt-get -y install postgresql-12
# RUN apt-get -y install postgresql-client-12

# RUN  sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
#   wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
#   apt-get update && \
#   apt-get -y install postgresql

# RUN postgres psql -c "SELECT version();" && \
#   systemctl status postgresql.service

# Overmind
RUN apt-get install -y tmux wget && \
  cd /tmp && \
  wget https://github.com/DarthSim/overmind/releases/download/${OVERMIND_VERSION}/overmind-${OVERMIND_VERSION}-linux-amd64.gz && \
  gunzip -d overmind-${OVERMIND_VERSION}-linux-amd64.gz && \
  chmod a+x overmind-${OVERMIND_VERSION}-linux-amd64 && \
  mv overmind-${OVERMIND_VERSION}-linux-amd64 /usr/local/bin/overmind && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# # Lucky system dependencies, as per https://luckyframework.org/guides/getting-started/installing#ubuntu
# RUN apt-get install -y libc6-dev libevent-dev libpcre2-dev libpcre3-dev libpng-dev libssl-dev libyaml-dev zlib1g-dev

# chromedriver
RUN apt-get update && apt-get upgrade -y && \
  apt-get install -y chromium-chromedriver && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app
# Copy minimum of app for now
COPY ./README.md /app
# COPY ./shard.yml /app

# # RUN script/misc_setup
# RUN script/setup

# nodejs npm Node.js
# Install asdf dependencies
RUN apt update && apt upgrade -y && \
    apt install -y curl git

# Install Node dependencies
RUN apt-get install -y dirmngr gpg curl gawk

# Cleanup re apt:
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# # Create the user
# RUN groupadd --gid $USER_GID $USERNAME \
#     && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME
# # Add sudo support
# RUN apt-get update \
#     && apt-get install -y sudo \
#     && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
#     && chmod 0440 /etc/sudoers.d/$USERNAME

# # WORKDIR /myapp
# RUN chown -R $USER_UID:$USER_GID /app

RUN adduser --shell /bin/bash --home /lucky_app_user --disabled-password lucky_app_user

ENV PATH="${PATH}:/lucky_app_user/.asdf/shims:/lucky_app_user/.asdf/bin"
ENV NODEJS_CHECK_SIGNATURES=no

WORKDIR /app
# WORKDIR /myapp
RUN chown -R $USER_UID:$USER_GID /app

USER lucky_app_user

RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git $HOME/.asdf && \
    echo '. $HOME/.asdf/asdf.sh' >> $HOME/.bashrc && \
    echo '. $HOME/.asdf/asdf.sh' >> $HOME/.profile

RUN asdf plugin-add nodejs
RUN asdf install nodejs latest
RUN asdf global nodejs latest

# With Ubuntu 18.04, this works. With alpine, this fails with the error:
# /lucky_app_user/.asdf/lib/commands/command-exec.bash: line 28: /lucky_app_user/.asdf/installs/nodejs/17.3.0/bin/node: No such file or directory
# STDERR: The command '/bin/sh -c node --version' returned a non-zero code: 127
RUN node --version
RUN npm -v

# Set the default user.
USER $USERNAME

# SHELL ["bash", "-lc"]

ENV PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"

# # Install asdf
# RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${ASDF_VERSION} && \
#     touch ~/.bashrc && \
#     echo ". ~/.asdf/asdf.sh" >> ~/.bashrc && \
#     . ~/.bashrc && \
#     asdf --version

#     #  && \
#     # . ~/.bashrc
#     # echo ". ~/.asdf/completions/asdf.bash" >> ~/.profile && \

# RUN . ~/.bashrc
# RUN whereis asdf
# RUN asdf
# RUN which asdf
# RUN bash -c "which asdf"
# RUN bash -c "whereis asdf"

# # Install node js
# RUN asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git && \
#     $HOME/.asdf/plugins/nodejs/bin/import-release-team-keyring && \
#     asdf install nodejs ${NODE_VERSION} && \
#     asdf global nodejs ${NODE_VERSION} && \
#     rm -rf  /tmp/*


# # RUN bash -c "source ${HOME}/.bashrc"

# RUN bash -c "source ~/.bashrc" && \
#     ~/.asdf/bin/asdf info
#     # asdf info

# Install Node
    # asdf install nodejs latest

# RUN bash -c "source ~/.bashrc"
# # && \
# RUN bash -c "source ~/.bashrc && ~/.asdf/bin/asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git"
# # && \
# RUN bash -c "source ~/.bashrc && ~/.asdf/bin/asdf install nodejs ${NODE_VERSION}"
# # && \
# RUN bash -c "echo '${NODE_VERSION}' > .tool-versions"
# # && \

# # RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
# #   apt-get update && apt-get upgrade -y && \
# #   apt-get install -y nodejs && \
# #   rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# RUN npm install --global yarn

# # # Lucky cli
# # RUN git clone https://github.com/luckyframework/lucky_cli --branch ${LUCKY_VERSION} --depth 1 /usr/local/lucky_cli && \
# #   cd /usr/local/lucky_cli && \
# #   shards install && \
# #   crystal build src/lucky.cr -o /usr/local/bin/lucky

# Copy rest of app for now
COPY . /app

EXPOSE 3001
