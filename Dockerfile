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
    wget https://github.com/DanBloomberg/leptonica/archive/9e9a8aeb727b9f72ef7317ca4d5e4a6f1e637688.zip -O leptonica.zip && \
    wget https://github.com/tesseract-ocr/tesseract/archive/4.1.0.zip

RUN cd /build && \
    unzip leptonica.zip && \
    unzip 4.1.0.zip

RUN cd /build && \
    cd leptonica-9e9a8aeb727b9f72ef7317ca4d5e4a6f1e637688 && \
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
      python3-devel \
      python2 \
      which \
      ghostscript \
      fribidi \
      libtiff

RUN npm install yarn -g

WORKDIR /corpusbuilder

COPY Gemfile Gemfile.lock ./

RUN gem install bundler -v 2.0.2

RUN pip3 install kraken

COPY --from=build /ocr /ocr
COPY --from=fedora /usr/bin/pg_dump /usr/bin/pg_dump
COPY --from=fedora /usr/bin/pg_restore /usr/bin/pg_restore

RUN cd /ocr/share/tessdata && \
    wget \
      https://github.com/tesseract-ocr/tessdata_best/raw/master/eng.traineddata \
      https://github.com/tesseract-ocr/tessdata_best/raw/master/ara.traineddata

COPY . .

ENV PATH="/ocr/bin:${PATH}"

ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/ocr/lib"

CMD ["./bin/rails server --port 8000"]
