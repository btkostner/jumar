# Documentation

[ExDoc][ex_doc] is the defacto documentation generation for Elixir. It can read code comments, type specs, and Markdown files and present them all in a nice site or EPUB file.In fact, you're reading an [`ex_doc`][ex_doc] site right now! This summary comes from a [hand written Markdown file in the repository][this].

Like most other projects, the code is only half the story. For a well maintained project, it's important to keep design and architecture decisions documented for reference later on. I generally like to include this as close to the code as possible. While things like Atlassian Confluence, or the notes app on your computer _work_, they don't _excel_ at it. They can quickly get out of date with reality, and it's a pain to learn _yet another_ tool. That's why I prefer using [ExDoc][ex_doc] or GitHub.

To make [ExDoc][ex_doc] usage as easy as possible, I build the documentation as part of the CI pipeline (to ensure it builds correctly), as well as publish it to GitHub pages on merge. This makes it easily accessible to read and link to, without having to setup another hosted project. If you work at a large company with GitHub enterprise, you can even use private GitHub pages and avoid dealing with authentication.

## Configuration

Configuration is done in the [`mix.exs`][config] file `docs/0` section. This is pretty standard, though there are some unique differences this project has.

- The `assets` option is set to `"docs/assets"`. This folder holds images specifically for documentation.
- The `canonical` option is set for better SEO.
- `extras` and `groups_for_extras` is set so we have a more organized sidebar for our custom Markdown files.
- `logo` is set so we have a nice logo in the upper left corner. Secondly, we use an SVG that uses a CSS color variable.
- `main` points to the readme so it matches the same thing you see when you view the project on GitHub.
- `skip_undefined_reference_warnings_on` avoids issues with our dynamically generated `CHANGELOG.md` file.
- `source_ref` is set to `main`, so any time you click the `</>` button in the upper right corner, you get taken to the current `main` branch. This is because we publish documentation on merge, and not on every release. Note how the version in the upper left still references the latest version.

## FAQ

### What's with the HTML in Markdown?

There are a couple of places where I use HTML in my Markdown files. While this is perfectly acceptable Markdown, it is a little weird. Why use Markdown at all? Well, there are two main places I use it.

The first one is in the [`README.md`][readme] head. I use HTML here to make the GitHub landing page look nicer. The title is centered along with the logotype.

The second place is for notes. This is because there are multiple ways of creating notes, and they differ between GitHub and [ExDoc][ex_doc]. In [ExDoc][ex_doc], you can create a note via:

```markdown
> #### Error {: .error}
>
> This syntax will render an error block
```

This looks great in [ExDoc][ex_doc], but ends up looking pretty ugly in GitHub. If you're up to date on your GitHub news, you also now that you can use this to make a note in GitHub Markdown:

```markdown
> **Note**
> This is a note
```

Sadly, this looks pretty basic in [ExDoc][ex_doc]. So to deal with all of this, I just use HTML for notes. This looks good in [ExDoc][ex_doc] and is unstyled in GitHub. It kinda sucks for writing, but it looks better in most contexts.

[ex_doc]: https://github.com/elixir-lang/ex_doc
[this]: https://github.com/btkostner/jumar/blob/main/docs/documentation/ex_doc.md
[config]: https://github.com/btkostner/jumar/blob/main/mix.exs
[readme]: https://github.com/btkostner/jumar/blob/main/README.md
