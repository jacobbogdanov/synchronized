#!/bin/bash

# NOTE: This script assumes that your $PATH is already set up and go/gofmt point to a
# toolchain that supports go generics.

set -e

echo "formatting code..."
gofmt -w **.go2

echo "running tests..."
go tool go2go test
