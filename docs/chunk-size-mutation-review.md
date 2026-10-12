# Chunk-size formatter: property and mutation review

## Result

A fixed-seed property found a real chunked-transfer encoding defect:
`int_to_hex(1)` returned `"49"` rather than `"1"`. Indexing the hexadecimal
alphabet yields a UTF-16 code unit; calling its `to_string()` prints the numeric
code unit. Convert the known ASCII code unit to a character before rendering it.
The public regression now checks that `encode_chunk([b'A'])` produces exactly
`1\r\nA\r\n`.

The private helper was moved unchanged from `encoder.mbt` to `encoder_hex.mbt`
first, to scope mutation discovery without excluding unrelated blocks through
annotations. The only subsequent production behavior change is
`.to_string()` -> `.to_char().unwrap().to_string()` on the alphabet entry.
All possible entries are ASCII hexadecimal digits, so the conversion is defined.
No public interface changed.

## Reproducibility

- Repository: https://github.com/f4ah6o/http11.mbt
- Base: `250a978988e3c81377b8d7c432cae5e7b193d96d`
- Moon: `0.1.20260920` (`914d7da`), matching `.tool-versions` and CI
- Compiler: `v0.10.14+7d59c7ec9`
- Official core archive: `core-0.10.14+7d59c7ec9.tar.gz`
- Core archive SHA-256: `6f18b8fdea18f85e628a75e4a1bd3977c5a5c9c6a836fd8824192b0e6bd91b14`
- turtles: `0.4.6`, official Linux release; source commit
  `6f5e06a70e7de1b49a3249f1d91a98e5f0f7e2b2`
- Mutation target: native; jobs: 2; per-command timeout: 30 seconds
- Mutation selection: checked-in `turtles.toml`, only `encoder_hex.mbt`
- Property: official `moonbitlang/core/quickcheck.check`; seed `20261012`,
  2,000 accepted cases, max size `2147483647`, max shrinks `1000`
- Domain: nonnegative `Int`, the domain of the caller's array length
- Oracle: core `Int::to_string(radix=16)`, not a copied implementation
- Explicit examples: 24 zero, radix-power-adjacent, and maximum-Int cases

Run:

```sh
moon test --target native
moon check --deny-warn --target native
moon info && moon fmt --check
turtles --dir . --target native --list
turtles --dir . --target native --jobs 2 --timeout 30 --emit-regressions \
  --json after.json --output-dir .turtles
```

## Evidence and comparison design

1. The original suite passed twice: 50/50 native tests on the pinned toolchain.
   The unchanged helper extraction preserved this baseline.
2. Initial buggy-source inventory: 8 target-active mutants; 0 killed,
   7 survived, 1 unviable, 0 timeouts.
3. The newly added oracle and boundaries failed before the fix. QuickCheck
   shrank the real defect to `1` (20 successful, 21 attempted shrinks).
4. After the minimal fix, 53/53 tests passed twice on native.
5. To avoid attributing a source change to test improvement, a separate copy
   used the **corrected production source with only the original tests**.
   Its 8 mutant identity tuples (ID, path, offsets, edit, group and location)
   were verified identical to the final campaign. It had 0 killed, 7 survived,
   1 unviable, 0 timeouts. Adding the three tests gave 7 killed, 0 survived,
   1 unviable, 0 timeouts, with no reused results.
6. The public wire regression ran alone: 1/1 passed on the fixed unmutated
   source; 0/1 passed when `if n == 0` was replaced with `if true` in a separate
   copy. It detected the wire-size byte changing from `0x31` to `0x30`.

## Final mutant classification

| ID | Change | Original tests, corrected source | Added tests |
| --- | --- | --- | --- |
| m-e9b633a60459188f | body -> empty string | survived | killed |
| m-41c01f496a9201bf | body -> xyzzy | survived | killed |
| m-275a8ccb860f648b | zero condition -> true | survived | killed |
| m-add6301818b40b20 | zero condition -> false | survived | killed |
| m-2ca47b0da85aa45f | == -> != | survived | killed |
| m-a5e11b4e6a9f831f | > -> < | survived | killed |
| m-f77e6bc284374afe | string + -> - | unviable | unviable |
| m-76d564df25e451bb | / -> * | survived | killed |

There are no remaining survivors to classify as equivalent. String subtraction
is rejected by the type checker and excluded from the viable denominator.
All seven viable kills were attributed to both the property and explicit
assertions; there were zero property-exclusive kills. The property additionally
found the actual production defect before the boundary regression was retained.

## Final validation

- Native tests: 53/53, repeated
- JavaScript tests: 53/53
- WebAssembly GC tests: 53/53
- Native check with `--deny-warn`: passed
- JavaScript and WebAssembly GC checks: passed
- Classic WebAssembly tests: build-only passed, not executed
- Native build: passed
- `moon info`: no generated public-interface changes
- `moon fmt --check` and `git diff --check`: passed

Independent code review confirmed the conversion, the nonnegative contract,
minimal extraction, independent oracle, and matched mutation comparison.

This is a small pure-helper campaign, not an audit of the HTTP parser, all
encoder behavior, or network behavior. The 100% score is 7/7 viable mutants in
this selected scope only. QuickCheck is randomized testing with shrinking, not
formal verification or a replacement for Kani. These results were obtained
locally before publication; hosted CI results are reported separately on the PR.
