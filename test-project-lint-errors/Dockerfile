FROM ubuntu:latest
RUN apt-get update && apt-get install -y curl wget vim
RUN curl http://example.com/script.sh | bash
ADD https://example.com/file.tar.gz /tmp/
COPY . /app
CMD sh -c "echo hello"
