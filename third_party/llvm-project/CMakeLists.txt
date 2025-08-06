# LLVM sources have warnings, ignore them. Otherwise, use options as close
# as possible to LLVM's defaults.
if(MSVC)
  # Silence warnings.
  add_compile_options(/w)
  add_compile_definitions(
    _CRT_SECURE_NO_DEPRECATE
    _CRT_SECURE_NO_WARNINGS
    _CRT_NONSTDC_NO_DEPRECATE
    _CRT_NONSTDC_NO_WARNINGS
    _SCL_SECURE_NO_DEPRECATE
    _SCL_SECURE_NO_WARNINGS
    UNICODE
    _UNICODE
    __STDC_CONSTANT_MACROS
    __STDC_FORMAT_MACROS
    __STDC_LIMIT_MACROS
  )
else()
  # Silence warnings.
  add_compile_options(-w)
  add_compile_definitions(
    _GNU_SOURCE
    _DEBUG
    __STDC_CONSTANT_MACROS
    __STDC_FORMAT_MACROS
    __STDC_LIMIT_MACROS
  )
endif()

SET(llvm_dwarf_SOURCES
  Binary.cpp
  ConvertUTF.cpp
  DataExtractor.cpp
  Debug.cpp
  DJB.cpp
  Dwarf.cpp
  dwarf2yaml.cpp
  DWARFAbbreviationDeclaration.cpp
  DWARFAcceleratorTable.cpp
  DWARFAddressRange.cpp
  DWARFCompileUnit.cpp
  DWARFContext.cpp
  DWARFDataExtractor.cpp
  DWARFDebugAbbrev.cpp
  DWARFDebugAddr.cpp
  DWARFDebugAranges.cpp
  DWARFDebugArangeSet.cpp
  DWARFDebugFrame.cpp
  DWARFDebugInfoEntry.cpp
  DWARFDebugLine.cpp
  DWARFDebugLoc.cpp
  DWARFDebugMacro.cpp
  DWARFDebugPubTable.cpp
  DWARFDebugRangeList.cpp
  DWARFDebugRnglists.cpp
  DWARFDie.cpp
  DWARFEmitter.cpp
  DWARFExpression.cpp
  DWARFFormValue.cpp
  DWARFGdbIndex.cpp
  DWARFListTable.cpp
  DWARFTypeUnit.cpp
  DWARFUnit.cpp
  DWARFUnitIndex.cpp
  DWARFVerifier.cpp
  DWARFVisitor.cpp
  DWARFYAML.cpp
  Error.cpp
  ErrorHandling.cpp
  FormatVariadic.cpp
  Hashing.cpp
  LEB128.cpp
  LineIterator.cpp
  MCRegisterInfo.cpp
  MD5.cpp
  MemoryBuffer.cpp
  NativeFormatting.cpp
  ObjectFile.cpp
  obj2yaml_Error.cpp
  Optional.cpp
  Path.cpp
  raw_ostream.cpp
  ScopedPrinter.cpp
  SmallVector.cpp
  SourceMgr.cpp
  StringMap.cpp
  StringRef.cpp
  SymbolicFile.cpp
  Twine.cpp
  UnicodeCaseFold.cpp
  WithColor.cpp
  YAMLParser.cpp # XXX needed?
  YAMLTraits.cpp
)
add_library(llvm_dwarf OBJECT ${llvm_dwarf_SOURCES})
set_target_properties(
  llvm_dwarf PROPERTIES
  CXX_STANDARD 14
  POSITION_INDEPENDENT_CODE ON
)
# Use SYSTEM to avoid warnings and errors.
target_include_directories(llvm_dwarf SYSTEM PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
)
