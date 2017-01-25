#!/usr/bin/env bash
set -e
diff <(./bin/check.sh) check_output
