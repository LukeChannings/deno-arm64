FROM ubuntu:20.04 as downloader

ARG TARGETPLATFORM
ARG VERSION

RUN apt update -y
RUN apt install -y unzip curl

RUN curl -Lsf https://github.com/LukeChannings/docker-deno/releases/download/${VERSION}/deno-$(echo $TARGETPLATFORM | tr '/' '-').zip -o deno.zip

RUN unzip deno.zip && rm deno.zip

FROM ubuntu:20.04

COPY --from=downloader /deno /bin/deno
RUN chmod 755 /bin/deno

RUN addgroup --gid 1993 deno
RUN adduser --uid 1993 --gid 1993 deno
RUN mkdir /deno-dir/
RUN chown deno:deno /deno-dir/

ENV DENO_DIR /deno-dir/
ENV DENO_INSTALL_ROOT /usr/local

ENTRYPOINT ["/bin/deno"]
CMD ["run", "https://deno.land/std/examples/welcome.ts"]
