# Event Contract Compatibility Guidelines

**Document Ownership**: This document OWNS schema evolution policies, backward compatibility rules, and version management strategies.

This document defines the backward compatibility strategy and version management for all event contracts in the Findly Now ecosystem.

## Privacy-First Architecture Rules

### 🚨 CRITICAL: NO PII IN EVENTS

**Fundamental Principle**: Event schemas MUST NOT contain Personally Identifiable Information (PII).

**Prohibited Fields** (Will cause immediate rejection):
- `email` - Email addresses
- `phone` - Phone numbers
- `full_name` - Complete names
- `address` - Physical addresses
- `ssn` - Social security numbers
- `passport` - Passport numbers
- `credit_card` - Payment information
- `ip_address` - IP addresses
- Any field that can identify an individual

**Allowed Privacy-Safe Fields**:
- `user_id` - Opaque identifiers
- `display_name` - Privacy-safe display names (e.g., "John D")
- `organization_id` - Organization identifiers
- `timezone` - Timezone preferences
- `language` - Language preferences
- `preferences` - Non-identifying settings

### Contact Exchange Security

Contact information sharing MUST use the secure token pattern:

**✅ CORRECT - Privacy-Safe Pattern**:
```json
{
  "contact_token": {
    "token": "encrypted_contact_data_token",
    "expires_at": "2025-01-15T12:00:00Z",
    "contact_methods": ["email", "phone"],
    "restrictions": {
      "single_use": true,
      "platform_mediated": false
    }
  }
}
```

**❌ INCORRECT - PII Violation**:
```json
{
  "contact_info": {
    "email": "user@example.com", // ❌ PII in event
    "phone": "+1234567890"       // ❌ PII in event
  }
}
```

### PrivacySafeUser Pattern

All events MUST use the `PrivacySafeUser` schema reference instead of raw user data:

**✅ CORRECT**:
```json
{
  "user": {
    "$ref": "../../shared/domains.json#/definitions/PrivacySafeUser"
  }
}
```

**❌ INCORRECT**:
```json
{
  "user": {
    "email": "user@example.com",  // ❌ PII violation
    "full_name": "John Doe"       // ❌ PII violation
  }
}
```

## Contract Versioning Strategy

### Schema Evolution Rules

**BREAKING CHANGES** (require major version bump):
- Adding PII fields to events (NEVER ALLOWED - immediate rejection)
- Removing required fields
- Changing field types (e.g., string → integer)
- Renaming fields
- Changing event_type values
- Modifying enum values (removing options)
- Changing the structure of nested objects
- Replacing PrivacySafeUser references with raw user data

**NON-BREAKING CHANGES** (minor version bump):
- Adding optional fields
- Adding new enum values
- Adding new event types
- Extending nested objects with optional fields
- Adding nullable properties

**PATCH CHANGES**:
- Documentation updates
- Example corrections
- Schema description improvements

### Event Type Stability

All event types are considered **immutable** once published:

#### Post Events (`posts.events` topic)
- `post.created` - **STABLE** since v1.0.0
- `post.updated` - **STABLE** since v1.0.0
- `post.resolved` - **STABLE** since v1.0.0
- `post.deleted` - **STABLE** since v1.0.0
- `post.photo.added` - **STABLE** since v1.0.0
- `post.photo.removed` - **STABLE** since v1.0.0

#### Matching Events (`posts.matching` topic)
- `post.matched` - **STABLE** since v1.0.0
- `post.claimed` - **STABLE** since v1.0.0
- `match.confirmed` - **STABLE** since v1.2.0 (PRIVACY-SAFE)
- `match.expired` - **STABLE** since v1.1.0

#### AI Enhancement Events (`media-ai.enrichment` topic)
- `post.enhanced` - **STABLE** since v1.0.0
- `photo.processed` - **STABLE** since v1.2.0 (PRIVACY-SAFE)

#### User Events (`users.events` topic)
- `user.registered` - **STABLE** since v1.0.0 (PRIVACY-SAFE)
- `user.updated` - **STABLE** since v1.2.0 (PRIVACY-SAFE)
- `organization.staff_added` - **STABLE** since v1.0.0 (PRIVACY-SAFE)
- `communication.opt_in` - **STABLE** since v1.0.0 (PRIVACY-SAFE)

#### Contact Exchange Events (`contact.exchange` topic)
- `contact.exchange.requested` - **STABLE** since v1.0.0 (PRIVACY-SAFE)
- `contact.exchange.approved` - **STABLE** since v1.2.0 (PRIVACY-SAFE, token-based)
- `contact.exchange.denied` - **STABLE** since v1.0.0 (PRIVACY-SAFE)
- `contact.exchange.expired` - **STABLE** since v1.0.0 (PRIVACY-SAFE)

#### Notification Events (`notifications.delivery` topic)
- `notification.sent` - **STABLE** since v1.0.0
- `notification.delivered` - **STABLE** since v1.0.0
- `notification.failed` - **STABLE** since v1.0.0

## Topic Naming Conventions

### Current Standard (v1.0.0+)
- `posts.events` - Unified topic for all post lifecycle events
- `posts.matching` - Matching and claiming events
- `users.events` - User and organization events
- `media-ai.enrichment` - AI enhancement events
- `notifications.delivery` - Notification delivery status events

### Migration from Legacy Names

**DEPRECATED** topic names (still supported but discouraged):
- ~~`posts.lifecycle`~~ → Use `posts.events`
- ~~`post-events`~~ → Use `posts.events`

**Migration Timeline:**
- **Phase 1** (Current): Both old and new topic names supported
- **Phase 2** (v2.0.0): Legacy topics deprecated with warnings
- **Phase 3** (v3.0.0): Legacy topics removed

## Field Compatibility Matrix

### BaseEvent Fields (All Events)
| Field | Type | Since | Status | Notes |
|-------|------|-------|--------|-------|
| `id` | string(uuid) | v1.0.0 | **STABLE** | Unique event identifier |
| `event_type` | string | v1.0.0 | **STABLE** | Cannot be changed once published |
| `timestamp` | string(date-time) | v1.0.0 | **STABLE** | ISO 8601 format required |
| `version` | integer | v1.0.0 | **STABLE** | Schema version, minimum 1 |

### Post Event Fields
| Field | Type | Since | Status | Notes |
|-------|------|-------|--------|-------|
| `post_id` | string(uuid) | v1.0.0 | **STABLE** | Post identifier |
| `user_id` | string | v1.0.0 | **STABLE** | User who triggered event |
| `tenant_id` | string(uuid) | v1.0.0 | **STABLE** | Organization ID (nullable) |
| `data` | object | v1.0.0 | **STABLE** | Event-specific payload |

### Photo Fields
| Field | Type | Since | Status | Notes |
|-------|------|-------|--------|-------|
| `original_url` | string(uri) | v1.0.0 | **STABLE** | Original photo URL |
| `thumbnail_url` | string(uri) | v1.0.0 | **STABLE** | Thumbnail URL (nullable) |
| `filename` | string | v1.0.0 | **STABLE** | Original filename |
| `file_size` | integer | v1.0.0 | **STABLE** | Size in bytes |
| `mime_type` | string | v1.0.0 | **STABLE** | MIME type |
| `width` | integer | v1.0.0 | **STABLE** | Image width in pixels |
| `height` | integer | v1.0.0 | **STABLE** | Image height in pixels |
| `order` | integer | v1.1.0 | **STABLE** | Display order within post |

## Consumer Compatibility Guidelines

### Required Fields
All consumers MUST handle:
- Unknown optional fields (ignore gracefully)
- New enum values (use fallback behavior)
- Additional properties in nested objects

### Recommended Patterns

#### Defensive Event Processing
```json
{
  "event_handler": {
    "ignore_unknown_fields": true,
    "validate_required_fields": true,
    "log_schema_warnings": true
  }
}
```

#### Version Checking
```json
{
  "if": { "properties": { "version": { "minimum": 2 } } },
  "then": { "process_v2_features": true },
  "else": { "use_v1_fallback": true }
}
```

### Error Handling
- **Unknown event_type**: Log warning, skip processing
- **Missing required field**: Log error, send to DLQ
- **Invalid field type**: Log error, attempt type coercion
- **Future schema version**: Process with current schema, log info

## Producer Guidelines

### Adding New Events
1. Create event schema in `events/schemas/`
2. Add to AsyncAPI specification
3. Update this compatibility document
4. Implement with version 1
5. Test with existing consumers

### Modifying Existing Events
1. **NEVER** remove or rename required fields
2. **NEVER** change field types
3. **ALWAYS** add new fields as optional
4. **ALWAYS** increment schema version
5. Update examples and documentation

### Schema Validation
All events MUST pass validation against:
- JSON Schema definitions
- AsyncAPI specification
- Backward compatibility tests
- **Privacy compliance validation (NO PII)**

### Privacy Validation Rules

**Automated PII Detection**:
Events are automatically scanned for prohibited fields:
```bash
# Example validation that WILL REJECT the schema
{
  "email": "any@email.com",     # ❌ REJECTED
  "phone": "+1234567890",       # ❌ REJECTED
  "full_name": "John Doe",      # ❌ REJECTED
  "address": "123 Main St"      # ❌ REJECTED
}
```

**Required Patterns**:
- Use `PrivacySafeUser` for all user references
- Use `ContactExchangeToken` for contact sharing
- Replace direct contact info with encrypted tokens
- Ensure `display_name` contains no full names

**GDPR/CCPA Compliance**:
- Events can be freely logged and replayed
- No data deletion required for event streams
- Privacy-safe for cross-border data transfer
- Supports right-to-be-forgotten without event modification

## Breaking Change Process

### When Breaking Changes Are Required

Breaking changes should be **extremely rare** and only considered for:
- Critical security vulnerabilities
- Legal/compliance requirements
- Fundamental architectural changes

### Process
1. **RFC Creation**: Document the need and impact
2. **Stakeholder Review**: All consuming services must approve
3. **Migration Plan**: Detailed transition timeline
4. **Parallel Support**: Old and new versions run simultaneously
5. **Gradual Migration**: Consumer-by-consumer transition
6. **Deprecation**: Mark old version as deprecated
7. **Sunset**: Remove old version after minimum 6 months

### Communication
- Slack announcement in #platform-changes
- Email to service teams
- Update in service documentation
- Breaking change tickets for all consumers

## Testing Strategy

### Compatibility Test Suite
- **Forward Compatibility**: New producers → Old consumers
- **Backward Compatibility**: Old producers → New consumers
- **Cross-Version**: All combinations of schema versions

### Automated Validation
- Schema validation in CI/CD pipeline
- Consumer contract tests
- Producer contract tests
- End-to-end event flow tests

## Monitoring & Alerting

### Schema Version Metrics
- Track event version distribution
- Monitor deprecated field usage
- Alert on schema validation failures

### Consumer Health
- Track processing success rates by event type
- Monitor DLQ (Dead Letter Queue) volumes
- Alert on unknown event types

## Emergency Procedures

### Schema Rollback
1. Identify problematic schema version
2. Rollback producer deployments
3. Verify consumer recovery
4. Post-incident review

### Consumer Recovery
1. Fix consumer compatibility issues
2. Replay failed events from DLQ
3. Verify processing resumption
4. Update consumer contract tests

## Contact Information

For questions about contract compatibility:
- **Contracts Team**: #contracts-support
- **Platform Team**: #platform-support
- **Emergency**: Page platform-oncall

---

**Last Updated**: 2025-01-15
**Document Version**: 1.0.0
**Next Review**: 2025-04-15