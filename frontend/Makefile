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