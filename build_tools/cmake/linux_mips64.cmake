
cmake_minimum_required(VERSION 3.26) # minimum CMake version

# CMake invokes the toolchain file twice during the first build, but only once
# during subsequent rebuilds. This was causing the various flags to be added
# twice on the first build, and on a rebuild ninja would see only one set of the
# flags and rebuild the world.
# https://github.com/android-ndk/ndk/issues/323

if(MIPS_TOOLCHAIN_INCLUDED)
  return()
endif()                              # guard from double include
set(MIPS_TOOLCHAIN_INCLUDED true)

set(CMAKE_SYSTEM_NAME Linux)  # OS = Linux
set(CMAKE_SYSTEM_PROCESSOR mips64) # target architecture = MIPS 64-bit (stays mips64 here)

if(NOT "${MIPS_TOOLCHAIN_ROOT}" STREQUAL "")   # if the MIPS toolchain root variable is set
  set(CMAKE_AR           "${MIPS_TOOLCHAIN_ROOT}/bin/${MIPS_TOOLCHAIN_PREFIX}llvm-ar")
  set(CMAKE_C_COMPILER   "${MIPS_TOOLCHAIN_ROOT}/bin/${MIPS_TOOLCHAIN_PREFIX}clang")
  set(CMAKE_CXX_COMPILER "${MIPS_TOOLCHAIN_ROOT}/bin/${MIPS_TOOLCHAIN_PREFIX}clang++")
  #set(CMAKE_RANLIB       "${MIPS_TOOLCHAIN_ROOT}/bin/${MIPS_TOOLCHAIN_PREFIX}llvm-ranlib")
  set(CMAKE_C_COMPILER_TARGET   "mips64el-linux-gnuabi64")
  set(CMAKE_CXX_COMPILER_TARGET "mips64el-linux-gnuabi64")
  set(CMAKE_ASM_COMPILER_TARGET "mips64el-linux-gnuabi64")
  #set(CMAKE_STRIP        "${MIPS_TOOLCHAIN_ROOT}/bin/${MIPS_TOOLCHAIN_PREFIX}llvm-strip")
  # Sysroot and GNU binutils/libs that clang links against.
  set(CMAKE_SYSROOT "${MIPS_SYSROOT}")
    list(APPEND MIPS_EXTRA_FLAGS "--gcc-toolchain=${MIPS_GCC_TOOLCHAIN}")
  # Use the GNU linker (bfd), not LLD.
  list(APPEND MIPS_EXTRA_FLAGS "-fuse-ld=bfd")
endif()

set(MIPS_COMPILER_FLAGS "\
    -march=mips64r2 -mabi=64") # ISA version and ABI

set(MIPS_QEMU_CPU_FLAGS "MIPS64R2-generic") # Generic 64-bit MIPS Release 2 CPU model == mips64r2

# Populate once MIPS codegen exists. This VMVX-only build does no
# codegen, so the active value below stays empty:
# set(MIPS64_TEST_DEFAULT_LLVM_FLAGS
#   "--iree-llvmcpu-target-triple=mips64el-unknown-linux-gnu"   # <arch>-<vendor>-<os>-<environment>
#   "--iree-llvmcpu-target-abi=64"             # matches the -mabi above
#   "--iree-llvmcpu-target-cpu=mips64"         # CPU model for instruction selection; matches -march
#   CACHE INTERNAL "Default llvm codegen flags for testing purposes")

set(MIPS64_TEST_DEFAULT_LLVM_FLAGS
  ""
  CACHE INTERNAL "Default llvm codegen flags for testing purposes")

set(CMAKE_C_FLAGS_INIT   "${MIPS_COMPILER_FLAGS}")
set(CMAKE_CXX_FLAGS_INIT "${MIPS_COMPILER_FLAGS}")
set(CMAKE_ASM_FLAGS_INIT "${MIPS_COMPILER_FLAGS}")
