# fn-contract

**Document Ownership**: This document OWNS API and event contract specifications, schema governance, and cross-service integration contracts.

**API and event contracts for Findly Now microservices ecosystem**

## Purpose

Schema governance and contract management for API specifications (OpenAPI) and event schemas (AsyncAPI) across all services.

**Technology**: OpenAPI + AsyncAPI + Confluent Schema Registry

## Quick Start

```bash
# 1. Setup environment
cp .env.example .env
# Edit .env with Schema Registry credentials (see fn-docs/CLOUD-SETUP.md)

# 2. Validate schemas
make validate-schemas

# 3. Publish to registry
make publish-schemas
```

## Schema Structure

- **`api/`** - OpenAPI specifications for REST endpoints
- **`events/`** - AsyncAPI schemas for Kafka events
- **`avro/`** - Avro schemas for event serialization

## Documentation

- **[DEVELOPMENT.md](./DEVELOPMENT.md)** - Schema management guide
- **[../fn-docs/](../fn-docs/)** - Architecture and standards