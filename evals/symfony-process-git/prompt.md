---
description: Running git with an argument from user input through symfony/process. The Symfony reference should lead to the array form and a failure that is not ignored.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

We use symfony/process in a PHP 8.4 CLI tool. Write a function `commitsSince(string $repoDir, string $ref): string` that runs `git log --oneline <ref>..HEAD` inside `$repoDir` and returns the output. `$ref` comes from the user. If git fails, the caller must find out. Just the function, please.
