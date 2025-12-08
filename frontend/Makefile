# Generate API client code from OpenAPI spec
generate_api:
	# Run OpenAPI generator from a Docker container
	docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
		-i /local/openapi.json \
		-g dart-dio \
		-o /local/packages/promille_zone \
		--additional-properties=pubName=promille_zone_api,pubVersion=1.0.0 \
		--global-property=apiTests=false,modelTests=false \
		--skip-validate-spec

	# Docker may fuck up ownership, so we fix it here
	sudo chown -R $(shell id -u):$(shell id -g) packages/promille_zone

	# Add unused_import rules to lints so we dont get linting errors inside the code
	echo "    unused_import: ignore" >> packages/promille_zone/analysis_options.yaml

	# Install dependencies of the generated packages
	flutter pub get --directory=packages/promille_zone

	# Run build_runner to generate rest of the code
	cd packages/promille_zone && dart run build_runner build --delete-conflicting-outputs

# Build for Raspberry Pi (ARM64)
build_pi:
	@echo "Building Flutter app for Raspberry Pi (ARM64)..."

	# Build Docker image and create container
	docker buildx build --platform linux/arm64 -f Dockerfile.pi -t promillezone-pi-builder --load .

	# Create output directory
	mkdir -p build/pi

	# Extract binary from container
	@echo "Extracting binary to build/pi/..."
	docker create --name promillezone-pi-temp promillezone-pi-builder
	docker cp promillezone-pi-temp:/app/build/linux/arm64/release/bundle/. build/pi/
	docker rm promillezone-pi-temp

	@echo "Build complete! Binary available in build/pi/"
	@echo "Copy the entire build/pi/ directory to your Raspberry Pi and run ./promillezone"

# Clean Pi build artifacts
clean_pi:
	rm -rf build/pi
	docker rmi promillezone-pi-builder 2>/dev/null || true