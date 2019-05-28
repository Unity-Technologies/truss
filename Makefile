# Makefile for Truss.
#
SHA := $(shell git rev-parse --short=10 HEAD)

MAKEFILE_PATH := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
VERSION_DATE := $(shell $(MAKEFILE_PATH)/commit_date.sh)

# Build native Truss by default.
default: truss

dependencies:
	go get -u github.com/gogo/protobuf/protoc-gen-gogo
	go get -u github.com/gogo/protobuf/protoc-gen-gogofaster
	go get -u github.com/gogo/protobuf/proto
	go get -u github.com/kevinburke/go-bindata/...

# Generate go files containing the all template files in []byte form
gobindata:
	go generate github.com/Unity-Technologies/truss/gengokit/template

# Install truss
truss: gobindata
	go install -ldflags '-X "main.Version=$(SHA)" -X "main.VersionDate=$(VERSION_DATE)"' github.com/Unity-Technologies/truss/cmd/truss

# Run the go tests and the truss integration tests
test: test-go test-integration

test-go:
	go test -v ./...

test-integration:
	$(MAKE) -C cmd/_integration-tests

# Removes generated code from tests
testclean:
	$(MAKE) -C cmd/_integration-tests clean

.PHONY: testclean test-integration test-go test truss gobindata dependencies
