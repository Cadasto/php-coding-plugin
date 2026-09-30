---
description: A new PHPUnit 12 test in a folder whose neighbours still use doc-comment annotations. The testing reference should lead to attributes.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

We're on PHPUnit 12.5. Write a test class for `App\Text\Slugger::slug(string $title): string` with a handful of cases (spaces, accents, punctuation, empty string). The other tests in `tests/Unit/Text/` use `@dataProvider` and `@covers` docblocks, so match whatever is right for us. Just the test class.
