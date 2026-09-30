# Guzzle — HTTP client

Read when: a diff requires `guzzlehttp/guzzle` or uses `GuzzleHttp\Client`, `GuzzleHttp\Exception\*`, `HandlerStack`, `Middleware::retry`, `MockHandler`, or a request option such as `timeout`, `base_uri`, `json`, `sink`, `stream`, or `verify`.

Deterministic backstop: `vendor/bin/phpstan analyse`. Guzzle 8 declares array shapes for client config and request options, so stricter analysis can report an invalid option key or value type ([UPGRADING](https://github.com/guzzle/guzzle/blob/8.2.0/UPGRADING.md#generic-promise-and-structured-phpdoc-types)). Level 8 also fails `getResponse()` on a `RequestException`, which no longer has it. Nothing checks the rules below.

This file targets **Guzzle 8** (`"php": "^7.4 || ^8.0"`). docs.guzzlephp.org may still show the Guzzle 7 manual; the Guzzle 8 manual is the `docs/` folder at the release tag. Check the constraint in `composer.json` first, because the 7.x line still receives patches and differs in the places listed under **On Guzzle 7**. Moving a repository from 7 means reading [UPGRADING](https://github.com/guzzle/guzzle/blob/8.2.0/UPGRADING.md) first.

## Rules

- **Set `timeout` on every client.** The total `timeout` defaults to `0`, which turns the deadline off. `connect_timeout` (cURL) and `read_timeout` (stream handler) default to 60 seconds ([timeout](https://github.com/guzzle/guzzle/blob/8.2.0/docs/request-options.md#timeout), [connect_timeout](https://github.com/guzzle/guzzle/blob/8.2.0/docs/request-options.md#connect_timeout)). On the cURL handlers only that deadline limits how long receiving headers and the body can take ([timeout phases](https://github.com/guzzle/guzzle/blob/8.2.0/docs/request-options.md#timeout-phases)). Pass `timeout` and `connect_timeout` to the `Client` constructor so they apply to every request ([quick start](https://github.com/guzzle/guzzle/blob/8.2.0/docs/quick-start.md#creating-a-client)).
- **Choose the catch by whether a response exists.** `NetworkException` means no response (`ConnectException`, `ConnectTimeoutException`, `NetworkTimeoutException`). `ResponseException` means a response exists, and only this branch has `getResponse()`. With `http_errors` on (the default), 4xx throws `ClientException` and 5xx throws `ServerException`. Anything else is a plain `RequestException` ([exceptions](https://github.com/guzzle/guzzle/blob/8.2.0/docs/exceptions.md)). Catch them in that order. Catching only `ConnectException` misses `NetworkTimeoutException`. A library that supports Guzzle 7 and 8 catches `Psr\Http\Client\NetworkExceptionInterface` ([UPGRADING](https://github.com/guzzle/guzzle/blob/8.2.0/UPGRADING.md#exception-hierarchy-and-classification)). For chaining the caught exception, see `idioms.md`.
- **`sendRequest()` returns 4xx, 5xx, and redirect responses.** `Client::sendRequest()` sets `http_errors` and `allow_redirects` to `false` for that call, whatever the client config says ([`Client.php`](https://github.com/guzzle/guzzle/blob/8.2.0/src/Client.php#L430-L439), [exceptions](https://github.com/guzzle/guzzle/blob/8.2.0/docs/exceptions.md)). Code typed to `Psr\Http\Client\ClientInterface` must check the status code itself. For the PSR-18 contract, see `psr.md`.
- **Build a stack with `HandlerStack::create()`.** It adds the `http_errors`, `allow_redirects`, `auth`, `cookies`, and `prepare_body` middleware ([`HandlerStack.php`](https://github.com/guzzle/guzzle/blob/8.2.0/src/HandlerStack.php#L56-L66)). `new HandlerStack($handler)` adds none of them, so the `http_errors`, redirect, and cookie options have no effect ([http_errors](https://github.com/guzzle/guzzle/blob/8.2.0/docs/request-options.md#http_errors), [handlers](https://github.com/guzzle/guzzle/blob/8.2.0/docs/handlers.md)).
- **End `base_uri` with `/` and start request paths without one.** Guzzle joins the two by RFC 3986 section 5.2. With `http://foo.com/foo/`, `bar` resolves to `/foo/bar` but `/bar` resolves to `/bar`. With `http://foo.com/foo`, even `bar` resolves to `/bar` ([quick start](https://github.com/guzzle/guzzle/blob/8.2.0/docs/quick-start.md#creating-a-client)).
- **Write HTTP method names in uppercase.** Guzzle 8 sends the method exactly as given, and only exact standard names such as `GET` and `POST` get method-specific handling. `request('get', …)` sends `get` ([UPGRADING](https://github.com/guzzle/guzzle/blob/8.2.0/UPGRADING.md#request-method-casing)).
- **Send bodies with `json`, `form_params`, or `multipart`, not a hand-encoded `body`.** `json` encodes with `JSON_THROW_ON_ERROR` ([`Client.php`](https://github.com/guzzle/guzzle/blob/8.2.0/src/Client.php#L1569-L1576)) and adds `Content-Type: application/json`. `form_params` adds `application/x-www-form-urlencoded`. Only one of the three can be used per request, and none of them together with `body` ([json](https://github.com/guzzle/guzzle/blob/8.2.0/docs/request-options.md#json), [form_params](https://github.com/guzzle/guzzle/blob/8.2.0/docs/request-options.md#form_params), [multipart](https://github.com/guzzle/guzzle/blob/8.2.0/docs/request-options.md#multipart)). `json` does not add `Accept` and takes no `json_encode()` flags. For either, set `body` and the headers directly.
- **Stream large downloads.** The default `sink` is a PHP temp stream, and casting a PSR-7 body to string "could attempt to load a large amount of data into memory" ([sink](https://github.com/guzzle/guzzle/blob/8.2.0/docs/request-options.md#sink), [PSR-7](https://www.php-fig.org/psr/psr-7/)). To write to a file, use `'sink' => $path`. To read in chunks, use `'stream' => true` ([stream](https://github.com/guzzle/guzzle/blob/8.2.0/docs/request-options.md#stream)). When a streamed read stalls it throws `GuzzleHttp\Psr7\Exception\TimeoutException`, and when it fails it throws `\RuntimeException`. Neither extends `GuzzleException`, so catch them around the read loop ([read_timeout](https://github.com/guzzle/guzzle/blob/8.2.0/docs/request-options.md#read_timeout)). A `sink` resource the caller opened is the caller's to close, because Guzzle 8 no longer closes it ([UPGRADING](https://github.com/guzzle/guzzle/blob/8.2.0/UPGRADING.md#sink-resource-ownership)).
- **Retry with `Middleware::retry()`, not a loop around `request()`.** Push it onto `HandlerStack::create()`. `http_errors` is the outermost middleware, so the decider receives a 429 as `$response` and a network failure as `$reason` ([retry](https://github.com/guzzle/guzzle/blob/8.2.0/docs/middleware.md#retry-middleware), [error messages](https://github.com/guzzle/guzzle/blob/8.2.0/docs/middleware.md#customizing-error-messages)). The middleware has no retry limit of its own, so the decider must return `false` after N attempts ([`RetryMiddleware.php`](https://github.com/guzzle/guzzle/blob/8.2.0/src/RetryMiddleware.php)). The manual's conservative policy retries only connection failures and 429. Without a delay callable, the wait doubles each time: 1 s, 2 s, 4 s.
- **Never set `verify` to `false`.** It defaults to `true`, which checks certificates against the system CA bundle. For a private CA, pass the bundle's path as a string ([verify](https://github.com/guzzle/guzzle/blob/8.2.0/docs/request-options.md#verify)). For TLS and secrets beyond this option, see `security.md`.
- **Keep credentials out of request logs and exception messages.** `Middleware::log()` with `MessageFormatter::DEBUG`, or with any template that includes headers, bodies, or URIs, can write credentials, cookies, and tokens. The manual says to avoid those templates in production unless the logs are protected or a processor redacts them ([logging middleware](https://github.com/guzzle/guzzle/blob/8.2.0/docs/middleware.md#logging-middleware)). `ClientException` and `ServerException` messages include a summary of the response body. To cap it, replace the default middleware with `Middleware::httpErrors(new BodySummarizer($bytes))` ([error messages](https://github.com/guzzle/guzzle/blob/8.2.0/docs/middleware.md#customizing-error-messages)).
- **Test with a `MockHandler` wrapped in `HandlerStack::create()`.** Wrapping it keeps `http_errors` and redirects in the path, the same as production. Push `Middleware::history($container)` to assert what was sent. When the mock's queue is empty, the next request throws `OutOfBoundsException` ([testing](https://github.com/guzzle/guzzle/blob/8.2.0/docs/testing-guzzle-clients.md)). Guzzle 8 rejects a per-request `handler` option, so pass the mocked client in through the constructor ([UPGRADING](https://github.com/guzzle/guzzle/blob/8.2.0/UPGRADING.md#per-request-handler-option)). For PHPUnit mechanics, see `testing.md`.

## On Guzzle 7

- **The exception tree is smaller.** There is no `NetworkException` or `ResponseException`. `ConnectException` covers failures with no response, and `BadResponseException` (parent of `ClientException` and `ServerException`) is the branch whose `getResponse()` is never null ([7.15.5 exceptions](https://github.com/guzzle/guzzle/tree/7.15.5/src/Exception)). Catch `Psr\Http\Client\NetworkExceptionInterface` when the code must run on both majors.
- **Method casing, the per-request `handler` option, and `sink` ownership are Guzzle 8 changes.** On 7, `guzzlehttp/psr7` 2.x uppercases the method ([`Request.php`](https://github.com/guzzle/psr7/blob/2.8.0/src/Request.php)); the other rules above apply as written.

```php
$stack = HandlerStack::create();
$stack->push(Middleware::retry(
    static function (
        int $retries,
        RequestInterface $request,
        ?ResponseInterface $response = null,
        mixed $reason = null,
    ): bool {
        return $retries < 3
            && ($reason instanceof ConnectException || $response?->getStatusCode() === 429);
    },
));

$client = new Client([
    'base_uri' => 'https://api.example.test/v2/', // then request 'users', not '/users'
    'handler' => $stack,
    'timeout' => 10.0,
    'connect_timeout' => 3.0,
]);
```

## Sources

- Guzzle 8.2.0 manual (`docs/` at the tag): request options, exceptions, middleware, handlers, quick start, testing. <https://github.com/guzzle/guzzle/tree/8.2.0/docs>
- Guzzle 7 to 8 upgrade guide. <https://github.com/guzzle/guzzle/blob/8.2.0/UPGRADING.md>
- `Client::sendRequest`, `HandlerStack::create`, `RetryMiddleware` source at 8.2.0. <https://github.com/guzzle/guzzle/tree/8.2.0/src>
- Guzzle releases. <https://github.com/guzzle/guzzle/releases>
- PSR-7 `StreamInterface::__toString()`. <https://www.php-fig.org/psr/psr-7/>
