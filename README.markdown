# Deno ARM64

I put this together because there are no ARM images for Docker [yet](https://github.com/denoland/deno/issues/1846#issuecomment-725165778).
This project compiles ARM binaries (see [Dockerfile.compile](Dockerfile.compile)) as well as building Docker images.

## Why isn't there official support?

The Deno team are waiting for ARM64 GitHub Actions runners:

> We use GitHub Actions exclusively. We are working with GitHub on the potential of their ARM64 support.
> 
> &mdash; [@kitsonk](https://github.com/denoland/deno/issues/1846#issuecomment-725209062)

At the moment [GitHub Actions Virtual Environments](https://github.com/actions/virtual-environments) are x86 only &mdash; although you can provide your own runners.

The QEMU-based builds take a long time, up to 2 hours just for compiling, and since Deno's CI runs on each push it needs to be fast.

You can follow the issue [here](https://github.com/denoland/deno/issues/1846).

## How do I use this as a base image?

```Dockerfile
FROM lukechannings/deno:1.6.3

CMD ["run", "https://deno.land/std/examples/welcome.ts"]
```

(A real-world example can be found [here](https://github.com/LukeChannings/moviematch/blob/main/Dockerfile))

## Where can I download Deno binaries for ARM64?

Deno binaries can be found in listed assets in [releases](https://github.com/LukeChannings/docker-deno/releases).

e.g. [https://github.com/LukeChannings/docker-deno/releases/download/v1.6.3/deno-linux-arm64.zip](https://github.com/LukeChannings/docker-deno/releases/download/v1.6.3/deno-linux-arm64.zip)

## How do I compile deno myself?

1. Set up buildx, so that you can emulate ARM: `docker buildx create --use`
2. Ensure Docker is configured with *at least* 8GB of RAM, otherwise the build will fail with `(signal: 9, SIGKILL: kill)`
3. Compile with `docker build -t deno-build --build-arg DENO_VERSION="v1.7.4" --platform="linux/arm64" --file ./Dockerfile.compile .`
4. Run `docker cp $(docker create deno-build):/deno/target/release/deno ./deno`

The resulting `deno` binary will run on Linux ARM64.

To build your own Docker image, run:

```bash
docker buildx create --use
docker buildx build --platform linux/arm64 -t deno --load -f Dockerfile.standalone .

# Run with
docker run -it --rm --platform=linux/arm64 deno
```

## What about 32-bit ARM?!

Docker's buildx uses [QEMU](https://en.wikipedia.org/wiki/QEMU) by emulate ARM on x86.

Unfortunately there are bugs related to QEMU and 32-bit ARM that prevent compilation. 
You can read more [here](https://bugs.launchpad.net/qemu/+bug/1805913).

As such, compiling for 32-bit ARM needs to be done on a 32-bit ARM computer,
and because these systems are typically underpowered,
compiling may take a prohibitively long time 😬.

## Why can't you just cross-compile?

In order to speed up startup time Deno builds a V8 bytecode snapshot for its JavaScript runtime.
These snapshots are architecture-specific, and will cause a crash at runtime if the architecture isn't the same.

For example, when Deno is cross-compiled to ARM64 from an x86_64 architecture, the resulting binary will be ARM64.
However, because the [`build.rs`](https://github.com/denoland/deno/blob/master/cli/build.rs#L52) snapshot was generated on an x86 host, the snapshot will be x86 bytecode, and that causes a crash at runtime.

I tried to work around this by patching Deno to disable the compiler snapshot, but there was still a runtime crash with a difficult-to-debug stacktrace, so I think the rabbit hole goes deeper.

I don't think patching Deno is a viable option, since a future change to Deno could cause another kind of incompatibility, and I'd have to maintain a patch. For the time being emulation is a reasonable (if a bit slow) solution to this problem.

Further, Deno depends on [`rusty_v8`](https://github.com/denoland/rusty_v8), which takes a long time to compile in normal conditions, let alone under emulation.

At time of writing `rusty_v8` has problems publishing a pre-compiled ARM64 binary, and so Deno requires being compiled with `V8_FROM_SOURCE=1`, as well as a number of additional dependencies.

I have forked `rusty_v8` for this project and have been able to successfully cross-compile `rusty_v8` for ARM64. The standalone binaries can be found [here](https://github.com/lukechannings/rusty_v8/releases).
