---
type: llm
weight: 2
---

PASS if the reply says that adding a method to a published interface breaks every existing implementation (the other teams' classes stop compiling or fatal), AND proposes a non-breaking path such as a separate new interface (for example a `RefundableGatewayInterface`) in a minor release, or states that the change requires a new major version (3.0.0).
FAIL if it simply adds `refund()` to `PaymentGatewayInterface` for a 2.x minor release without mentioning the break.
