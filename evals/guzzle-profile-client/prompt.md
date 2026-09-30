---
description: A new Guzzle client class. The Guzzle reference should lead to explicit timeouts and failures that reach the caller.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

Write a PHP 8.4 class `ProfileClient` that uses Guzzle to fetch `GET https://api.example.com/v2/users/{id}` and returns the decoded JSON as an array. It runs inside a web request, so it must not hang, and the caller needs to know when the API is down or returns an error. Show me the class.
