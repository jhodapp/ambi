# Ambi

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Running in a Docker container

To run ambi in a Docker container along with another one for Postgresql 11:

 * Build the web/DB containers: `docker-compose build`
 * Create the DB in the DB container: `docker-compose run web mix ecto.create`
 * Run the Ecto DB migrations inside the web container: `docker-compose run web mix ecto.migrate`
 * Run the application in the container: `docker-compose up`

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
