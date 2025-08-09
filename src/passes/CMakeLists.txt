# The below condition is intended for removal once the suffix_tree and
# suffix_tree_node source files no longer depend on LLVM code in the
# third_party folder
add_subdirectory(outlining)

add_subdirectory(gen-intrinsics)

FILE(GLOB passes_HEADERS *.h)
set(passes_SOURCES
  param-utils.cpp
  pass.cpp
  string-utils.cpp
  test_passes.cpp
  AbstractTypeRefining.cpp
  AlignmentLowering.cpp
  Asyncify.cpp
  AvoidReinterprets.cpp
  CoalesceLocals.cpp
  CodePushing.cpp
  CodeFolding.cpp
  ConstantFieldPropagation.cpp
  ConstHoisting.cpp
  DataFlowOpts.cpp
  DeadArgumentElimination.cpp
  DeadCodeElimination.cpp
  DeAlign.cpp
  DebugLocationPropagation.cpp
  DeNaN.cpp
  Directize.cpp
  DuplicateImportElimination.cpp
  DuplicateFunctionElimination.cpp
  DWARF.cpp
  EncloseWorld.cpp
  ExtractFunction.cpp
  Flatten.cpp
  FuncCastEmulation.cpp
  GenerateDynCalls.cpp
  GlobalEffects.cpp
  GlobalRefining.cpp
  GlobalStructInference.cpp
  GlobalTypeOptimization.cpp
  GUFA.cpp
  Heap2Local.cpp
  HeapStoreOptimization.cpp
  I64ToI32Lowering.cpp
  Inlining.cpp
  InstrumentBranchHints.cpp
  InstrumentLocals.cpp
  InstrumentMemory.cpp
  Intrinsics.cpp
  J2CLItableMerging.cpp
  J2CLOpts.cpp
  JSPI.cpp
  LegalizeJSInterface.cpp
  LimitSegments.cpp
  LLVMMemoryCopyFillLowering.cpp
  LocalCSE.cpp
  LocalSubtyping.cpp
  LogExecution.cpp
  LoopInvariantCodeMotion.cpp
  Memory64Lowering.cpp
  MemoryPacking.cpp
  MergeBlocks.cpp
  MergeSimilarFunctions.cpp
  MergeLocals.cpp
  Metrics.cpp
  MinifyImportsAndExports.cpp
  MinimizeRecGroups.cpp
  Monomorphize.cpp
  MultiMemoryLowering.cpp
  NameList.cpp
  NameTypes.cpp
  NoInline.cpp
  LLVMNontrappingFPToIntLowering.cpp
  OnceReduction.cpp
  OptimizeAddedConstants.cpp
  OptimizeCasts.cpp
  OptimizeInstructions.cpp
  OptimizeForJS.cpp
  PickLoadSigns.cpp
  Poppify.cpp
  PostEmscripten.cpp
  Precompute.cpp
  Print.cpp
  PrintCallGraph.cpp
  PrintFeatures.cpp
  PrintFunctionMap.cpp
  RoundTrip.cpp
  SetGlobals.cpp
  SignaturePruning.cpp
  SignatureRefining.cpp
  SignExtLowering.cpp
  StringLifting.cpp
  StringLowering.cpp
  Strip.cpp
  StripTargetFeatures.cpp
  TraceCalls.cpp
  RandomizeBranchHints.cpp
  RedundantSetElimination.cpp
  RemoveImports.cpp
  RemoveMemoryInit.cpp
  RemoveUnusedBrs.cpp
  RemoveUnusedNames.cpp
  RemoveUnusedModuleElements.cpp
  RemoveUnusedTypes.cpp
  ReorderFunctions.cpp
  ReorderGlobals.cpp
  ReorderLocals.cpp
  ReReloop.cpp
  TrapMode.cpp
  TypeGeneralizing.cpp
  TypeRefining.cpp
  TypeMerging.cpp
  TypeSSA.cpp
  SafeHeap.cpp
  SeparateDataSegments.cpp
  SimplifyGlobals.cpp
  SimplifyLocals.cpp
  Souperify.cpp
  SpillPointers.cpp
  StackCheck.cpp
  StripEH.cpp
  SSAify.cpp
  TupleOptimization.cpp
  TranslateEH.cpp
  TypeFinalizing.cpp
  Unsubtyping.cpp
  Untee.cpp
  Vacuum.cpp
  ${passes_HEADERS}
)
add_library(passes OBJECT ${passes_SOURCES})

if(NOT BUILD_LLVM_DWARF)
  target_compile_definitions(passes PRIVATE SKIP_OUTLINING)
endif()

add_library(intrinsics-ops-pass OBJECT RemoveNonJSOps.cpp)
target_link_libraries(intrinsics-ops-pass PRIVATE
  binaryen-base
  iface_gen-intrinsics
)
add_library(iface_intrinsics-ops-pass INTERFACE)
target_link_libraries(iface_intrinsics-ops-pass INTERFACE
  intrinsics-ops-pass $<TARGET_OBJECTS:intrinsics-ops-pass>)


target_link_libraries(passes PUBLIC
  propagate-include-root-from-here
  $<$<BOOL:${BUILD_LLVM_DWARF}>:iface_outlining>
  iface_intrinsics-ops-pass
)
# target_precompile_headers(passes REUSE_FROM binaryen-base)

add_library(iface_passes INTERFACE)
target_link_libraries(iface_passes INTERFACE passes $<TARGET_OBJECTS:passes>)
