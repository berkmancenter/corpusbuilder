FROM ruby:2.3.1

RUN mkdir -p /corpus_builder
WORKDIR /corpus_builder

COPY Gemfile Gemfile.lock ./
COPY . ./corpusbuilder/

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
  apt-get install nodejs && \
  npm -g install yarn && \
  gem install bundler

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-p", "3000" "-b", "0.0.0.0"]
