# Synchronized

a go generics synchronization library.

This package is inspired by [folly::Synchronized](https://github.com/facebook/folly/blob/master/folly/docs/Synchronized.md), but has almost zero of the same API.

## Usage

### API

The package provides two `struct`s, both with the same API.

- `Synchronized[T]`. A wrapper for a value `T` that is locked with a [`sync.Locker`](https://golang.org/pkg/sync/#Locker).

- `RWSynchronized[T]`. A wrapper for a value `T` that is locked with a
read-write lock, `RWLocker`.

#### `Synchronized[T]`

`Synchronized[T]` can be created via `NewSynchronized`, which initializes the
structure with a given value, and a [`*sync.Mutex`](https://golang.org/pkg/sync/#Mutex).
To specify a custom `Locker`, `NewSynchronizedWithLock` accepts a value and the
lock to use.

Once created there are three functions to interact with the locked object.
`Set(value T)` is the setter, `Value() T` is the getter. To do a more complex
operation, `WithLock(func(value *T))` acquires a lock to the underlying object,
then calls the given function and passes the data in as a pointer. This allows
the function to either read the stored value, or update it by dereferencing and
assigning to the pointer.

#### `RWSynchronized[T]`

`RWSynchronized[T]` can be created via `NewRWSynchronized`, which initializes the
structure with a given value, and a [`*sync.RWMutex`](https://golang.org/pkg/sync/#RWMutex).
To specify a custom `RWLocker`, `NewRWSynchronizedWithLock` accepts a value and the
lock to use.

The API is the same as `Synchronized[T]`, with the notable difference that
calling `Value() T` acquires a read-lock rather than an exclusive write lock.

### Example

Here's a contrived example that shows how to use the API

```go

import (
  "fmt"

  "github.com/jacobbogdanov/synchronized"
)

func main() {
    // create a synchronized int slice.
    locked := synchronizedNewRWSynchronized[[]int]([]int{1, 2, 3, 4})

    // Double each value.
    locked.WithLock(func(values *[]int) {
        for i, value := range *values {
            (*values)[i] = value * 2
        }
    })

    // read the values.
    locked.WithRLock(func(values []int) {
        for i, value := range values {
            fmt.Printf("%d=%d\n", i, value)
        }
    })

    // Or just replace the entire thing.
    locked.Set([]int{4, 3, 2, 1})

    // copy the data out, then read the values.
    values := locked.Value()
    for i, value := range values {
        fmt.Printf("%d=%d\n", i, value)
    }
}
```

### Setup

At the time of writing this, the [Type Parameters Design-Draft](https://go.googlesource.com/proposal/+/refs/heads/master/design/go2draft-type-parameters.md) has been [accepted](https://github.com/golang/go/issues/43651),
but not released in an official version of go. To use the code in this repo you
will need to follow the instructions in the [dev.go2go README](https://go.googlesource.com/go/+/refs/heads/dev.go2go/README.go2go.md).
