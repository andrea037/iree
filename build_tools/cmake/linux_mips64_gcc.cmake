
cmake_minimum_required(VERSION 3.26) #minimalna cmake verzija

# CMake invokes the toolchain file twice during the first build, but only once
# during subsequent rebuilds. This was causing the various flags to be added
# twice on the first build, and on a rebuild ninja would see only one set of the
# flags and rebuild the world.
# https://github.com/android-ndk/ndk/issues/323

if(MIPS_TOOLCHAIN_INCLUDED)
  return()
endif()                              #guard od dvostrukog include-a
set(MIPS_TOOLCHAIN_INCLUDED true)

set(CMAKE_SYSTEM_NAME Linux)  # os = linux
set(CMAKE_SYSTEM_PROCESSOR mips64) # ciljna arhitektura = mips 64-bit ! ovde ostaje mips64 !

set(MIPS_TOOLCHAIN_PREFIX "${MIPS_TOOLCHAIN_PREFIX}")
if(MIPS_TOOLCHAIN_PREFIX STREQUAL "")
  set(MIPS_TOOLCHAIN_PREFIX "mips64el-linux-gnuabi64-")
endif()

if(NOT "${MIPS_TOOLCHAIN_ROOT}" STREQUAL "")   # ovo se razlikuje u odnosu na linux_mips64.cmake (tamo je clang ovde gcc)
  set(CMAKE_AR           "${MIPS_TOOLCHAIN_ROOT}/bin/${MIPS_TOOLCHAIN_PREFIX}ar")
  set(CMAKE_C_COMPILER   "${MIPS_TOOLCHAIN_ROOT}/bin/${MIPS_TOOLCHAIN_PREFIX}gcc")
  set(CMAKE_CXX_COMPILER "${MIPS_TOOLCHAIN_ROOT}/bin/${MIPS_TOOLCHAIN_PREFIX}g++")
  set(CMAKE_RANLIB       "${MIPS_TOOLCHAIN_ROOT}/bin/${MIPS_TOOLCHAIN_PREFIX}ranlib")
  set(CMAKE_STRIP        "${MIPS_TOOLCHAIN_ROOT}/bin/${MIPS_TOOLCHAIN_PREFIX}strip")
  set(CMAKE_SYSROOT      "${MIPS_TOOLCHAIN_ROOT}/sysroot") #root fajl sistem za target
else()
  set(CMAKE_C_COMPILER   "${MIPS_TOOLCHAIN_PREFIX}gcc")
  set(CMAKE_CXX_COMPILER "${MIPS_TOOLCHAIN_PREFIX}g++")
  #set(CMAKE_SYSROOT      "/usr/mips64el-linux-gnuabi64") 
endif()

set(MIPS_COMPILER_FLAGS "\
    -march=mips64r2 -mabi=64") #isa verzija i abi

set(MIPS_QEMU_CPU_FLAGS "MIPS64R2-generic") # Generic 64-bit MIPS Release 2 CPU model == mips64r2

# set(MIPS64_TEST_DEFAULT_LLVM_FLAGS
#   "--iree-llvmcpu-target-triple=mips64el-unknown-linux-gnu"   #<arch>-<vendor>-<os>-<environment> mips64el??
#   "--iree-llvmcpu-target-abi=64"             # odgovara za mabi od gore
#   "--iree-llvmcpu-target-cpu=mips64"         # model za instruction selection, odgovara za march
#   CACHE INTERNAL "Default llvm codegen flags for testing purposes") -> treba nam rpazno samo??

set(MIPS64_TEST_DEFAULT_LLVM_FLAGS
  ""
  CACHE INTERNAL "Default llvm codegen flags for testing purposes")


set(CMAKE_C_FLAGS_INIT   "${MIPS_COMPILER_FLAGS}")
set(CMAKE_CXX_FLAGS_INIT "${MIPS_COMPILER_FLAGS}")
set(CMAKE_ASM_FLAGS_INIT "${MIPS_COMPILER_FLAGS}")