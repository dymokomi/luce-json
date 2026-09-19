# luce-json

Structured JSON encoding and decoding for [Luce](https://github.com/dymokomi/luce) and
[luce-base](https://github.com/dymokomi/luce-base). A standalone package: it depends only on
the embedded standard library (`memory`, `interop`, `strings`, `utf8`, `math`).

## Use it

Declare the dependency relative to your own manifest:

```toml
[package]
name = "demo"

[dependencies]
luce_json = "../luce-json"
```

```luce
import json
import memory

pub func main(arguments: str[]) -> i32!:
    with memory.heap:
        # Encode: build a value, then read its UTF-8 text.
        let object = try new json.Value()
        defer free(object)
        defer object.close()
        try object.set_integer("count", 42)
        try object.set_text("name", "luce")
        print(object.encode())                       # {"count":42,"name":"luce"}

        # Decode: parse text into a queryable document.
        let document = try json.decode(object.encode())
        defer document.release()
        let root = (try document.get()).root()
        let count = (root.member("count") else trap("count")).integer() else -1
        print(f"{count}")                            # 42
    return 0
```

## Encoding

`json.Value()` creates an object; `Value.array()`, `text`, `integer`, `number`, `boolean` and
`null` construct the other values. Containers take `set`/`append`; objects also have
`set_text`, `set_integer`, `set_number`, `set_boolean`. Containers snapshot inserted values,
so a later change to a child never mutates its parent or forms a cycle. `encode()` borrows the
value's UTF-8 text until the next mutation or close. All growth is bounded and transactional.

## Decoding

`json.decode(text, maximum_bytes = 1 MiB)` parses one complete JSON value into an owned
`Document`. `document.root()` returns a `View` cursor:

| Method | Answers |
| --- | --- |
| `kind()` | `Kind.object`, `.array`, `.string`, `.number`, `.boolean` or `.null` |
| `length()` | member/element count of an object or array |
| `member(name)` | the named object member, or `none` |
| `at(index)` | the array element at `index`, or `none` |
| `text()` | a string's decoded UTF-8 (escapes and surrogate pairs resolved), or `none` |
| `integer()` / `number()` | a number as `i64` / `f64`, or `none` |
| `boolean()` | a boolean, or `none` |
| `is_null()` | whether the value is JSON `null` |

Views are borrowed and valid until the document closes. Malformed input fails with
`json.invalid`; input larger than the limit fails with `json.limit_exceeded`.

## Test

`./test.sh` runs the unit tests through both backends and a consumer round-trip. Set
`LUCE_BASE` to your compiler; it defaults to a sibling `../luce-base` checkout.

## License

Dual-licensed under Apache-2.0 or MIT, at your option.
