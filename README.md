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

### Database Layer

- ✅ [Cockroach DB](https://www.cockroachlabs.com/) usage via [`ecto`](https://hexdocs.pm/ecto/Ecto.html)
- 🟨 Database multi tenant setup
- ✅ Prefixed primary keys similar to Stripe (`usr_abc123`)

### Web Server Layer

- ✅ HTTP server with [`bandit`](https://github.com/mtrudel/bandit)

### User Layer

- ✅ User authentication via [`mix phx.gen.auth`](https://hexdocs.pm/phoenix/mix_phx_gen_auth.html)
- 🟨 User organizationse
- 🟨 User and organization permissions
- 🟨 User notification preferences

### Event Layer

- 🟨 [Rabbitmq](https://www.rabbitmq.com/) message publishing
- 🟨 [Rabbitmq](https://www.rabbitmq.com/) message consuming with [Broadway](https://elixir-broadway.org/)
- 🟨 Unique CLI arg to start message consuming separately from web server

### Documentation Generation

- ✅ Code documentation via [`ex_doc`](https://hexdocs.pm/ex_doc/readme.html)
- ✅ [Published documentation](https://jumar.btkostner.io) to [GitHub pages](https://pages.github.com/)

### Continuous Integration

- ✅ Code formatting via [`mix format`](https://hexdocs.pm/mix/main/Mix.Tasks.Format.html)
- ✅ [Tailwind](https://tailwindcss.com/) class ordering via [`tailwind_formatter`](https://github.com/100phlecs/tailwind_formatter)
- ✅ Code linting via [`dialyzer`](https://hexdocs.pm/dialyxir/readme.html)
- ✅ Code linting via [`credo`](https://hexdocs.pm/credo/overview.html)
- ✅ Code linting via `boundary`
- ✅ Linting for other file types (almost too much linting 🤯)
  - ✅ Linting GitHub actions via [`actionlint`](https://github.com/rhysd/actionlint)
  - ✅ Linting for insensitive and inconsiderate writing via [`alex`](https://github.com/get-alex/alex)
  - ✅ Linting CSS via [`stylelint`](https://stylelint.io/)
  - ✅ Linting `Dockerfile`s via [`hadolint`](https://github.com/hadolint/hadolint)
  - ✅ Linting Javascript via [`eslint`](https://eslint.org/) and [`standard`](https://standardjs.com/)
  - ✅ Linting Markdown via [`markdownlint`](https://github.com/DavidAnson/markdownlint)
  - ✅ Spell checking via [`misspell`](https://github.com/client9/misspell)
  - ✅ Linting shell scripts via [`shellcheck`](https://www.shellcheck.net/)
  - ✅ Linting shell scripts via [`shfmt`](https://github.com/mvdan/sh)
  - ✅ Linting YAML via [`yamllint`](https://github.com/adrienverge/yamllint)
- ✅ Code testing via [`exunit`](https://hexdocs.pm/ex_unit/ExUnit.html)
- 🟨 Browser testing via [`wallaby`](https://github.com/elixir-wallaby/wallaby)
- ✅ Property testing via [`stream_data`](https://github.com/whatyouhide/stream_data)

### Continuous Deployment

- 🟨 Continuous integration with GitHub actions
- ✅ Releasing via [`release-please`](https://github.com/googleapis/release-please)
- 🟨 Container building on PRs and releases
- 🟨 Continuous deployment with GitHub actions to [Fly.io](https://fly.io)

## Documentation

Documentation for this project is hosted at <https://jumar.btkostner.io>. It is built and published on every merge to the `main` branch.
