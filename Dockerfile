FROM registry.access.redhat.com/ubi8/ubi AS build

RUN yum install -y \
  wget \
  unzip \
  libstdc++ \
  autoconf \
  automake \
  libtool \
  pkg-config \
  gcc \
  gcc-c++ \
  make \
  libjpeg-devel \
  libpng-devel \
  libtiff-devel \
  zlib-devel

RUN mkdir /build && \
    mkdir /ocr && \
    cd /build && \
    wget http://www.leptonica.org/source/leptonica-1.75.3.tar.gz && \
    wget https://github.com/tesseract-ocr/tesseract/archive/4.1.0.zip

RUN cd /build && \
    tar -xvf leptonica-1.75.3.tar.gz && \
    unzip 4.1.0.zip

RUN cd /build && \
    cd leptonica-1.75.3 && \
    ./autobuild && \
    ./configure --prefix=/ocr/ && \
    make && \
    make install

ENV PKG_CONFIG_PATH /ocr/lib/pkgconfig

RUN cd /build/tesseract-4.1.0 && \
    ./autogen.sh && \
    LIBLEPT_HEADERSDIR=/ocr/include ./configure --prefix=/ocr/ --with-extra-libraries=/ocr/lib && \
    make && \
    make install

FROM fedora:31 as fedora

RUN yum install -y postgresql

FROM registry.access.redhat.com/ubi8/ubi-minimal

RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

RUN microdnf install \
      postgresql-devel \
      nodejs \
      npm \
      ruby \
      gcc \
      gcc-c++ \
      ruby-devel \
      zlib-devel \
      redhat-rpm-config \
      tar \
      patch \
      make \
      git \
      wget \
      GraphicsMagick \
      python36 \
      python3-pip \
      python2

RUN npm install yarn -g

WORKDIR /corpusbuilder

COPY Gemfile Gemfile.lock ./

COPY . .

RUN gem install bundler -v 2.0.2

COPY --from=build /ocr /ocr
COPY --from=fedora /usr/bin/pg_dump /usr/bin/pg_dump
COPY --from=fedora /usr/bin/pg_restore /usr/bin/pg_restore

CMD ["./bin/rails server --port 8000"]
