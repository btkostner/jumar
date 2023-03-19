# Database

I chose to go with [Cockroach DB][cdb] for the database layer. This is because it shares a lot of the same scaling principals as Elixir. It scales horizontally. A single node can not take down the whole cluster. It's simple to upgrade in a rolling release (very helpful for Fly.io). And lastly, it has a very useful web interface to help debug slow queries. I won't go into too much detail about the benefits, but know that there are quite a bit. On the Elixir side, we use the standard `Postgrex` module to connect and run mostly the standard setup. Once thing of note is that during tests, we use a unique sandbox module to work around nested transactions. See this [ecto issue][cdb-gh-issue] for more details.

[cdb]: https://www.cockroachlabs.com/
[cdb-gh-issue]: https://github.com/elixir-ecto/ecto/issues/1959
