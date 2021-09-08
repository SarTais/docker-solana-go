FROM ubuntu:focal

ARG SOLANA_ENDPOINT="https://api.devnet.solana.com"
ARG SOL_AMOUNT=10

# Timezone
ENV TZ=Europe/Kiev

# Base
RUN export LC_ALL=C.UTF-8 && \
    DEBIAN_FRONTEND=noninteractive && \
    rm /bin/sh && ln -s /bin/bash /bin/sh && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezon

# Common
RUN apt-get update && \
    apt-get install -y \
    apt-utils \
    automake \
    build-essential \
    software-properties-common \
    pkg-config \
    sudo \
    curl \
    wget \
    libssl-dev \
    libudev-dev

# Install Git
RUN add-apt-repository ppa:git-core/ppa && \
    apt-get update && \
    apt-get install -y git

# Install Golang
RUN wget https://dl.google.com/go/go1.16.4.linux-amd64.tar.gz && \
    tar -xvf go1.16.4.linux-amd64.tar.gz && \
    rm -rf go1.16.4.linux-amd64.tar.gz && \
    mv go /usr/local

ENV GOROOT /usr/local/go
ENV PATH $GOPATH/bin:$GOROOT/bin:$PATH

# Install Solana CLI devnet wallet
RUN sh -c "$(curl -sSfL https://release.solana.com/v1.7.11/install)"
ENV PATH="/root/.local/share/solana/install/active_release/bin:$PATH"

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install SPL Token CLI
RUN cargo install spl-token-cli

# Configure Solana Wallet

RUN solana config set --url $SOLANA_ENDPOINT && \
    solana-keygen new --no-bip39-passphrase && \
    solana airdrop $SOL_AMOUNT

WORKDIR /app