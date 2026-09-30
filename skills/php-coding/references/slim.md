# Slim 4 applications

Read when: `composer.json` requires `slim/slim` or `php-di/slim-bridge`, or code uses `Slim\App`, `Slim\Factory\AppFactory`, `DI\Bridge\Slim\Bridge`, `$app->get(`, `$app->add(`, `addErrorMiddleware()`, `RouteContext`, or a `Slim\Exception\Http*Exception`.

Deterministic backstop: none. `vendor/bin/phpstan analyse` at level 8 accepts any order of `$app->add()` calls, any flags passed to `addErrorMiddleware()`, and route closures in any strategy's shape.

Targets **Slim 4**. Its `php` constraint runs to `~8.5.0`, so it installs on the 8.4 pin (<https://github.com/slimphp/Slim/releases>). Do not target an unreleased Slim 5 development branch. Slim is built on PSR-7, PSR-15, PSR-17, and PSR-11, and those contract rules (immutable `with*()`, streams, factories, service locator) are in `psr.md`. Monolog setup is in `monolog.md`.

## Rules

- **Middleware runs last-added-first.** Slim processes middleware LIFO, so the last one added is the first executed (<https://www.slimframework.com/docs/v4/concepts/middleware.html>). Add body parsing before routing, and the error middleware last (<https://www.slimframework.com/docs/v4/middleware/body-parsing.html>). The error middleware does not handle exceptions from middleware added after it. Routing must be added before it, or routing exceptions go unhandled (<https://www.slimframework.com/docs/v4/middleware/error-handling.html>).

  ```php
  $app->addBodyParsingMiddleware();
  $app->add(NeedsRouteMiddleware::class);   // runs after routing
  $app->addRoutingMiddleware();
  $app->addErrorMiddleware($displayErrorDetails, true, true, $logger); // outermost, runs first
  ```

- **Middleware that reads `RouteContext` is added before `addRoutingMiddleware()`.** Only then has routing run when it executes (<https://www.slimframework.com/docs/v4/cookbook/retrieving-current-route.html>). `RouteContext::fromRequest()` throws `RuntimeException` before routing has completed ([source](https://github.com/slimphp/Slim/blob/4.15.3/Slim/Routing/RouteContext.php)).
- **`displayErrorDetails` is `false` in production.** The docs say the first argument of `addErrorMiddleware()` should be false in production, yet every example passes `true` (<https://www.slimframework.com/docs/v4/middleware/error-handling.html>). Read it from configuration, not a literal.
- **Pass the app's PSR-3 logger as the fourth argument.** With `logErrors` on and no logger, `ErrorHandler` falls back to `Slim\Logger`, which writes through `error_log()` ([ErrorHandler](https://github.com/slimphp/Slim/blob/4.15.3/Slim/Handlers/ErrorHandler.php), [Logger](https://github.com/slimphp/Slim/blob/4.15.3/Slim/Logger.php)).
- **Throw an `HttpException` subclass for an HTTP outcome.** The default handler uses an `HttpException`'s code as the status, and returns `500` for any other throwable ([source](https://github.com/slimphp/Slim/blob/4.15.3/Slim/Handlers/ErrorHandler.php), `determineStatusCode()`). A domain "not found" exception becomes a 500 unless the code throws `HttpNotFoundException($request)` or another class from the docs list, or map the type with `setErrorHandler()`. For a code Slim lacks, extend `HttpSpecializedException` (<https://www.slimframework.com/docs/v4/middleware/error-handling.html>).
- **`setErrorHandler()` matches the exact class unless `$handleSubclasses` is `true`.** The third argument defaults to `false`. A handler mapped to a base exception class never sees its subclasses unless `true` is passed ([source](https://github.com/slimphp/Slim/blob/4.15.3/Slim/Middleware/ErrorMiddleware.php)).
- **A custom error handler sets the status.** The docs' custom handler calls `createResponse()` with no code, and PSR-17 defaults that to `200` (<https://www.php-fig.org/psr/psr-17/>). Pass the status, as the built-in `ErrorHandler::respond()` does with `createResponse($this->statusCode)`.
- **JSON and XML request bodies need `addBodyParsingMiddleware()`.** PSR-7 implementations do not parse those formats out of the box. Without the middleware, the handler must decode `getBody()` itself (<https://www.slimframework.com/docs/v4/middleware/body-parsing.html>).
- **Write to `$response->getBody()` and return the response.** Since Slim 4 a route callback must return a `ResponseInterface`. `echo` reaches the response only through the Output Buffering Middleware (<https://www.slimframework.com/docs/v4/objects/routing.html>, "Writing content to the response"). For JSON, return the copy from `withHeader('Content-Type', 'application/json')` (<https://www.slimframework.com/docs/v4/objects/response.html>, "Returning JSON").
- **Set the container before creating the app.** Call `AppFactory::setContainer()` before `AppFactory::create()`, or use `AppFactory::createFromContainer()` (<https://www.slimframework.com/docs/v4/concepts/di.html>). With PHP-DI, use `DI\Bridge\Slim\Bridge::create($container)` (<https://php-di.org/doc/frameworks/slim.html>).
- **With the PHP-DI bridge, parameter names are the wiring.** The request and response parameters must be named `$request` and `$response`. Route placeholders and request attributes go into the parameter with the same name (<https://php-di.org/doc/frameworks/slim.html>). Renaming `$request` to `$req`, or `$id` to `$userId`, still type-checks.
- **Do not make route or middleware closures `static`.** Slim does not support static closures (<https://www.slimframework.com/docs/v4/objects/routing.html>, "Closure binding"). When a container is set, `CallableResolver` binds every closure to it with `Closure::bindTo()` ([source](https://github.com/slimphp/Slim/blob/4.15.3/Slim/CallableResolver.php)). A static closure cannot be bound, and `bindTo()` returns `null` with a warning (<https://www.php.net/manual/en/closure.bindto.php>). php-cs-fixer's risky `static_lambda` rule, which is not in `@PER-CS`, adds `static`. Keep it off for Slim code (<https://cs.symfony.com/doc/rules/function_notation/static_lambda.html>).
- **Set the base path when the app is served from a subdirectory.** Slim 4 no longer detects it, so it must be declared, with `$app->setBasePath('/my-app')` right after `AppFactory::create()` (<https://www.slimframework.com/docs/v4/start/upgrade.html>, <https://www.slimframework.com/docs/v4/start/web-servers.html>).
- **Change the invocation strategy before defining routes.** `setDefaultInvocationStrategy()` applies only to routes defined after the call (<https://www.slimframework.com/docs/v4/objects/routing.html>, "Route strategies"). `RouteCollector::createRoute()` captures the strategy when the route is created ([source](https://github.com/slimphp/Slim/blob/4.15.3/Slim/Routing/RouteCollector.php)). The default `RequestResponse` passes placeholders as one `array $args`. `RequestResponseArgs` passes each placeholder as its own argument. A callback written for the other strategy gets the wrong arguments.

## Sources

- Slim 4 docs: middleware, error handling, body parsing, routing middleware, current route, routing, response, DI, upgrade, web servers. <https://www.slimframework.com/docs/v4/> (raw text read from `slimphp/Slim-Website` `gh-pages` at `193ec4f`, 2026-09-30)
- Slim 4.15.3 release and source (latest on 2026-09-30; Slim 5 had no release): <https://github.com/slimphp/Slim/releases/tag/4.15.3>, <https://github.com/slimphp/Slim/tree/4.15.3/Slim>
- PHP-DI Slim bridge 3.4.1: <https://php-di.org/doc/frameworks/slim.html>, <https://github.com/PHP-DI/Slim-Bridge/blob/3.4.1/README.md>
- `Closure::bindTo`: <https://www.php.net/manual/en/closure.bindto.php>
- PSR-17 `createResponse()` default: <https://www.php-fig.org/psr/psr-17/>
