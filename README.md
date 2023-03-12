<h1 align="center">
  <img width="575.618" height="273.777" src="./assets/logos/logotype.svg" alt="Jumar">
</h1>

Jumar is a heavily opinionated Elixir boilerplate repository. It contains a _ton_ of useful features and documentation explaining the how and why.

## Features

> **NOTE**: Jumar is currently a work in progress. Not all features are complete.

### Data Layer

- [ ] Cockroach DB usage via `ecto`
- [ ] Database multi tenant setup

### User Layer

- [ ] User authentication via `mix phx.gen.auth`
- [ ] User organizations
- [ ] User and organization permissions
- [ ] User notification preferences

### Event Layer

- [ ] Rabbitmq message publishing
- [ ] Rabbitmq message consuming with Broadway
- [ ] Unique CLI arg to start message consuming separately from web server

### Documentation

- [x] Code documentation via `ex_doc`
- [ ] Published documentation to GitHub pages

### Continuous Integration

- [x] Code formatting via `mix format`
- [ ] Code linting via `dialyzer`
- [ ] Code linting via `credo`
- [ ] Code linting via `boundary`
- [ ] Code testing via `exunit`
- [ ] Browser testing via `wallaby`
- [ ] Property testing via `stream_data`

### Continuous Deployment

- [ ] Continuous integration with GitHub actions
- [ ] Releasing via `release-please`
- [ ] Container building on PRs and releases
- [ ] Continuous deployment with GitHub actions to [Fly.io](https://fly.io)
