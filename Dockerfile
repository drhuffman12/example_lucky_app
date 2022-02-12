# FROM crystallang/crystal:1.0.0
FROM crystallang/crystal:1.2.2
# WORKDIR /data
WORKDIR /app

# ARG CRYSTAL_VERSION=1.0.0
# ENV CRYSTAL_VERSION=${CRYSTAL_VERSION}

ARG LUCKY_VERSION=v0.29.0
ENV LUCKY_VERSION=${LUCKY_VERSION}

ARG OVERMIND_VERSION=v2.2.2
ENV OVERMIND_VERSION=${OVERMIND_VERSION}

ARG USERNAME=lucky_app_user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV USERNAME=$USERNAME
ENV USER_UID=$USER_UID
ENV USER_GID=$USER_GID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # Add sudo support.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# install base dependencies
RUN apt-get update && apt-get upgrade -y && \
  apt-get install -y apt-utils dialog && \
  apt-get install -y lsb-core curl libgconf-2-4 curl libreadline-dev gnupg2 wget ca-certificates vim libicu66 sysstat

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
RUN apt-get -y install postgresql-client-12

# RUN  sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
#   wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
#   apt-get update && \
#   apt-get -y install postgresql

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# RUN postgres psql -c "SELECT version();" && \
#   systemctl status postgresql.service

# nodejs npm Node.js
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
  apt-get update && apt-get upgrade -y && \
  apt-get install -y nodejs && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN npm install --global yarn

# Overmind
RUN apt-get update && apt-get upgrade -y && \
  apt-get install -y tmux wget && \
  cd /tmp && \
  wget https://github.com/DarthSim/overmind/releases/download/${OVERMIND_VERSION}/overmind-${OVERMIND_VERSION}-linux-amd64.gz && \
  gunzip -d overmind-${OVERMIND_VERSION}-linux-amd64.gz && \
  chmod a+x overmind-${OVERMIND_VERSION}-linux-amd64 && \
  mv overmind-${OVERMIND_VERSION}-linux-amd64 /usr/local/bin/overmind && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Lucky cli
RUN git clone https://github.com/luckyframework/lucky_cli --branch ${LUCKY_VERSION} --depth 1 /usr/local/lucky_cli && \
  cd /usr/local/lucky_cli && \
  shards install && \
  crystal build src/lucky.cr -o /usr/local/bin/lucky

# chromedriver
RUN apt-get update && apt-get upgrade -y && \
  apt-get install -y chromium-chromedriver && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . /app

RUN script/misc_setup

# WORKDIR /myapp
RUN chown -R $USER_UID:$USER_GID /app

# Set the default user.
USER $USERNAME

EXPOSE 3001
