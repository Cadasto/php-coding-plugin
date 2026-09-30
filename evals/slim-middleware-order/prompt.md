---
description: Slim 4 bootstrap with a middleware-order bug. The Slim reference should lead to LIFO order and production-safe error details.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

Our Slim 4 app returns raw HTML errors for JSON routes and exceptions thrown in routing don't get our error handler. Here's the bootstrap. What should change?

```php
$app = AppFactory::create();
$app->addErrorMiddleware(true, true, true);
$app->addRoutingMiddleware();
$app->addBodyParsingMiddleware();
$app->add(new AuthMiddleware());

$app->post('/orders', CreateOrderAction::class);
$app->run();
```
