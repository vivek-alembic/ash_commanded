#!/bin/bash

set -e

echo "Running section tests..."
mix test test/commanded/sections/

echo "Running DSL tests..."
mix test test/commanded/commands_dsl_test.exs test/commanded/dsl_test.exs test/commanded/events_dsl_test.exs test/commanded/projections_dsl_test.exs

echo "Running transformer tests (excluding verifier tests)..."
mix test test/commanded/transformers/ --exclude verifier_test

echo "Running verifier tests..."
mix test test/commanded/verifiers/ --include verifier_test

echo "All tests passed!"