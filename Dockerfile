# Use an official Ruby image.
FROM ruby:3.2.2

# Install system dependencies.
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# Install bundler
RUN gem install bundler

# Create a non-root user
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o user
RUN useradd -u $UID -g user -o -s /bin/bash user

# Set the working directory
WORKDIR /usr/src/app

# Set environment variables for gem installation.
# This tells Ruby where to install gems and ensures executables are in the PATH.
ENV GEM_HOME /usr/src/app/vendor/bundle
ENV BUNDLE_PATH /usr/src/app/vendor/bundle
ENV PATH /usr/src/app/vendor/bundle/bin:$PATH

# Change ownership of the app directory to the non-root user.
# This must be done before switching user.
RUN chown -R user:user /usr/src/app

# Switch to the non-root user
USER user

# Copy the application files with the correct ownership.
# This is useful for caching, but the volume mount will be the primary source of truth.
COPY --chown=user:user . .

# Expose port 3001 to the Docker host.
EXPOSE 3001

# The main command to run when the container starts.
# This will be overridden by the command in docker-compose.yml, which is expected.
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3001"]
