---
description: A PSR-15 middleware that discards a with*() result. The PSR reference should explain immutability.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

This PSR-15 middleware should add an `X-Request-Id` header to every response, but clients never see it. PHPStan is green. What's wrong, and what's the fix?

```php
final class RequestIdMiddleware implements MiddlewareInterface
{
    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
    {
        $id = bin2hex(random_bytes(8));
        $request->withAttribute('request_id', $id);
        $response = $handler->handle($request);
        $response->withHeader('X-Request-Id', $id);

        return $response;
    }
}
```
