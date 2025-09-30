# Avro Schemas for Event Serialization

**Document Ownership**: This document OWNS Avro schema specifications, serialization formats, and Kafka message contracts.

This directory contains Avro schemas for binary event serialization in the Findly Now ecosystem.

## Purpose

Avro schemas provide:
- **Binary serialization** for efficient Kafka message storage
- **Schema evolution** with strong backward/forward compatibility
- **Type safety** at runtime with automatic validation
- **Cross-language support** for polyglot microservices

## Schema Files

Event schemas are organized by domain:

```
avro/
├── posts/
│   ├── post-created.avsc
│   ├── post-updated.avsc
│   ├── post-resolved.avsc
│   └── photo-events.avsc
├── notifications/
│   ├── notification-sent.avsc
│   ├── notification-delivered.avsc
│   └── notification-failed.avsc
├── users/
│   ├── user-registered.avsc
│   └── staff-events.avsc
└── media-ai/
    └── post-enhanced.avsc
```

## Development Workflow

### 1. Creating Avro Schemas

**From JSON Schema:**
```bash
# Convert JSON Schema to Avro
# (Manual process - Avro has stricter requirements)
```

**Direct Avro Creation:**
```bash
# Create new Avro schema
touch avro/domain/event-name.avsc
```

### 2. Schema Validation

```bash
# Validate Avro schema syntax
java -jar avro-tools.jar validate schema.avsc

# Test schema evolution compatibility
java -jar avro-tools.jar compatible --type=backward old.avsc new.avsc
```

### 3. Code Generation

```bash
# Generate Go structs
java -jar avro-tools.jar compile schema avro/posts/ go-output/

# Generate Java classes
java -jar avro-tools.jar compile schema avro/posts/ java-output/

# Generate Python classes
java -jar avro-tools.jar compile schema avro/posts/ python-output/
```

## Schema Evolution Rules

### Compatible Changes
- Adding optional fields with defaults
- Adding new enum symbols
- Expanding union types

### Incompatible Changes
- Removing fields
- Changing field types
- Renaming fields
- Removing enum symbols

## Integration with Services

### Schema Registry

Avro schemas are published to Confluent Schema Registry:

```bash
# Publish schema
curl -X POST \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  --data '{"schema": "..."}' \
  https://schema-registry/subjects/posts.lifecycle-value/versions
```

### Service Implementation

**Go (fn-posts):**
```go
import "github.com/linkedin/goavro/v2"

// Use generated Avro structs
func PublishEvent(event PostCreatedEvent) error {
    // Serialize with Avro
    codec := getAvroCodec("post-created")
    binary, err := codec.BinaryFromNative(nil, event)
    // Publish to Kafka
}
```

**Elixir (fn-notifications):**
```elixir
# Use AvroEx library
def decode_event(binary_data) do
  schema = get_avro_schema("post-created")
  AvroEx.decode(binary_data, schema)
end
```

**Python (fn-media-ai):**
```python
import avro.schema
import avro.io

# Use generated Avro classes
def publish_enhanced_event(event: PostEnhancedEvent):
    schema = avro.schema.parse(open("post-enhanced.avsc").read())
    # Serialize and publish
```

## Future Development

Currently using JSON Schema for development speed. Avro migration planned for production optimization:

**Phase 1:** JSON Schema development and testing
**Phase 2:** Avro schema generation from JSON
**Phase 3:** Production deployment with binary serialization
**Phase 4:** Performance optimization and monitoring

## Tools and Dependencies

**Required:**
- Apache Avro Tools
- Schema Registry CLI
- Language-specific Avro libraries

**Installation:**
```bash
# Download Avro tools
wget https://repo1.maven.org/maven2/org/apache/avro/avro-tools/1.11.1/avro-tools-1.11.1.jar

# Install per language
go get github.com/linkedin/goavro/v2
pip install avro-python3
mix deps.add avrora
```

---

**Note:** This directory structure is prepared for future Avro implementation. Current development uses JSON Schema in `events/schemas/` for rapid iteration and development.