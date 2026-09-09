// Copyright 2023 The IREE Authors
//
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "iree/base/api.h"
#include "iree/hal/local/elf/arch.h"
#include "iree/hal/local/elf/elf_types.h"

#if defined(IREE_ARCH_MIPS_64)

//==============================================================================
// ELF machine type/ABI
//==============================================================================

bool iree_elf_machine_is_valid(iree_elf_half_t machine) {
  // Phase 1: Don't recognize MIPS ELF files - use VMVX fallback
  return false;
}

//==============================================================================
// ELF relocations (Phase 1: stub implementation)
//==============================================================================

enum {
  IREE_ELF_R_MIPS_NONE = 0,
  IREE_ELF_R_MIPS_64 = 18,
  IREE_ELF_R_MIPS_REL32 = 3,
};

iree_status_t iree_elf_arch_apply_relocations(
    iree_elf_relocation_state_t* state) {
  // Phase 1: No native MIPS execution, should not be called
  return iree_make_status(IREE_STATUS_UNIMPLEMENTED,
                          "MIPS ELF relocations not implemented in Phase 1");
}

//==============================================================================
// Cross-ABI function calls (Phase 1: stub implementation)
//==============================================================================

void iree_elf_call_v_v(const void* symbol_ptr) {
  // Phase 1: No native MIPS execution
}

void* iree_elf_call_p_i(const void* symbol_ptr, int a0) {
  // Phase 1: No native MIPS execution
  return NULL;
}

void* iree_elf_call_p_ip(const void* symbol_ptr, int a0, void* a1) {
  // Phase 1: No native MIPS execution
  return NULL;
}

int iree_elf_call_i_p(const void* symbol_ptr, void* a0) {
  // Phase 1: No native MIPS execution
  return -1;
}

int iree_elf_call_i_ppp(const void* symbol_ptr, void* a0, void* a1, void* a2) {
  // Phase 1: No native MIPS execution
  return -1;
}

void* iree_elf_call_p_ppp(const void* symbol_ptr, void* a0, void* a1,
                          void* a2) {
  // Phase 1: No native MIPS execution
  return NULL;
}

int iree_elf_thunk_i_ppp(const void* symbol_ptr, void* a0, void* a1, void* a2) {
  // Phase 1: No native MIPS execution
  return -1;
}

#endif  // IREE_ARCH_MIPS_64