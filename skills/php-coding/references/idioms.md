# Idioms — types, exceptions, and language forms on the 8.4 pin

Read when: a diff adds or changes a type, `mixed`, a union, `never`, an array shape, a generic, a comparison, `in_array()` or `array_search()`, `json_decode()` or `json_encode()`, a `throw` or `catch`, an enum or its `from()`, `readonly`, a date, constructor promotion, `match` or `switch`, `#[\Override]`, or a PHP 8.4 or 8.5 feature.

Deterministic backstop: `vendor/bin/phpstan analyse` at level 8 with `phpVersion: 80400`. Levels are cumulative. PHPStan does not check exception handling at all.

## Contents

- Types that PHPStan level 8 does not prove
- Exceptions
- Language forms on the 8.4 pin
- Newer in PHP 8.5 (hints)

## Types that PHPStan level 8 does not prove

Level 8 already fails missing typehints, wrong argument and return types, a method missing on some members of a union, and nullable access. With `phpVersion: 80400` it also reports an implicitly nullable parameter (`string $name = null`). Point those errors at the command; do not restate them. `@PER-CS` owns union and nullable layout. Leave `treatPhpDocTypesAsCertain` at its default (`true`); `false` relaxes checks.

- **`declare(strict_types=1);` in every file.** Without it, a scalar parameter coerces instead of throwing `TypeError` ([type declarations](https://www.php.net/manual/en/language.types.declarations.php)). The reference fixer config adds `declare_strict_types`, which `@PER-CS` lacks. Run the fixer; do not hand-write the header.
- **`===` and `!==`.** `strict_types` does not change `==`, which converts operands first ([comparison](https://www.php.net/manual/en/language.operators.comparison.php)). Use `===` unless the conversion is the point of the line, and say so. Level 8 does not fail `==`.
- **Search arrays strictly.** `in_array()` and `array_search()` use loose comparison unless the third argument `strict` is `true`, so `true` matches any truthy string ([in_array](https://www.php.net/manual/en/function.in-array.php), [array_search](https://www.php.net/manual/en/function.array-search.php)). Pass `true`. `switch` also "does a loose comparison" ([switch](https://www.php.net/manual/en/control-structures.switch.php)); `match` compares with `===`.
- **`never` when the function does not return.** A function that always throws or exits is [`never`](https://www.php.net/manual/en/language.types.never.php), not `void`. Level 8 accepts `void` there.
- **No `mixed` to silence the analyzer.** Only level 9 restricts an explicit `mixed`. At level 8 it type-checks at the boundary and then goes dark. Write the real union or class.
- **An array that is a record has a shape.** `array{id: int, name: string}` for a record, `list<T>` for a list. A bare `array` proves nothing ([PHPDoc types](https://phpstan.org/writing-php-code/phpdoc-types)). Put the shape in `@param` or `@return` next to the native `array`.
- **A function that hands the caller's type back is generic.** `@template T`, then `@param T` and `@return T`. Returning `mixed` drops the type ([PHPDoc basics](https://phpstan.org/writing-php-code/phpdocs-basics)).

## Exceptions

- **Chain the cause.** `Exception::__construct` takes `?Throwable $previous` as its third argument. When catching one failure and throwing another, pass it, or `getPrevious()` returns nothing ([constructor](https://www.php.net/manual/en/exception.construct.php)).
- **A `catch` that does nothing has handled the exception.** Execution continues and the caller never sees the failure ([exceptions](https://www.php.net/manual/en/language.exceptions.php)). An empty body, a log line with no rethrow, and a variable-less `catch` that continues are all swallowing. Handle it, chain and rethrow, or let it bubble.
- **Catch only a type the code can respond to**, specific before general.
  - `LogicException` is an error "that should lead directly to a fix in your code" ([LogicException](https://www.php.net/manual/en/class.logicexception.php)). `InvalidArgumentException` and `DomainException` are the usual ones. Do not catch them and carry on.
  - `RuntimeException` is an error "which can only be found on runtime" ([RuntimeException](https://www.php.net/manual/en/class.runtimeexception.php)): the database, the filesystem, the network. Translate it at the boundary into the caller's type, with `$previous` set.
  - `Error` is for internal PHP errors ([Error](https://www.php.net/manual/en/class.error.php)). Catch `\Throwable` or `\Error` only at the process boundary, such as the global handler or the top of a worker loop.
- **Do not throw from `finally` unless that is the exception meant for the caller.** If `try` and `finally` both throw, the `finally` one wins and the other becomes its previous ([exceptions](https://www.php.net/manual/en/language.exceptions.php)).
- **Make JSON failures throw.** `json_decode()` returns `null` when the input cannot be decoded, which is also what the JSON literal `null` decodes to ([json_decode](https://www.php.net/manual/en/function.json-decode.php)). Pass `JSON_THROW_ON_ERROR` to `json_decode()` and `json_encode()` so a failure throws `JsonException` instead.

## Language forms on the 8.4 pin

Neither `@PER-CS` nor PHPStan level 8 enforces this table. A green build can ship the right-hand column.

| Prefer | Over | Since |
|---|---|---|
| a backed or pure [`enum`](https://www.php.net/manual/en/language.enumerations.php) for a closed set | a class of constants, or string modes | 8.1 |
| [`readonly`](https://www.php.net/manual/en/language.oop5.properties.php) properties, or a `readonly` class | a value object written again after construction | 8.1 / 8.2 |
| [`DateTimeImmutable`](https://www.php.net/manual/en/class.datetimeimmutable.php) | `DateTime` for a value other code still holds; `DateTime` modifies itself | 5.5 |
| [constructor promotion](https://www.php.net/manual/en/language.oop5.decon.php) when the constructor only stores the argument | a parameter, a property, and an assignment | 8.0 |
| [`match`](https://www.php.net/manual/en/control-structures.match.php) when each arm is an expression and a missing arm should throw | a `switch` that only maps a value | 8.0 |
| `public private(set)` asymmetric visibility | a private property plus a getter that only returns it | 8.4 |
| a property hook that only computes or normalizes | a getter and setter pair doing the same | 8.4 |
| `array_find`, `array_any`, `array_all` | a `foreach` whose only job is to search | 8.4 |
| [`#[\Override]`](https://www.php.net/manual/en/class.override.php) on a method meant to override or implement | nothing, so renaming the parent method silently orphans the child; the engine errors instead | 8.3 |
| typed class constants (`public const string PREFIX = 'x';`) | an untyped constant a child class can redefine with another type | 8.3 |
| `#[\Deprecated]` so callers get the engine warning | a docblock `@deprecated` alone | 8.4 |

The 8.3 rows cite the [PHP 8.3 release page](https://www.php.net/releases/8.3/en.php) and the 8.4 rows the [PHP 8.4 release page](https://www.php.net/releases/8.4/en.php). Map input to a backed enum with `tryFrom()` and handle `null`; `from()` throws `ValueError` when no case matches ([from](https://www.php.net/manual/en/backedenum.from.php), [tryFrom](https://www.php.net/manual/en/backedenum.tryfrom.php)). Use `switch` when an arm needs statements. Do not promote a parameter the constructor must normalize first. Do not reach for a property hook when a method name is the API. Rector's PHP 8.4 set can strip the parentheses in `(new Foo())->bar()` that `@PER-CS` puts back; after any Rector run, the fixer runs and wins.

## Newer in PHP 8.5 (hints)

Not required while `composer.json` says `^8.4` and `phpVersion` is `80400`; PHPStan with that pin rejects the syntax, so do not hand-audit the grammar. Source for the table: <https://www.php.net/releases/8.5/en.php>.

| Idiom (8.5) | Supersedes |
|---|---|
| `\|>` to chain a value through callables | nested calls that exist only to thread the value |
| `clone($object, ['field' => $value])` | a with-er that copies every property by hand |
| `Uri\Rfc3986\Uri` | `parse_url` on new code |
| `array_first` / `array_last` | a hand-rolled first or last that special-cases `[]` |
| `#[\NoDiscard]` on a return value that must not be ignored | a docblock warning the engine cannot see |

The backtick operator, an alias of `shell_exec`, is deprecated in 8.5. Do not add new ones. Do not use features from an unreleased PHP version.

## Sources

- PHPStan rule levels and config — <https://phpstan.org/user-guide/rule-levels>, <https://phpstan.org/config-reference>
- PHP manual: type declarations, comparison, `never`, exceptions, exception classes — linked inline above
- PHP 8.3, 8.4, and 8.5 release pages — <https://www.php.net/releases/8.3/en.php>, <https://www.php.net/releases/8.4/en.php>, <https://www.php.net/releases/8.5/en.php>
- PHP manual: `in_array`, `array_search`, `switch`, `json_decode`, `BackedEnum::from` and `tryFrom`, `Override` — linked inline above
