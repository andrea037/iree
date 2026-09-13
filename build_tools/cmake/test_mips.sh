#!/bin/bash

# Copyright 2026 The IREE Authors
#
# Licensed under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

# Test the cross-compiled MIPS 64-bit Linux targets.
#
# The desired build directory can be passed as the first argument. Otherwise, it
# uses the environment variable IREE_TARGET_BUILD_DIR, defaulting to
# "build-mips". Designed for CI, but can be run manually. Expects to be run
# from the root of the IREE repository.

set -xeuo pipefail

BUILD_DIR="${1:-${IREE_TARGET_BUILD_DIR:-build-mips}}"
MIPS_PLATFORM="${IREE_TARGET_PLATFORM:-linux}"
MIPS_ARCH="${IREE_TARGET_ARCH:-mips_64}"

export CTEST_PARALLEL_LEVEL=${CTEST_PARALLEL_LEVEL:-$(nproc)}

ctest_args=(
  "--timeout 900"
  "--output-on-failure"
  "--no-tests=error"
)

declare -a label_exclude_args=(
  "^nodocker$"
  "^driver=vulkan$"
  "^driver=metal$"
  "^driver=cuda$"
  "^driver=hip$"
  "^vulkan_uses_vk_khr_shader_float16_int8$"
  "^requires-filesystem$"
  "^requires-dtz$"
  "^nomips$"
)

# TODO(#10462): not included in phase 1
declare -a test_exclude_args=(
  "regression_llvm-cpu_lowering_config"
)

# Known MIPS-alignment failures under qemu-mips64el, excluded from the Phase 1
# gate. Each fails with SIGBUS (unaligned memory access in a binary/data parser
# that QEMU user-mode does not fix up). Only these specific
# broken tests are skipped; the many passing tokenizer/tooling tests still run
declare -a runtime_test_exclude_args=(
  # ELF loader: unused by VMVX (guide Phase 1: "No ELF loader work").
  "iree/hal/local/elf/elf_module_test"
  # Profiling / command-stream replay tooling.
  "iree/hal/local/profile_test"
  "iree/hal/replay/execute_test"
  "iree/tooling/profile/cli_test"
  # GGUF weight-file parser.
  "iree/io/formats/gguf/gguf_parser_test"
  # LLM tokenizer: JSON / tiktoken / regex / segmenter parsers.
  "iree/tokenizer/special_tokens_test"
  "iree/tokenizer/tokenizer_encode_test"
  "iree/tokenizer/tokenizer_huggingface_test"
  "iree/tokenizer/tokenizer_consistency_test"
  "iree/tokenizer/format/huggingface/segmenter_json_test"
  "iree/tokenizer/format/huggingface/tokenizer_json_test"
  "iree/tokenizer/format/tiktoken/tiktoken_test"
  "iree/tokenizer/model/unigram_test"
  "iree/tokenizer/regex/exec_benchmark_test"
  "iree/tokenizer/regex/compile_test"
  "iree/tokenizer/regex/compile_benchmark_test"
  "iree/tokenizer/regex/regex_test"
  "iree/tokenizer/segmenter/split_test"
)

# Test runtime unit tests
runtime_label_exclude_regex="($(IFS="|" ; echo "${label_exclude_args[*]}"))"
runtime_test_exclude_regex="($(IFS="|" ; echo "${runtime_test_exclude_args[*]}"))"
runtime_ctest_args=(
  "--test-dir ${BUILD_DIR}/runtime/"
  ${ctest_args[@]}
  "--label-exclude ${runtime_label_exclude_regex}"
  "--exclude-regex ${runtime_test_exclude_regex}"
)

# Print the exclusion summary cleanly: turn off xtrace for this block only, so
# the list is not doubled by the "+ echo ..." trace lines
{ set +x; } 2>/dev/null
echo ""
echo "******** Excluding ${#runtime_test_exclude_args[@]} known-broken tests from the Phase 1 gate ********"
echo "These fail under qemu-mips64el with SIGBUS (unaligned access in binary/data"
echo "parsers), are off the VMVX inference path, and are deferred to a later phase:"
for _t in "${runtime_test_exclude_args[@]}"; do
  echo "  - ${_t}"
done
echo ""
echo "******** Running runtime CTest ********"
set -x
ctest ${runtime_ctest_args[@]}

# Tests not included in phase 1
# tests_label_exclude_regex="($(IFS="|" ; echo "${label_exclude_args[*]}"))"
# tests_exclude_regex="($(IFS="|" ; echo "${test_exclude_args[*]}"))"
# test_ctest_args=(
#   "--test-dir ${BUILD_DIR}/tests/e2e"
#   ${ctest_args[@]}
#   "--label-exclude ${tests_label_exclude_regex}"
#   "--exclude-regex ${tests_exclude_regex}"
# )
# echo "******** Running e2e CTest ********"
# ctest  ${test_ctest_args[@]}
