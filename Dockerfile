FROM golang:latest

# Install beego and the bee dev tool
RUN go get -u -v github.com/astaxie/beego
RUN go get -u -v github.com/beego/bee
RUN go get -u -v github.com/Microsoft/ApplicationInsights-Go/appinsights
RUN go get -u -v gopkg.in/mgo.v2
RUN go get -u -v github.com/Azure/go-autorest/autorest/utils
RUN go get -u -v github.com/Microsoft/ApplicationInsights-Go/appinsights

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
ENV DATABASE=
ENV PASSWORD=
ENV INSIGHTSKEY=
ENV SOURCE=

# Create the directory where the application will reside
# RUN mkdir /go/src

# Copy the application files (needed for production)
ADD . /go/src/go_order_SB

# Set the working directory to the app directory
WORKDIR /go/src/go_order_SB

# Expose the application on port 8080
EXPOSE 80

# Set the entry point of the container to the application executable
# ENTRYPOINT /go/src/app

# build the app
# RUN go build main.go
# Set the entry point of the container to the bee command that runs the
# application and watches for changes
CMD ["bee", "run"]