FROM ubuntu as build

ENV DENO_VERSION=1.6.3

RUN apt update -y
RUN apt install -y python nodejs build-essential libglib2.0-dev curl
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

RUN curl -fsSL "https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno_src.tar.gz" -o deno.tar.gz
RUN tar -zxf deno.tar.gz
RUN rm deno.tar.gz

WORKDIR /deno

ENV PATH="/root/.cargo/bin:${PATH}"
# 7GB
ENV RUSTUP_UNPACK_RAM=7000000000

RUN rustup target add wasm32-unknown-unknown
RUN rustup target add wasm32-wasi 

RUN cargo build --release --locked -vv

FROM alpine

RUN addgroup -g 1993 -S deno
RUN adduser -u 1993 -S deno -G deno
RUN mkdir /deno-dir/
RUN chown deno:deno /deno-dir/

ENV DENO_DIR /deno-dir/
ENV DENO_INSTALL_ROOT /usr/local

COPY --from=build /deno/target/release/deno /bin/deno
RUN chmod 755 /bin/deno

ENTRYPOINT ["/bin/deno"]
CMD ["run", "https://deno.land/std/examples/welcome.ts"]
