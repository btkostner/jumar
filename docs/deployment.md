# Deployment

This guide goes over deploying Jumar to Fly.io. This will be pretty specific to Fly.io, but can be converted to other deployment platforms as well.

## Database

Deploying Cockroach DB to Fly.io _can_ be easy if you chose to run without TLS. This _can_ be fine, but we want to keep with best security practice, so we will generate self signed certificates for all nodes and ensure secure connections are enforced.

### Building

If you are running a Cockroach DB instance yourself, I'd strongly suggest you to publish your own custom Docker image for Cockroach. This makes it easier to version control and prevents build chain attacks. First up, `cd` into the `priv/cockroachdb` directory. Next, build the included `Dockerfile` and push it to your repository of choice. Once done, update the `fly.toml` file to point to the registry you just published to. Once that is done, you can follow the rest of this guide.

### Setup

For setup, you'll need to build the included `Dockerfile` locally so we can run some commands in it. You can do that via this command:

```bash
docker build -t cockroach .
```

Then create the certificates directory. You can do this via running:

```bash
mkdir cockroach-certs
```

Next up, start the container in interactive mode so we can run some commands. You'll also want to mount the current directory so you can save the certificates.

```bash
docker run --rm -it -v $(pwd)/cockroach-certs:/root/.cockroach-certs --entrypoint /bin/bash cockroach
```

<blockquote class="neutral">
  <h4 class="neutral"><strong>Note</strong></h4>

  <p>You might encounter permission errors running the above command. If you do, you will need to add <code>--privileged</code>.</p>
</blockquote>

Then export the Fly.io app name you will use. By default, this is just `cockroach`.

```bash
export FLY_APP="cockroach"
```

Next up, create the certificates you'll need:

```bash
cockroach cert create-ca --ca-key=$HOME/.cockroach-certs/ca.key
cockroach cert create-node --ca-key=$HOME/.cockroach-certs/ca.key 127.0.0.1 localhost $FLY_APP.internal "*.$FLY_APP.internal" "*.vm.$FLY_APP.internal" "*.nearest.of.$FLY_APP.internal" $FLY_APP.fly.dev
```

Next up, you'll want to generate a certificate for your `root`, `jumar`, and any other clients you want. Do this via:

```bash
cockroach cert create-client --ca-key=$HOME/.cockroach-certs/ca.key <client>
```

Once that is done, you can exit the container. **Ensure you save the generated certificates and keys to a secure place**.

### Deploying

Then create the Fly.io deployment via:

```bash
flyctl launch
```

This will create an empty deployment where we will want to add our secrets to via:

```bash
base64 ./cockroach-certs/ca.crt | flyctl secrets set DB_CA_CRT=-
base64 ./cockroach-certs/node.crt | flyctl secrets set DB_NODE_CRT=-
base64 ./cockroach-certs/node.key | flyctl secrets set DB_NODE_KEY=-
```

Next up, start creating some volumes. This will dictate where Fly.io places your servers, so please check the [Cockroach DB multi-region capabilities overview page](https://www.cockroachlabs.com/docs/stable/multiregion-overview.html) to ensure your survivability goals match what you create here. Once you figure out the regions you want, run this command to generate a volume. Repeat for every instance you want and change the volume size to fit your needs.

```bash
flyctl volumes create crdb_data --region <region> --size 10
```

**Optionally**, you can scale the VM size you will use. Cockroach recommends at least 4gb of RAM. From personal experience, 1gb is the absolute _minimum_ you will want (might still cause problems). Keep in mind that this is pretty easy to change after the fact _without downtime_ if you are running multiple instances.

```bash
flyctl scale vm <size> --memory <memory_in_megabytes>
```

Once that is done, you can deploy the database!

```bash
flyctl deploy
```

Next up, you'll want to copy your previously generated `client.root.crt` and `client.root.key` files to a node. You can do this via the flyctl sftp command:

```bash
flyctl sftp shell
```

Then type this command to copy your local files to the node:

```sftp
put ./cockroach-certs/client.root.crt /root/.cockroach-certs/client.root.crt
put ./cockroach-certs/client.root.key /root/.cockroach-certs/client.root.key
```

You can then `^C` out of that shell. Next up, ssh into the running container you just copied the file to.

```bash
flyctl ssh console
```

And then initialize the cluster.

```bash
chmod 600 $HOME/.cockroach-certs/client.root.key
cockroach init --cluster-name=$FLY_APP_NAME --host=$FLY_APP_NAME.internal
```

You should then see `Cluster successfully initialized` in your terminal. After the cluster is initialized, you can create users to access the cluster. You'll want at least one with a set password to allow you to log into the web UI.

```bash
cockroach sql --execute="CREATE USER <username> WITH PASSWORD '<password>'" --execute="GRANT SYSTEM ALL TO <user>"
```

Optionally, you can set [different grants](https://www.cockroachlabs.com/docs/v22.2/grant#supported-privileges) for the user.

You'll also want to create the `jumar` database, user, and grant them permissions. This can be done via:

```bash
cockroach sql --execute="CREATE DATABASE jumar" --execute="CREATE USER jumar" --execute="GRANT ALL ON DATABASE jumar TO jumar"
```

Once that is done, you can exit out of the terminal. You should then run `flyctl apps restart <app>` to restart your database node. This will remove the root certificate and key from the file system. You can then do `flyctl scale count <count>` to create more nodes matching the number of volumes you created above.

### Access

Once your node is up, you can proxy to the node and access the web UI. To do this, run this proxy command:

```bash
flyctl proxy 8080:8080
```

Then open your browser to <http://localhost:8080>, ignore the certificate warning, and login with the user you previously created.

### Updating

Updating a Cockroach cluster is much easier than most other databases when it's ran in a multi node setup. All you'll need to do is update the image set in the `fly.toml` file and run `fly deploy`. This will create a new release on Fly.io, taking down one node at a time while it's upgrading. The Jumar application will gracefully handle this and reconnect to another node if the current connect node goes down.
