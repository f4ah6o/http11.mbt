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

## Revalidation after main's toolchain update (2026-10-13)

PR #8 was merged into main at
`e8821026f2c9f2f58a3120c04114032ac7ead54a`. PR #7 incorporates that commit
without reverting its toolchain pins or source migrations. The CI conflict
uses main's installer release `0.10.15+943464bfa`. The helper remains extracted
and fixed; its input and the property input use `Int32`, matching main's
migration. The duplicate, buggy helper from main is not restored.

The results in this section are a **new campaign on the merged source**, run
on this Mac. The original campaign below used the old source and toolchain;
its mutant IDs and measurements are historical evidence, not reused results.

- Moon: `0.1.20261012` (`748b63c`)
- Compiler and official core: `v0.10.15+943464bfa`
- Core archive SHA-256:
  `96d30f4dbcc6a9e1736ef26fbdd0e8fb0e97cb01d50e55d2a0072208b8061ae5`
- `src/encoder_hex.mbt` SHA-256:
  `0cc0152b81c9a65104697335d08618016177df649243467be92d06916146b938`
- turtles: `0.4.6`, macOS arm64; native target, 2 jobs, 30-second timeout,
  checked-in operators and file selection; no reused outcomes
- Both comparison copies contain identical corrected production source. The
  control removes only the two added test files (50 tests); the treatment
  retains the property, 24 boundaries and wire regression (53 tests).
- All 8 new mutant identities match between these two copies, including ID,
  path, offsets, original text, replacement, group and location. The `Int32`
  spelling shifts offsets, so these IDs differ from the old campaign.

| New mutant ID | Change | Original tests, corrected source | Added tests |
| --- | --- | --- | --- |
| m-f103f0a1ddb6920f | body -> empty string | survived | killed |
| m-b0fda3db2c86fe3f | body -> xyzzy | survived | killed |
| m-953787cf582f436f | zero condition -> true | survived | killed |
| m-54ac322fcf87268c | zero condition -> false | survived | killed |
| m-d1eda2ee0c70ae82 | == -> != | survived | killed |
| m-cb3ab7c33035b86b | > -> < | survived | killed |
| m-f609f25824612bee | string + -> - | unviable | unviable |
| m-55ddd627d811dcdf | / -> * | survived | killed |

The new control has 0 killed / 7 survived; the new treatment has 7 killed /
0 survived. Both have 1 unviable mutant and 0 timeouts. All seven viable mutants
are caught by both the property and boundary assertions; property-exclusive
kills remain zero. This is 7/7 within the selected pure helper, not a score for
the whole HTTP library. The seed, accepted-case count, size, shrinking limit,
nonnegative domain and independent core radix oracle are unchanged.

Fresh local validation passes native, JavaScript and wasm-gc tests (53/53
each), native `--deny-warn` check, JavaScript and wasm-gc checks, native build,
classic wasm test build-only, `moon info`, `moon fmt`, `moon fmt --check` and
`git diff --check`. Public interfaces are identical to updated main. The
non-native checks retain 8 unused-import warnings in the native-only example
packages; no unrelated cleanup is included.

The original defect was separately restored in a disposable merged-source
copy: the property fails and shrinks to `1`. The isolated wire regression
passes 1/1 on pristine merged source and fails 0/1 on the condition-true mutant.
Hosted CI is verified separately against the pushed PR HEAD.

## Original campaign reproducibility

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

## Original evidence and comparison design

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

## Original mutant classification

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

## Original validation

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
