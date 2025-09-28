# Findly Now - Service Contracts Makefile
#
# Schema validation, documentation generation, and contract testing
# for API and event contracts across the microservices ecosystem.

.PHONY: help validate validate-api validate-events validate-schemas docs clean install

# Default target
help:
	@echo "Findly Now Contract Management"
	@echo "=============================="
	@echo ""
	@echo "Available targets:"
	@echo "  validate           - Validate all contracts and schemas"
	@echo "  validate-api       - Validate OpenAPI specifications"
	@echo "  validate-events    - Validate AsyncAPI specifications"
	@echo "  validate-schemas   - Validate JSON schemas"
	@echo "  docs               - Generate contract documentation"
	@echo "  install            - Install validation dependencies"
	@echo "  clean              - Clean generated files"
	@echo ""
	@echo "Schema Registry:"
	@echo "  publish-schemas    - Publish schemas to Confluent Schema Registry"
	@echo "  check-compatibility - Check schema compatibility"
	@echo ""

# Install validation dependencies
install:
	@echo "Installing contract validation dependencies..."
	npm install -g @apidevtools/swagger-cli @asyncapi/cli ajv-cli redoc-cli
	@echo "Dependencies installed successfully"

# Validate all contracts and schemas
validate: validate-api validate-events validate-schemas
	@echo "✅ All contracts and schemas are valid"

# Validate OpenAPI specifications
validate-api:
	@echo "Validating OpenAPI specifications..."
	@for file in api/*.yaml; do \
		echo "Validating $$file..."; \
		swagger-cli validate "$$file" || exit 1; \
	done
	@echo "✅ OpenAPI specifications valid"

# Validate AsyncAPI specifications
validate-events:
	@echo "Validating AsyncAPI specifications..."
	@for file in events/*.yaml; do \
		echo "Validating $$file..."; \
		asyncapi validate "$$file" || exit 1; \
	done
	@echo "✅ AsyncAPI specifications valid"

# Validate JSON schemas
validate-schemas:
	@echo "Validating JSON schemas..."
	@for file in events/schemas/*.json shared/*.json; do \
		if [ -f "$$file" ]; then \
			echo "Validating $$file..."; \
			ajv validate -s "$$file" -d /dev/null --spec=draft7 || exit 1; \
		fi \
	done
	@echo "✅ JSON schemas valid"

# Generate contract documentation
docs:
	@echo "Generating contract documentation..."
	@mkdir -p docs/api docs/events

	# Generate OpenAPI documentation
	@for file in api/*.yaml; do \
		base=$$(basename "$$file" .yaml); \
		echo "Generating docs for $$file..."; \
		redoc-cli build "$$file" --output "docs/api/$$base.html"; \
	done

	# Generate AsyncAPI documentation
	@for file in events/*.yaml; do \
		base=$$(basename "$$file" .yaml); \
		echo "Generating docs for $$file..."; \
		asyncapi generate html "$$file" --output "docs/events/$$base.html"; \
	done

	@echo "✅ Documentation generated in docs/ directory"

# Schema Registry operations (requires Confluent Cloud credentials)
publish-schemas:
	@echo "Publishing schemas to Confluent Schema Registry..."
	@if [ -z "$$SCHEMA_REGISTRY_URL" ]; then \
		echo "❌ SCHEMA_REGISTRY_URL environment variable not set"; \
		exit 1; \
	fi
	@if [ -z "$$SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO" ]; then \
		echo "❌ SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO environment variable not set"; \
		exit 1; \
	fi

	# Publish post event schemas
	@echo "Publishing post event schemas..."
	@curl -X POST \
		-H "Content-Type: application/vnd.schemaregistry.v1+json" \
		-u "$$SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO" \
		--data @events/schemas/post-events.json \
		"$$SCHEMA_REGISTRY_URL/subjects/posts.events-value/versions"

	# Publish notification event schemas
	@echo "Publishing notification event schemas..."
	@curl -X POST \
		-H "Content-Type: application/vnd.schemaregistry.v1+json" \
		-u "$$SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO" \
		--data @events/schemas/notification-events.json \
		"$$SCHEMA_REGISTRY_URL/subjects/notifications.delivery-value/versions"

	# Publish user event schemas
	@echo "Publishing user event schemas..."
	@curl -X POST \
		-H "Content-Type: application/vnd.schemaregistry.v1+json" \
		-u "$$SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO" \
		--data @events/schemas/user-events.json \
		"$$SCHEMA_REGISTRY_URL/subjects/users.lifecycle-value/versions"

	@echo "✅ Schemas published to Schema Registry"

# Check schema compatibility with existing versions
check-compatibility:
	@echo "Checking schema compatibility..."
	@if [ -z "$$SCHEMA_REGISTRY_URL" ]; then \
		echo "❌ SCHEMA_REGISTRY_URL environment variable not set"; \
		exit 1; \
	fi
	@if [ -z "$$SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO" ]; then \
		echo "❌ SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO environment variable not set"; \
		exit 1; \
	fi

	# Check post events compatibility
	@curl -X POST \
		-H "Content-Type: application/vnd.schemaregistry.v1+json" \
		-u "$$SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO" \
		--data @events/schemas/post-events.json \
		"$$SCHEMA_REGISTRY_URL/compatibility/subjects/posts.events-value/versions/latest"

	@echo "✅ Schema compatibility checked"

# Lint all contract files
lint:
	@echo "Linting contract files..."
	@echo "Checking YAML formatting..."
	@find . -name "*.yaml" -o -name "*.yml" | xargs yamllint -d relaxed
	@echo "Checking JSON formatting..."
	@find . -name "*.json" | xargs jq . > /dev/null
	@echo "✅ All files properly formatted"

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	@rm -rf docs/
	@echo "✅ Cleaned generated documentation"

# Development helpers
dev-setup: install
	@echo "Setting up development environment..."
	@echo "Contract validation tools installed"
	@echo ""
	@echo "Environment variables needed for Schema Registry:"
	@echo "  export SCHEMA_REGISTRY_URL=https://your-registry-url"
	@echo "  export SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO=api-key:api-secret"

# Validate specific schema file
validate-schema:
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make validate-schema FILE=path/to/schema.json"; \
		exit 1; \
	fi
	@echo "Validating schema: $(FILE)"
	@ajv validate -s "$(FILE)" -d /dev/null --spec=draft7
	@echo "✅ Schema $(FILE) is valid"

# Contract testing targets
test-contracts:
	@echo "Running contract tests..."
	@echo "⚠️  Contract testing not yet implemented"
	@echo "TODO: Implement Pact consumer-driven contract testing"

# Event flow validation
validate-flow:
	@echo "Validating event flow consistency..."
	@echo "Checking that all events published by services have consumers..."
	@echo "Checking that all events consumed by services are published..."
	@echo "⚠️  Event flow validation not yet implemented"
	@echo "TODO: Implement cross-service event flow validation"