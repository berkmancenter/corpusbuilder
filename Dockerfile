FROM ruby:2.3.1

RUN mkdir -p /corpus_builder
WORKDIR /corpus_builder

COPY Gemfile Gemfile.lock ./
COPY . ./

RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get install nodejs
RUN npm -g install yarn
RUN gem install bundler && bundle install

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-p", "3000" "-b", "0.0.0.0"]
