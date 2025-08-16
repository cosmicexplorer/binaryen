from cpp.target_types import CppExecutable, CppLibrary, CppSources


def rules():
  return []


def target_types():
  return [CppSources, CppLibrary, CppExecutable]
