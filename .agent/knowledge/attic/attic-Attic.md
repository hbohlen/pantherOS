## [`attic` CLI](https://docs.attic.rs/reference/attic-cli.html#attic-cli)

The following are the help messages that will be printed when you invoke any sub-command with `--help`:

```
Attic binary cache client

Usage: attic <COMMAND>

Commands:
  login        Log into an Attic server
  use          Configure Nix to use a binary cache
  push         Push closures to a binary cache
  cache        Manage caches on an Attic server
  watch-store  Watch the Nix Store for new paths and upload them to a binary cache
  help         Print this message or the help of the given subcommand(s)

Options:
  -h, --help     Print help
  -V, --version  Print version
```

## [`attic login`](https://docs.attic.rs/reference/attic-cli.html#attic-login)

```
Log into an Attic server

Usage: attic login [OPTIONS] <NAME> <ENDPOINT> [TOKEN]

Arguments:
  <NAME>      Name of the server
  <ENDPOINT>  Endpoint of the server
  [TOKEN]     Access token

Options:
      --set-default  Set the server as the default
  -h, --help         Print help
  -V, --version      Print version
```

## [`attic use`](https://docs.attic.rs/reference/attic-cli.html#attic-use)

```
Configure Nix to use a binary cache

Usage: attic use <CACHE>

Arguments:
  <CACHE>
          The cache to configure.
          
          This can be either `servername:cachename` or `cachename` when using the default server.

Options:
  -h, --help
          Print help (see a summary with '-h')

  -V, --version
          Print version
```

## [`attic push`](https://docs.attic.rs/reference/attic-cli.html#attic-push)

```
Push closures to a binary cache

Usage: attic push [OPTIONS] <CACHE> [PATHS]...

Arguments:
  <CACHE>
          The cache to push to.
          
          This can be either `servername:cachename` or `cachename` when using the default server.

  [PATHS]...
          The store paths to push

Options:
      --stdin
          Read paths from the standard input

      --no-closure
          Push the specified paths only and do not compute closures

      --ignore-upstream-cache-filter
          Ignore the upstream cache filter

  -j, --jobs <JOBS>
          The maximum number of parallel upload processes
          
          [default: 5]

  -h, --help
          Print help (see a summary with '-h')

  -V, --version
          Print version
```

## [`attic watch-store`](https://docs.attic.rs/reference/attic-cli.html#attic-watch-store)

```
Watch the Nix Store for new paths and upload them to a binary cache

Usage: attic watch-store [OPTIONS] <CACHE>

Arguments:
  <CACHE>
          The cache to push to.
          
          This can be either `servername:cachename` or `cachename` when using the default server.

Options:
      --ignore-upstream-cache-filter
          Ignore the upstream cache filter

  -j, --jobs <JOBS>
          The maximum number of parallel upload processes
          
          [default: 5]

  -h, --help
          Print help (see a summary with '-h')

  -V, --version
          Print version
```

## [`attic cache`](https://docs.attic.rs/reference/attic-cli.html#attic-cache)

```
Manage caches on an Attic server

Usage: attic cache <COMMAND>

Commands:
  create     Create a cache
  configure  Configure a cache
  destroy    Destroy a cache
  info       Show the current configuration of a cache
  help       Print this message or the help of the given subcommand(s)

Options:
  -h, --help     Print help
  -V, --version  Print version
```

## [`attic cache create`](https://docs.attic.rs/reference/attic-cli.html#attic-cache-create)

```
Create a cache.

You need the `create_cache` permission on the cache that you are creating.

Usage: attic cache create [OPTIONS] <CACHE>

Arguments:
  <CACHE>
          Name of the cache to create.
          
          This can be either `servername:cachename` or `cachename` when using the default server.

Options:
      --public
          Make the cache public.
          
          Public caches can be pulled from by anyone without a token. Only those with the `push` permission can push.
          
          By default, caches are private.

      --priority <PRIORITY>
          The priority of the binary cache.
          
          A lower number denotes a higher priority. <https://cache.nixos.org> has a priority of 40.
          
          [default: 41]

      --upstream-cache-key-name <NAME>
          The signing key name of an upstream cache.
          
          When pushing to the cache, paths signed with this key will be skipped by default. Specify this flag multiple times to add multiple key names.
          
          [default: cache.nixos.org-1]

  -h, --help
          Print help (see a summary with '-h')

  -V, --version
          Print version
```

## [`attic cache configure`](https://docs.attic.rs/reference/attic-cli.html#attic-cache-configure)

```
Configure a cache.

You need the `configure_cache` permission on the cache that you are configuring.

Usage: attic cache configure [OPTIONS] <CACHE>

Arguments:
  <CACHE>
          Name of the cache to configure

Options:
      --regenerate-keypair
          Regenerate the signing keypair.
          
          The server-side signing key will be regenerated and all users will need to configure the new signing key in `nix.conf`.

      --public
          Make the cache public.
          
          Use `--private` to make it private.

      --private
          Make the cache private.
          
          Use `--public` to make it public.

      --priority <PRIORITY>
          The priority of the binary cache.
          
          A lower number denotes a higher priority. <https://cache.nixos.org> has a priority of 40.

      --upstream-cache-key-name <NAME>
          The signing key name of an upstream cache.
          
          When pushing to the cache, paths signed with this key will be skipped by default. Specify this flag multiple times to add multiple key names.

      --retention-period <PERIOD>
          Set the retention period of the cache.
          
          You can use expressions like "2 years", "3 months" and "1y".

      --reset-retention-period
          Reset the retention period of the cache to global default

  -h, --help
          Print help (see a summary with '-h')

  -V, --version
          Print version
```

## [`attic cache destroy`](https://docs.attic.rs/reference/attic-cli.html#attic-cache-destroy)

```
Destroy a cache.

Destroying a cache causes it to become unavailable but the underlying data may not be deleted immediately. Depending on the server configuration, you may or may not be able to create the cache of the same name.

You need the `destroy_cache` permission on the cache that you are destroying.

Usage: attic cache destroy [OPTIONS] <CACHE>

Arguments:
  <CACHE>
          Name of the cache to destroy

Options:
      --no-confirm
          Don't ask for interactive confirmation

  -h, --help
          Print help (see a summary with '-h')

  -V, --version
          Print version
```

## [`attic cache info`](https://docs.attic.rs/reference/attic-cli.html#attic-cache-info)

```
Show the current configuration of a cache

Usage: attic cache info <CACHE>

Arguments:
  <CACHE>  Name of the cache to query

Options:
  -h, --help     Print help
  -V, --version  Print version
```

[](https://docs.attic.rs/reference/index.html "Previous chapter")[](https://docs.attic.rs/reference/atticd-cli.html "Next chapter")

[](https://docs.attic.rs/reference/index.html "Previous chapter")[](https://docs.attic.rs/reference/atticd-cli.html "Next chapter")