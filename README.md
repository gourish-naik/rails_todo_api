# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Need Docker installed 

* clone the repo

* docker compose build
* docker compose up

* app will be running 

* * * * * * * * * 

* * * * *

Docker first approach Project Setup
===================================

Docker-First Rails API Setup Guide
----------------------------------

This document explains, step-by-step, how to set up a **Rails API-only application** using a **Docker-first approach**. That means we don't create the Rails app on the host system. Instead, we use Docker to generate and run everything inside containers. This gives us a consistent and reproducible development environment.

* * * * *

✅ Prerequisites
---------------

Ensure the following are installed on your system:

-   [Docker](https://docs.docker.com/get-docker/)

-   [Docker Compose](https://docs.docker.com/compose/)

* * * * *

🗂️ Initial Project Structure
-----------------------------

When you begin, your project folder should include only the Docker-related setup files. These are used to bootstrap the Rails API project **inside Docker**.

```
/your-rails-api-project/
├── .env.docker          # Environment variables for PostgreSQL container
├── database.yml         # Rails database configuration
├── Dockerfile           # Instructions for building the Rails container
├── docker-compose.yml   # Defines and connects services (Rails + PostgreSQL)
├── Gemfile              # Lists required Ruby gems
└── Gemfile.lock         # Initially empty, populated during Rails install

```

* * * * *

📦 1. `Gemfile`
---------------

**Purpose:** Defines your app's Ruby and gem dependencies.

```
# Gemfile
source "https://rubygems.org"

ruby "3.2.2" # Must match Ruby version in Dockerfile

gem "rails", "~> 7.1.3" # The Rails framework
gem "pg"                # PostgreSQL database adapter

# Add other optional API gems here:
# gem "rack-cors"
# gem "active_model_serializers"

```

* * * * *

📄 2. `Gemfile.lock`
--------------------

**Purpose:** Initially an empty file. It is used by Bundler to lock the gem versions after the first install.

```
# Create an empty Gemfile.lock file
touch Gemfile.lock

```

When you run `rails new` inside Docker, this file will be updated with the exact versions of the installed gems.

* * * * *

🐳 3. `Dockerfile`
------------------

**Purpose:** Defines the Docker image that will run your Rails API app.

```
# Dockerfile
FROM ruby:3.2.2                       # Base Ruby image
WORKDIR /usr/src/app                 # Set working directory inside container

# Install system-level dependencies needed for Rails and PostgreSQL
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# Install Bundler
RUN gem install bundler

# Copy Gem configuration files first to use Docker cache
COPY Gemfile Gemfile.lock ./

# Install Ruby gems
RUN bundle install

# Copy entire project into the container
COPY . .

# Expose port for Rails to run
EXPOSE 3001

# Default command to start Rails server in API mode
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3001"]

```

**Key Notes:**

-   The `bundle install` step uses the copied `Gemfile.lock` (even if it's empty) to set up gems.

-   Rails runs in API mode and listens on port `3001`.

* * * * *

🧩 4. `docker-compose.yml`
--------------------------

**Purpose:** Defines and connects all your services (Rails app and PostgreSQL database).

```
# docker-compose.yml
services:
  api:
    build: .                        # Build from Dockerfile
    volumes:
      - .:/usr/src/app              # Mount current project dir into container
    ports:
      - "3001:3001"                 # Map container's port 3001 to host
    depends_on:
      - pg                          # Start database container first
    environment:
      - DATABASE_URL=postgres://admin:root@pg:5432/rails_json_api

  pg:
    image: postgres:15.6
    restart: always
    ports:
      - "5454:5432"                 # Host port 5454 maps to PostgreSQL port 5432
    env_file:
      - .env.docker
    volumes:
      - rails_json_api-data:/var/lib/postgresql/data

volumes:
  rails_json_api-data:              # Persistent volume for PostgreSQL data

```

* * * * *

🔐 5. `.env.docker`
-------------------

**Purpose:** Holds environment variables used by the PostgreSQL container.

```
# .env.docker
POSTGRES_USER=admin
POSTGRES_PASSWORD=root
POSTGRES_DB=rails_json_api

```

This file is loaded by the `pg` service as defined in `docker-compose.yml`.

* * * * *

⚙️ 6. `database.yml`
--------------------

**Purpose:** Tells Rails how to connect to the database using the `DATABASE_URL` provided in Docker Compose.

```
# database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  url: <%= ENV["DATABASE_URL"] %>

development:
  <<: *default

production:
  <<: *default

```

* * * * *

🏗️ 7. Generate Rails API Inside Docker
---------------------------------------

Now, you're ready to **generate the actual Rails app inside the container**.

```
# Step 1: Build the Docker image
docker compose build

# Step 2: Create the Rails app inside the 'api' container
docker compose run --rm api rails new . --force --api --database=postgresql

```

**Explanation:**

-   `--rm`: Removes the temporary container after running.

-   `--force`: Overwrites files like Gemfile and Dockerfile (you already created them).

-   `--api`: Sets up Rails in API-only mode (no views, assets).

-   `--database=postgresql`: Preconfigures PostgreSQL support.

* * * * *

🔧 8. Post-Generation Configuration
-----------------------------------

After `rails new`, confirm the following files are correctly configured:

### `config/application.rb`

Ensure the app is in **API-only mode**:

```
# config/application.rb
module YourAppName
  class Application < Rails::Application
    # Other configs...
    config.api_only = true
  end
end

```

### `config/routes.rb`

Define your API endpoints:

```
# config/routes.rb
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :users # Example route
    end
  end
end

```

* * * * *

🗃️ 9. Set Up the Database
--------------------------

With the app generated, create and migrate your database.

```
# Create database as defined in database.yml
docker compose run --rm api rails db:create

# Run database migrations
docker compose run --rm api rails db:migrate

```

* * * * *

🚀 10. Run the Application
--------------------------

Now start your app and database together:

```
# Start the services (Rails API + PostgreSQL)
docker compose up

# Or to run in background
docker compose up -d

```

Your API should now be available at:

```
http://localhost:3001

```

* * * * *

✅ Summary
---------

You now have a Rails API-only app running **entirely inside Docker**, with PostgreSQL configured and Rails generated from inside the container. This approach ensures:

-   Environment consistency across developers

-   Easy onboarding and clean dependency isolation

-   Better reproducibility in CI/CD pipelines

* * * * *