FROM golang:1.10-alpine AS builder

RUN apk add git

# Download and install dep
ADD https://github.com/golang/dep/releases/download/v0.4.1/dep-linux-amd64 /usr/bin/dep
RUN chmod +x /usr/bin/dep

# Copy the code from the host and compile it
WORKDIR $GOPATH/src/github.com/bitly/oauth2_proxy
COPY Gopkg.toml Gopkg.lock ./
RUN dep ensure --vendor-only
COPY . ./
RUN go build

FROM alpine:3.8
LABEL maintainer="Dan Maas <dmaas@maasdigital.com>"
# with credit to Andrew Huynh <a5thuynh@gmail.com>

# Install CA certificates
RUN apk add --no-cache --virtual=build-dependencies ca-certificates

COPY --from=builder /go/src/github.com/bitly/oauth2_proxy/oauth2_proxy ./bin/oauth2_proxy

# Expose the ports we need and setup the ENTRYPOINT w/ the default argument
# to be pass in.
EXPOSE 8080 4180
ENTRYPOINT [ "./bin/oauth2_proxy" ]
CMD [ "--upstream=http://0.0.0.0:8080/", "--http-address=0.0.0.0:4180" ]
