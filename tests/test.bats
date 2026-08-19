#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  export GITHUB_REPO=zone1987/ddev-shopware

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p "${HOME}/tmp"
  export TESTDIR="$(mktemp -d "${HOME}/tmp/${PROJNAME}.XXXXXX")"
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"

  # A minimal Shopware-shaped project: the commands locate the shop by looking
  # for a composer.json that requires a shopware/* package.
  mkdir -p shopware/public
  cat > shopware/composer.json <<'EOF'
{
  "name": "test/shopware",
  "require": {
    "shopware/core": "6.7.*"
  }
}
EOF

  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site --docroot=shopware/public
  assert_success
  run ddev start -y
  assert_success
}

health_checks() {
  # shopware-cli must be built into the web image.
  run ddev exec 'command -v shopware-cli'
  assert_success

  # Deployer ships alongside it.
  run ddev exec 'command -v deployer'
  assert_success

  # The commands are registered and documented.
  run ddev build --help
  assert_success
  run ddev watch --help
  assert_success
  run ddev admin-build --help
  assert_success
  run ddev admin-watch --help
  assert_success
  run ddev storefront-build --help
  assert_success
  run ddev storefront-watch --help
  assert_success

  # The internal helper stays out of the command list.
  run ddev help
  assert_success
  refute_output --partial "shopware-cli-command"

  # The watcher ports are published through ddev-router.
  run ddev describe
  assert_success
  assert_output --partial "5173"
  assert_output --partial "9998"

  # The shop is located even though neither working_dir nor composer_root is set,
  # and an unknown scope is rejected rather than silently ignored.
  run ddev exec '.ddev/commands/web/.shopware-cli-command admin-build bogus-mode'
  assert_failure
  assert_output --partial "Unknown mode: bogus-mode"
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1
  # Persist TESTDIR if running inside GitHub Actions. Useful for uploading test result artifacts
  # See example at https://github.com/ddev/github-action-add-on-test#preserving-artifacts
  if [ -n "${GITHUB_ENV:-}" ]; then
    [ -e "${GITHUB_ENV:-}" ] && echo "TESTDIR=${HOME}/tmp/${PROJNAME}" >> "${GITHUB_ENV}"
  else
    [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
  fi
}

@test "install from directory" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}
