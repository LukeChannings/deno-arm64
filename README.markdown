# Deno ARM64

I put this together because there are no ARM images for Docker [yet](https://github.com/denoland/deno/issues/1846#issuecomment-725165778).
This project compiles ARM binaries (see [Dockerfile.compile](Dockerfile.compile)) as well as building Docker images.

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
