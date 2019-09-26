FROM minidocks/tesseract:4-eng AS tesseract
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
      python3-pip

RUN npm install yarn -g

WORKDIR /corpusbuilder

COPY Gemfile Gemfile.lock ./

COPY . .

RUN gem install bundler -v 2.0.2

COPY --from=tesseract /usr/lib/libtesseract* /usr/lib/
COPY --from=tesseract /usr/lib/liblept* /usr/lib/
COPY --from=tesseract /usr/bin/tesseract /usr/bin/

CMD ["./bin/rails server --port 8000"]
