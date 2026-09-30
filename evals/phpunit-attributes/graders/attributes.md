---
type: llm
weight: 2
---

PASS if the test class uses PHP attributes for its metadata (`#[DataProvider(...)]` or `#[TestWith(...)]` for the cases, and `#[CoversClass(Slugger::class)]`), does not put `@dataProvider` or `@covers` in doc-comments, and compares the slug with `assertSame()`.
FAIL if the code relies on `@dataProvider` or `@covers` doc-comment annotations, which PHPUnit 12 ignores, or uses `assertEquals()` for the string comparison.
