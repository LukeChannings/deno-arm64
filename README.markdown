# Docker images for Deno

I put this together because there are no ARM images for Docker [yet](https://github.com/denoland/deno/issues/1846#issuecomment-725165778).
This project compiles ARM binaries (see [Dockerfile.compile](Dockerfile.compile)) as well as building Docker images.

## As a runtime image

```Dockerfile
FROM lukechannings/deno:latest

CMD ["run", "https://deno.land/std/examples/welcome.ts"]
```

## Using as a builder

```Dockerfile
FROM lukechannings/deno:latest as compile

RUN deno compile --unstable https://deno.land/std/examples/welcome.ts

FROM ubuntu

COPY --from=compile /welcome

CMD ["/welcome"]
```
