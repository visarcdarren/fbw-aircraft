#!/bin/bash

set -e

# store current file ownership
ORIGINAL_USER_ID=$(stat -c '%u' /external)
ORIGINAL_GROUP_ID=$(stat -c '%g' /external)

AIRCRAFT_PROJECT_PREFIX="a380x"

# set ownership to root to fix cargo/rust build (when run as github action)
if [ "${GITHUB_ACTIONS}" == "true" ]; then
  chown -R root:root /external
fi

# Loop through the arguments
args=()
for arg in "$@"; do
  # If the argument is "-clean", perform some action
  if [ "$arg" = "-clean" ]; then
    echo "Removing out directories..."
    rm -rf /external/fbw-"${AIRCRAFT_PROJECT_PREFIX}"/out
    rm -rf /external/fbw-"${AIRCRAFT_PROJECT_PREFIX}"/bundles
  else
    # Otherwise, add the arg it to the new array
    args+=("$arg")
  fi
done


if [ "${GITHUB_ACTIONS}" == "true" ]; then
  # run build
  time npx igniter -c "ci.igniter.config.mjs" -r "${AIRCRAFT_PROJECT_PREFIX}" "${args[@]}"
else
  # run build
  time npx igniter -r "${AIRCRAFT_PROJECT_PREFIX}" "${args[@]}"
fi

# restore ownership (when run as github action)
if [ "${GITHUB_ACTIONS}" == "true" ]; then
  chown -R ${ORIGINAL_USER_ID}:${ORIGINAL_GROUP_ID} /external
fi
