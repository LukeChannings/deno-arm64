FROM alpine

RUN addgroup -g 1993 -S deno
RUN adduser -u 1993 -S deno -G deno
RUN mkdir /deno-dir/
RUN chown deno:deno /deno-dir/

ENV DENO_DIR /deno-dir/
ENV DENO_INSTALL_ROOT /usr/local

COPY deno /bin/deno
RUN chmod 755 /bin/deno

ENTRYPOINT ["/bin/deno"]
CMD ["run", "https://deno.land/std/examples/welcome.ts"]
