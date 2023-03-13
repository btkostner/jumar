<h1 align="center">
  Jumar
</h1>

<p align="center">
  <img width="575.618" height="273.777" src="./assets/logos/logotype.svg" alt="Jumar">
</p>

Jumar is a heavily opinionated Elixir boilerplate repository. It contains a _ton_ of useful features and documentation explaining the how and why.

One of the goals of this project is to bookmark some good decisions I've learned over the years working in this space. I don't want to say this is "best practices" because truth be told, those change wildly based on the project's context. With that said, this project aims to start on the right foot and document the "why this way" decisions made in the process.

## Features

Features marked with ✅ should be feature complete. Anything with 🟨 is a planned feature that is not yet complete.

<blockquote class="neutral">
  <h4 class="neutral"><strong>Note</strong></h4>

  <p>Jumar is currently a work in progress. Not all features are complete. If you have an idea or request, please open up a <a href="https://github.com/btkostner/jumar/discussions">GitHub discussion</a>.</p>
</blockquote>

### Data Layer

- 🟨 Cockroach DB usage via `ecto`
- 🟨 Database multi tenant setup

### User Layer

- 🟨 User authentication via `mix phx.gen.auth`
- 🟨 User organizations
- 🟨 User and organization permissions
- 🟨 User notification preferences

### Event Layer

- 🟨 Rabbitmq message publishing
- 🟨 Rabbitmq message consuming with Broadway
- 🟨 Unique CLI arg to start message consuming separately from web server

### Documentation Generation

- ✅ Code documentation via `ex_doc`
- ✅ Published documentation to GitHub pages

### Continuous Integration

- ✅ Code formatting via `mix format`
- 🟨 Code linting via `dialyzer`
- 🟨 Code linting via `credo`
- 🟨 Code linting via `boundary`
- 🟨 Code testing via `exunit`
- 🟨 Browser testing via `wallaby`
- 🟨 Property testing via `stream_data`

### Continuous Deployment

- 🟨 Continuous integration with GitHub actions
- ✅ Releasing via `release-please`
- 🟨 Container building on PRs and releases
- 🟨 Continuous deployment with GitHub actions to [Fly.io](https://fly.io)

## Documentation

Documentation for this project is hosted at <https://jumar.btkostner.io>. It is built and published on every merge to the `main` branch.
