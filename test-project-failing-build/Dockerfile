FROM alpine:3.20
# Intentional failure: run a command that doesn't exist
RUN this-command-does-not-exist
ENTRYPOINT ["echo", "this should never be reached"]
