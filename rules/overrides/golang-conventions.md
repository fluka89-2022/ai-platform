# Go Conventions — Team Overrides

<!-- STUB — content to be defined with the team -->
<!-- These explicitly override defaults from cc-skills-golang@samber -->
<!-- Format each section as: OUR RULE > why it differs from the plugin default -->

## Skill Activation — MANDATORY

**Before writing any Go code**, you MUST invoke the relevant `cc-skills-golang:*` skill.
This is not optional. Do not write Go code without first invoking the appropriate skill.

Map the task to the skill:

| Task | Skill to invoke |
| ---- | --------------- |
| Writing or reading tests | `cc-skills-golang:golang-testing` |
| Goroutines, channels, sync, errgroup | `cc-skills-golang:golang-concurrency` |
| Error handling, wrapping, sentinel errors | `cc-skills-golang:golang-error-handling` |
| Structs, interfaces, embedding | `cc-skills-golang:golang-structs-interfaces` |
| CLI commands (cobra/viper) | `cc-skills-golang:golang-spf13-cobra` / `cc-skills-golang:golang-spf13-viper` |
| Database access | `cc-skills-golang:golang-database` |
| Observability, logging, tracing | `cc-skills-golang:golang-observability` |
| gRPC | `cc-skills-golang:golang-grpc` |
| Dependency injection | `cc-skills-golang:golang-dependency-injection` |
| Performance or benchmarks | `cc-skills-golang:golang-performance` |
| Code style and linting | `cc-skills-golang:golang-code-style` |
| Any other Go code | `cc-skills-golang:golang-code-style` (default fallback) |

If multiple skills apply, invoke them in order (process → implementation).

## Naming

<!-- TODO: discuss with team
     Examples of what to cover:
     - Receiver variable names (single letter vs descriptive?)
     - Interface naming (do we use -er suffix strictly?)
     - Error variable naming (err vs specific names?)
     - Test helper naming conventions?
-->

## Package Organization

<!-- TODO: discuss with team
     Examples of what to cover:
     - Do we use internal/ packages? When?
     - cmd/ layout for services with multiple binaries?
     - Shared code: internal package vs separate module?
-->

## Testing

<!-- TODO: discuss with team
     Examples of what to cover:
     - Table-driven tests: always, or only when >2 cases?
     - Test file naming: _test.go always in same package or separate?
     - Which assertion library (testify, standard library)?
     - Integration tests: separate package? build tags?
     - Mock generation: mockgen, moq, manual?
-->

## Dependency Management

<!-- TODO: discuss with team
     Examples of what to cover:
     - Minimum Go version?
     - Allowed external dependencies (any restrictions)?
     - Vendoring: yes or no?
     - How do we handle private modules?
-->

## Concurrency

<!-- TODO: discuss with team
     Examples of what to cover:
     - Context propagation rules?
     - When to use goroutines vs sequential?
     - Channel usage patterns?
     - sync.WaitGroup vs errgroup?
-->

## Logging

<!-- TODO: discuss with team
     Examples of what to cover:
     - Which library (slog, zerolog, zap)?
     - Structured fields we always include?
     - Log levels policy?
-->
