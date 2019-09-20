FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
ENV BUNDLE_PATH=/bundle
ENV BUNDLE_BIN=/bundle/bin
ENV GEM_HOME=/bundle

RUN apt-get update && \
    apt-get install -y \
      software-properties-common \
      curl && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y \
      git \
      build-essential \
      libssl-dev \
      libreadline-dev \
      zlib1g-dev \
      tzdata \
      nodejs \
      yarn \
      postgresql-client \
      postgresql-server-dev-10 \
      python3.6 \
      python3-pip \
      tesseract-ocr && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install kraken

ENV HOME /home/corpusbuilder
ENV PATH $HOME/.rbenv/shims:$HOME/.rbenv/bin:$HOME/.rbenv/plugins/ruby-build/bin:$PATH

RUN groupadd -r corpusbuilder && \
    useradd -u 1000 -s /bin/bash -g corpusbuilder -g sudo -d /home/corpusbuilder corpusbuilder

WORKDIR /home/corpusbuilder/deployment

COPY Gemfile Gemfile.lock ./
COPY . .

RUN mkdir /home/corpusbuilder/.tessdata && \
    cp -R /usr/share/tesseract-ocr/4.00/tessdata/* /home/corpusbuilder/.tessdata

ENV TESSDATA_PREFIX /home/corpusbuilder/.tessdata
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

RUN mkdir /bundle && \
    chown -R corpusbuilder:corpusbuilder /home/corpusbuilder && \
    chown -R corpusbuilder:corpusbuilder /bundle

RUN apt-get update && apt-get install -y ruby-full && apt-get clean && rm -rf /var/lib/apt/lists/*

USER corpusbuilder

CMD ["/home/corpusbuilder/deployment/bin/app_ctl", "--init", "--migrate", "--run"]
