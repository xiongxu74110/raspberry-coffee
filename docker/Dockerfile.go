FROM golang:1.8

ENV http_proxy http://www-proxy.us.oracle.com:80
ENV https_proxy http://www-proxy.us.oracle.com:80

RUN echo "alias ll='ls -lisah'" >> $HOME/.bashrc

WORKDIR /go/src
COPY ./app ./app
WORKDIR /go/src/app

RUN go get -d -v ./...
RUN go install -v ./...
RUN go build

ENV http_proxy ""
ENV https_proxy ""

CMD ["app"]