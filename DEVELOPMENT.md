# Contract Development Guide

**Schema management and contract governance for Findly Now microservices ecosystem**

## Quick Setup

1. **Environment Configuration**
   ```bash
   cp .env.example .env
   # Edit .env with your Confluent Cloud credentials
   ```

2. **Install Dependencies**
   ```bash
   make install
   ```

3. **Validate Schemas**
   ```bash
   make validate
   ```

## Schema Development Workflow

### 1. Creating New Event Schemas

**Step 1: Define Business Event**
```bash
# Create event schema in events/schemas/
touch events/schemas/new-domain-events.json
```

**Step 2: Add to AsyncAPI Specification**
```bash
# Edit events/asyncapi.yaml
# Add channel, message, and schema reference
```

**Step 3: Validate Schema**
```bash
make validate-schemas
make validate-events
```

**Step 4: Test Schema**
```bash
make validate-schema FILE=events/schemas/new-domain-events.json
```

### 2. Event Schema Structure

All event schemas follow this pattern:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://findlynow.com/schemas/domain-events.json",
  "title": "Domain Events Schema",
  "description": "Event schemas for [domain] in Lost & Found platform",
  "definitions": {
    "BaseEvent": {
      "type": "object",
      "required": ["id", "event_type", "timestamp", "version"],
      "properties": {
        "id": {
          "type": "string",
          "format": "uuid",
          "description": "Unique event identifier"
        },
        "event_type": {
          "type": "string",
          "description": "Type of event"
        },
        "timestamp": {
          "type": "string",
          "format": "date-time",
          "description": "Event occurrence timestamp"
        },
        "version": {
          "type": "integer",
          "minimum": 1,
          "description": "Event schema version"
        }
      }
    }
  }
}
```

### 3. Event Naming Conventions

**Event Types:**
- Use lowercase with dots: `domain.action`
- Examples: `post.created`, `user.registered`, `notification.sent`

**Schema Files:**
- Format: `{domain}-events.json`
- Examples: `post-events.json`, `user-events.json`

**Schema Definitions:**
- Use PascalCase: `PostCreated`, `UserRegistered`
- Match event type: `post.created` → `PostCreated`

### 4. Schema Evolution Rules

**Breaking Changes (require new version):**
- Removing required fields
- Changing field types
- Renaming fields
- Removing enum values

**Non-Breaking Changes (patch version):**
- Adding optional fields
- Adding enum values
- Expanding field descriptions

**Version Strategy:**
```json
{
  "event_type": "post.created",
  "version": 2,  // Increment for breaking changes
  "data": {
    "new_optional_field": "value"  // OK without version bump
  }
}
```

## Schema Registry Integration

### Publishing Schemas

```bash
# Set up environment
export SCHEMA_REGISTRY_URL="https://your-registry.confluent.cloud"
export SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO="api-key:api-secret"

# Publish all schemas
make publish-schemas

# Check compatibility
make check-compatibility
```

### Subject Naming Strategy

**Topics → Subjects:**
- `posts.lifecycle` → `posts.lifecycle-value`
- `users.lifecycle` → `users.lifecycle-value`
- `notifications.delivery` → `notifications.delivery-value`

### Compatibility Levels

- **BACKWARD** (default): New schema can read old data
- **FORWARD**: Old schema can read new data
- **FULL**: Both backward and forward compatible

## Testing Contracts

### Schema Validation Testing

```bash
# Test specific schema
make validate-schema FILE=events/schemas/post-events.json

# Test all schemas
make validate-schemas

# Test AsyncAPI spec
make validate-events
```

## Development Best Practices

### 1. Contract-First Development

**Process:**
1. Define contracts before implementation
2. Validate contracts with stakeholders
3. Generate client/server stubs
4. Implement against contracts
5. Validate implementation compliance

### 2. Schema Review Process

**Requirements:**
- All schema changes require architectural review
- Breaking changes need migration strategy
- Include comprehensive examples
- Maintain DDD alignment

### 3. Business Context Alignment

**Lost & Found Focus:**
- All events support item reunification workflow
- Event names reflect business operations
- Schema optimization for rapid recovery scenarios

---

For more information, see:
- [README.md](./README.md) - Overview and quick start
- [../fn-docs/](../fn-docs/) - Architecture documentation
- [Confluent Schema Registry Docs](https://docs.confluent.io/platform/current/schema-registry/)