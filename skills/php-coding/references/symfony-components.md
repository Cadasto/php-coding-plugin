# Symfony components

Read when: `composer.json` requires `symfony/console`, `symfony/process`, `symfony/yaml`, `symfony/http-foundation`, `symfony/event-dispatcher`, `symfony/cache`, or `symfony/dotenv` as a library, or code imports `Symfony\Component\{Console,Process,Yaml,HttpFoundation,EventDispatcher,Cache,Dotenv}` or `Symfony\Contracts\Cache`. Not for the full-stack framework (bundles, `config/packages`, Doctrine, Twig, Flex recipes).

Deterministic backstop: `vendor/bin/phpstan analyse` fails on the APIs Symfony 8.0 removed (`Application::add()`, `Request::get()`). No rule below fails it; each one is run-time behavior.

This file targets **Symfony 8.1**. Its components require `php >= 8.4.1`, so a machine on PHP 8.4.0 cannot install them. The 7.4 LTS line (PHP 8.2+, bug fixes until November 2028) behaves the same unless a bullet says otherwise (<https://symfony.com/releases>). For PSR-6, PSR-14, and PSR-20 semantics, see `psr.md`. For `DateTimeImmutable` in general, see `idioms.md`.

## Console

- **Return the exit code that names the outcome.** `Command::SUCCESS` (0), `Command::FAILURE` (1), or `Command::INVALID` (2) for incorrect usage such as a bad option or a missing argument (<https://symfony.com/doc/current/console.html>).
- **An invokable command's `__invoke()` returns `int`.** No interface lets PHPStan check this. On 8.x `InvokableCommand` throws `TypeError` for any other value. On 7.4 it triggers a deprecation and returns 0, so a failed `void` command reports success (<https://github.com/symfony/symfony/blob/v8.1.8/src/Symfony/Component/Console/Command/InvokableCommand.php>, <https://github.com/symfony/symfony/blob/v7.4.20/src/Symfony/Component/Console/Command/InvokableCommand.php>).
- **Write through `$output` or `SymfonyStyle`, never `echo`.** `--quiet` and `--silent` work because `Output::write()` returns without printing, and `echo` skips that path (<https://symfony.com/doc/current/console/verbosity.html>).
- **Errors go to stderr.** Use `$io->getErrorStyle()` so piped stdout carries only the result. It writes to stdout anyway when the output is not a `ConsoleOutputInterface` (<https://symfony.com/doc/current/console/style.html>).

## Process

- **Pass the command as an array.** `new Process(['git', 'log', $ref])` escapes each argument and is the documented recommended form. Use `Process::fromShellCommandline()` only for shell features such as pipes, and pass values through the env argument as `"${:NAME}"` placeholders (<https://symfony.com/doc/current/components/process.html>). For why, see `security.md`.
- **`run()` does not throw.** It returns the exit code. Check `isSuccessful()`, or call `mustRun()`, which throws `ProcessFailedException` (<https://symfony.com/doc/current/components/process.html>).
- **The default timeout is 60 seconds.** Past it, the process is stopped and `ProcessTimedOutException` is thrown. Call `setTimeout()` for long jobs; `null` disables it (<https://github.com/symfony/symfony/blob/v8.1.8/src/Symfony/Component/Process/Process.php>).
- **A started process dies with its object.** `Process::__destruct()` calls `stop(0)`, so a `start()`ed process whose variable goes out of scope is killed. Keep the reference and call `wait()` (<https://github.com/symfony/symfony/blob/v8.1.8/src/Symfony/Component/Process/Process.php>).

## Yaml

- **Unquoted dates parse to an integer.** `Yaml::parse('2016-05-27')` returns a Unix timestamp (a float when microseconds are present), with UTC assumed when no zone is given. Pass `Yaml::PARSE_DATETIME` to get a `\DateTimeImmutable`, or quote the value to keep a string (<https://symfony.com/doc/current/components/yaml.html>, <https://github.com/symfony/symfony/blob/v8.1.8/src/Symfony/Component/Yaml/Inline.php>).
- **Objects dump as `null` without an error.** Pass `Yaml::DUMP_EXCEPTION_ON_INVALID_TYPE` so `Yaml::dump()` throws instead (<https://symfony.com/doc/current/components/yaml.html>).
- **Untrusted YAML gets no object or constant flags.** `PARSE_OBJECT` runs `unserialize()` and `PARSE_CONSTANT` resolves any PHP constant or enum case. Add `PARSE_EXCEPTION_ON_ALIAS` to reject alias bombs (<https://symfony.com/doc/current/components/yaml.html>). For why, see `security.md`.

## HttpFoundation

- **Arrays come from `all($key)`.** `$request->query->get('ids')` throws `BadRequestException` when the value is an array (`?ids[]=1`). `all('ids')` returns the array, or `[]` when the key is absent (<https://symfony.com/doc/current/components/http_foundation.html>, <https://github.com/symfony/symfony/blob/v8.1.8/src/Symfony/Component/HttpFoundation/InputBag.php>).
- **Typed getters throw, they do not fall back.** On `query` and `request` (both `InputBag`), `getInt()`, `getBoolean()`, and `getEnum()` throw `BadRequestException` for a value they cannot convert. The default applies only when the key is absent (<https://github.com/symfony/symfony/blob/v8.1.8/src/Symfony/Component/HttpFoundation/InputBag.php>).
- **Behind a proxy, trust it by address.** Until `Request::setTrustedProxies()` names the proxies, `getClientIp()`, `isSecure()`, and `getHost()` describe the proxy. Accept traffic only from those proxies, and enable `Request::HEADER_X_FORWARDED_HOST` only when the proxy sets that header (<https://symfony.com/doc/current/deployment/proxies.html>).

## EventDispatcher

- **The event name defaults to the class.** `dispatch($event)` uses `$event::class`, so a listener added under `'order.placed'` never runs. Register under `OrderPlaced::class`, or pass the same name to both calls (<https://symfony.com/doc/current/event_dispatcher.html>, <https://github.com/symfony/symfony/blob/v8.1.8/src/Symfony/Component/EventDispatcher/EventDispatcher.php>).
- **Higher priority runs first.** The default is 0, and equal priorities run in the order they were added (<https://symfony.com/doc/current/event_dispatcher.html>, <https://github.com/symfony/symfony/blob/v8.1.8/src/Symfony/Component/EventDispatcher/EventDispatcher.php>).

## Cache

- **Use `get($key, $callback)` from the contracts.** The docs recommend `Symfony\Contracts\Cache\CacheInterface` over PSR-6 `getItem()`, `isHit()`, and `save()`. It needs less code and protects against stampedes by default, with locking and probabilistic early expiration (<https://symfony.com/doc/current/cache.html>).
- **Set the lifetime inside the callback.** Call `$item->expiresAfter()`. An adapter built with the default `$defaultLifetime = 0` keeps items until they are deleted (<https://symfony.com/doc/current/cache/adapters/filesystem_adapter.html>).
- **Keys are restricted.** Use only `A-Z`, `a-z`, `0-9`, `_`, and `.`. The characters `{}()/\@:` are reserved, and `CacheItem::validateKey()` throws `InvalidArgumentException` at run time, so hash a key built from an email, URL, or path (<https://symfony.com/doc/current/cache.html>, <https://github.com/symfony/symfony/blob/v8.1.8/src/Symfony/Component/Cache/CacheItem.php>).

## Dotenv

- **Read `$_ENV` or `$_SERVER`, not `getenv()`.** `usePutenv` defaults to `false`, so loaded values never reach `getenv()`. Call `usePutenv()` only when a library requires it (<https://github.com/symfony/dotenv>, <https://github.com/symfony/symfony/blob/v8.1.8/src/Symfony/Component/Dotenv/Dotenv.php>).
- **Real environment variables win.** `load()` and `loadEnv()` skip a name already set in the environment unless `overload()` is called or `$overrideExistingVars = true` is passed (<https://symfony.com/doc/current/configuration.html>, <https://github.com/symfony/symfony/blob/v8.1.8/src/Symfony/Component/Dotenv/Dotenv.php>).
- **`loadEnv()` skips `.env.local` in tests.** It loads `.env`, `.env.local`, `.env.$APP_ENV`, then `.env.$APP_ENV.local`, and skips `.env.local` when the env is in `$testEnvs` (default `['test']`). Commit `.env` and `.env.$APP_ENV`, never the `.local` files (<https://symfony.com/doc/current/configuration.html>, <https://github.com/symfony/symfony/blob/v8.1.8/src/Symfony/Component/Dotenv/Dotenv.php>).
- **`.env` files are parsed on every request.** `bootEnv()` reads a dumped `.env.local.php` first when it exists. The component's `dotenv:dump` command writes that file (<https://symfony.com/doc/current/configuration.html>, <https://github.com/symfony/symfony/blob/v8.1.8/src/Symfony/Component/Dotenv/Dotenv.php>).

## Sources

Fetched 2026-09-30. Several `components/` URLs now redirect, and the targets are cited here.

- Symfony releases (8.1 stable, 7.4 LTS, PHP requirements): <https://symfony.com/releases>
- Console: <https://symfony.com/doc/current/console.html>, <https://symfony.com/doc/current/console/verbosity.html>, <https://symfony.com/doc/current/console/style.html>
- Process: <https://symfony.com/doc/current/components/process.html>
- Yaml: <https://symfony.com/doc/current/components/yaml.html>
- HttpFoundation: <https://symfony.com/doc/current/components/http_foundation.html>, <https://symfony.com/doc/current/deployment/proxies.html>
- EventDispatcher: <https://symfony.com/doc/current/event_dispatcher.html>
- Cache: <https://symfony.com/doc/current/cache.html>, <https://symfony.com/doc/current/cache/adapters/filesystem_adapter.html>
- Dotenv: <https://github.com/symfony/dotenv>, <https://symfony.com/doc/current/configuration.html>
- Component source at v8.1.8 (and v7.4.20 for Console): <https://github.com/symfony/symfony/tree/v8.1.8/src/Symfony/Component>
- 8.0 removals: <https://github.com/symfony/symfony/blob/v8.1.8/src/Symfony/Component/Console/CHANGELOG.md>, <https://github.com/symfony/symfony/blob/v8.1.8/src/Symfony/Component/HttpFoundation/CHANGELOG.md>
