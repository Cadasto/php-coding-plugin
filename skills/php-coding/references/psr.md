# PSR interface contracts

Read when: `composer.json` requires a `psr/*` package (`psr/log`, `psr/cache`, `psr/simple-cache`, `psr/http-message`, `psr/http-factory`, `psr/http-client`, `psr/http-server-handler`, `psr/http-server-middleware`, `psr/container`, `psr/event-dispatcher`, `psr/clock`), or code type-hints a `Psr\Log`, `Psr\Cache`, `Psr\SimpleCache`, `Psr\Http\Message`, `Psr\Http\Client`, `Psr\Http\Server`, `Psr\Container`, `Psr\EventDispatcher`, or `Psr\Clock` interface.

Deterministic backstop: none for these rules. `vendor/bin/phpstan analyse` at level 8 checks the interface signatures, not the contracts below. It does not report a discarded `withHeader()` result: PHPStan reports an unused call only when it has no impure points, and a method with no purity annotation counts as possibly impure. psr/http-message 2.0 has no such annotations ([rule](https://github.com/phpstan/phpstan-src/blob/2.2.16/src/Rules/Methods/CallToMethodStatementWithoutSideEffectsRule.php), [impure point](https://github.com/phpstan/phpstan-src/blob/2.2.16/src/Reflection/Callables/SimpleImpurePoint.php)).

Every `psr/*` interface package installs on the 8.4 pin; `psr/http-message` 2.0 and `psr/log` 3.0 are the current majors. Monolog is `monolog.md`, Guzzle is `guzzle.md`, OpenTelemetry is `opentelemetry.md`, Symfony implementations are `symfony-components.md`, and Slim is `slim.md`.

## Rules

### HTTP messages (PSR-7, PSR-17, PSR-15, PSR-18)

- **Keep the return value of every `with*()` call.** Messages are immutable. Every method that might change state MUST keep the current instance as it was and return an instance with the change (PSR-7 section 3, <https://www.php-fig.org/psr/psr-7/>). A bare `$response->withHeader(...);` statement does nothing. In middleware, pass the request that `withAttribute()` returned on to `$handler->handle()` (PSR-15 meta section 6.2, <https://www.php-fig.org/psr/psr-15/meta/>).

  ```php
  $response = $response->withHeader('Content-Type', 'application/json');
  return $handler->handle($request->withAttribute('user', $user));
  ```

- **Do not use `===` to test whether a message changed or was sent as passed.** A `with*()` method MAY return `$this` when the value does not change (PSR-7 meta, "New instances vs returning $this", <https://www.php-fig.org/psr/psr-7/meta/>). A PSR-18 client MAY send a different object from the one given to `sendRequest()`, so the caller MUST NOT compare them by reference (<https://www.php-fig.org/psr/psr-18/>).
- **Read a whole body with `(string) $body`, not `getContents()`.** `__toString()` MUST seek to the start and read to the end. `getContents()` returns only what remains after the current position (PSR-7 section 3.4). After a `write()` or an earlier read, `getContents()` returns a partial or empty string. To use `getContents()` for the whole body, call `rewind()` first, which throws on a stream that cannot seek.
- **A body stream is shared, mutable state.** `StreamInterface` does not model immutability, and any code that holds the stream can move its cursor or change its contents. When in doubt, create a new stream and attach it with `withBody()` (PSR-7 section 1.3). Create that stream with `StreamFactoryInterface::createStream()` (<https://www.php-fig.org/psr/psr-17/>).
- **Library code builds messages through PSR-17 factories.** Creating a concrete response ties a package to one PSR-7 implementation. PSR-17 exists so reusable middleware and handlers depend on the factory interfaces instead (PSR-17 meta section 2, <https://www.php-fig.org/psr/psr-17/meta/>), and PSR-15 section 1.3 RECOMMENDS a response prototype or factory (<https://www.php-fig.org/psr/psr-15/>). `ResponseFactoryInterface::createResponse()` defaults to `200`, so pass the status for an error response.
- **Type-hint `Psr\Http\Client\ClientInterface`, not a concrete client.** PSR-18 exists so libraries are decoupled from the client implementation and clients can be swapped (PSR-18, Goal).
- **A 4xx or 5xx response is not an exception.** A PSR-18 client MUST NOT throw for a well-formed response. Responses in the 400 and 500 range MUST be returned as normal (PSR-18, Error handling). A `catch (ClientExceptionInterface)` does not handle a failed call. Check `getStatusCode()`. The client throws `ClientExceptionInterface` only when it cannot send the request or parse the response. That is `RequestExceptionInterface` for a malformed request, and `NetworkExceptionInterface` for a network failure or timeout.
- **The exception-to-response middleware runs first.** PSR-15 section 1.4 RECOMMENDS a component that turns exceptions into responses, and says it SHOULD be the first component executed, wrapping all later processing. Which position runs first depends on the dispatcher. For Slim, see `slim.md`.

### Logging (PSR-3)

- **Put variable data in `$context` and reference it as `{key}`.** Placeholder names MUST match context keys and MUST use single braces with no inner whitespace, and they SHOULD use only `A-Z`, `a-z`, `0-9`, `_`, and `.`. Implementors MAY escape or translate through placeholders, and users SHOULD NOT pre-escape values (PSR-3 section 1.2, <https://www.php-fig.org/psr/psr-3/>). A value concatenated into the message string never reaches that handling.
- **Pass a caught exception as `$context['exception']`.** An `Exception` in context MUST be under the `'exception'` key, which lets the implementation extract a stack trace (PSR-3 section 1.3). `$logger->error($e->getMessage())` logs no trace.
- **Use the eight `Psr\Log\LogLevel` constants.** `log()` with a level the implementation does not know MUST throw `Psr\Log\InvalidArgumentException`, and users SHOULD NOT use a custom level (PSR-3 section 1.1). psr/log 3.0 leaves `$level` untyped, so PHPStan accepts any value.

### Container, events, clock (PSR-11, PSR-14, PSR-20)

- **Do not inject the container so a class can fetch its own dependencies.** Users SHOULD NOT do this. It is the service locator pattern (PSR-11 section 1.3, <https://www.php-fig.org/psr/psr-11/>). The meta document allows it only when the object computes the entry name from a variable set (a router fetching a controller), or in a factory behind an interface (PSR-11 meta section 4, <https://www.php-fig.org/psr/psr-11/meta/>). Do not rely on two `get()` calls returning the same instance (section 1.1.2).
- **A listener returns `void`, and results go on the event.** The dispatcher MUST ignore listener return values and MUST return the same event object it was passed. An exception from a listener MUST stop later listeners and propagate to the emitter (PSR-14, <https://www.php-fig.org/psr/psr-14/>).
- **Read "now" from an injected `Psr\Clock\ClockInterface`.** PSR-20 exists because `time()` and `new \DateTimeImmutable('now')` make mocking the current time impossible (section 1.1, <https://www.php-fig.org/psr/psr-20/>). A test passes a frozen clock. PSR-20 leaves the timezone to the implementation, so call `setTimezone()` where it matters (meta section 4.2, <https://www.php-fig.org/psr/psr-20/meta/>). Which date class to use is `idioms.md`.

### Cache (PSR-6, PSR-16)

- **Keys use `A-Z`, `a-z`, `0-9`, `_`, and `.`, at most 64 characters.** That is all an implementation MUST support, and `{}()/\@:` are reserved and MUST NOT be supported. An illegal key MUST throw `InvalidArgumentException` (PSR-6 Definitions, <https://www.php-fig.org/psr/psr-6/>; PSR-16 section 1.2, <https://www.php-fig.org/psr/psr-16/>). A URL, a path, or `user:42` type-checks and fails at runtime. Hash or encode it.
- **In PSR-16 a cached `null` looks like a miss.** A miss returns `$default`, so a stored `null` cannot be detected (PSR-16 section 1.2). PSR-6 `isHit()` tells "null found" from "not found" and SHOULD be checked on every `get()`. PSR-16 `has()` is for cache warming only, because it races with `get()`.
- **PSR-6 `set()` does not persist.** `CacheItemInterface::set()` sets the value on the item. `CacheItemPoolInterface::save()` persists it, and returns `false` on error instead of throwing (PSR-6 Interfaces).

## Sources

- PSR-3, PSR-6, PSR-7 (and meta), PSR-11 (and meta), PSR-14, PSR-15 (and meta), PSR-16, PSR-17 (and meta), PSR-18, PSR-20 (and meta): <https://www.php-fig.org/psr/> (raw text read from `php-fig/fig-standards` at `229d92c`, 2026-07-03)
- Package versions and PHP constraints, read 2026-09-30: `psr/http-message` 2.0, `psr/log` 3.0.2, `psr/cache` 3.0, `psr/simple-cache` 3.0, `psr/container` 2.0, `psr/http-factory` 1.1, `psr/http-client` 1.0, `psr/http-server-handler` and `psr/http-server-middleware` 1.0, `psr/event-dispatcher` 1.0, `psr/clock` 1.0. <https://packagist.org/packages/psr/>
- psr/log 3.0.2 `LoggerInterface::log()` signature: <https://github.com/php-fig/log/blob/3.0.2/src/LoggerInterface.php>
- PHPStan 2.2.16 unused-call rule: <https://github.com/phpstan/phpstan-src/blob/2.2.16/src/Rules/Methods/CallToMethodStatementWithoutSideEffectsRule.php>
