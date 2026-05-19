# Microservices Conventions

<!-- STUB — content to be defined with the team -->
<!-- Each section will be filled during the ai-platform setup session -->

## Service Structure

<!-- TODO: discuss with team
     Questions to answer:
     - Standard directory layout inside a service repo?
     - Package naming conventions?
     - Where do interfaces live vs implementations?
     - How are internal packages separated from external/public ones?
-->

## Error Handling

<!-- TODO: discuss with team
     Questions to answer:
     - Do we use sentinel errors, error types, or wrapped messages?
     - How do we propagate context (request ID, trace ID)?
     - What goes in logs vs in the returned error?
     - How do we handle partial failures in multi-step operations?
-->

## API Conventions

<!-- TODO: discuss with team
     Questions to answer:
     - REST or gRPC or both? Versioning strategy?
     - Standard response envelope format?
     - Pagination patterns?
     - How are validation errors returned?
     - Authentication/authorization header conventions?
-->

## Messaging

<!-- TODO: discuss with team
     Questions to answer:
     - Which message broker(s) do we use?
     - Event naming conventions (topic/subject format)?
     - Message envelope format (schema, versioning)?
     - Dead-letter queue handling?
     - Idempotency strategy for consumers?
-->

## Database Access

<!-- TODO: discuss with team
     Questions to answer:
     - ORM vs raw SQL?
     - Where do queries live (repository pattern)?
     - Migration tool and workflow?
     - Connection pool configuration conventions?
-->

## Observability

<!-- TODO: discuss with team
     Questions to answer:
     - Logging library and log format?
     - Metrics: what do we expose and how?
     - Tracing: which instrumentation library?
     - Health check endpoint conventions?
-->

## Configuration

<!-- TODO: discuss with team
     Questions to answer:
     - How is configuration injected (env vars, config files, Vault)?
     - Naming conventions for env vars?
     - How are secrets managed?
-->
