# Use Ruby 3.2 base image
FROM ruby:3.2

# Set default locale for the environment
ENV LC_ALL C.UTF-8
ENV LANG ko.UTF-8
ENV LANGUAGE ko.UTF-8

# Upgrade RubyGems to the latest version and install Bundler 2.5.x
RUN gem update --system && gem install bundler -v "~> 2.5"

# Set work directory
WORKDIR /usr/src/app

# Copy Gemfile, Gemfile.lock, and gemspec file
COPY Gemfile Gemfile.lock jekyll-text-theme.gemspec ./

# Install dependencies using Bundler
RUN bundle install

# Copy the rest of the application files
COPY . ./

# Expose port 4000
EXPOSE 4000

# Default command
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0"]
