# Development

To get started with development on Jumar, you'll need two things:

- A working `elixir` install where you can run `mix deps.get` successfully
- A working `docker` and `docker compose` setup

Once you have those two things, you can start all of the Jumar dependencies via `docker compose up`. This will start the database (Cockroach DB), the message broker (RabbitMQ), the web browsers used for automated tests, as well as a couple of tools for observability. All of these should be setup and work out of the box without any further setup.

After the dependencies are up, you can interact with the Jumar Elixir project like most others. First run `mix setup` to download the dependencies, run database migrations, and install tools needed for the asset pipeline. Finally run `mix phx.server` to start up the web server.

## Ports and Debugging

- `8080` loads the Cockroach DB interface. You can log in with username `jumar` and password `jumar`.
