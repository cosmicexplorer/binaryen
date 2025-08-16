from cpp.target_types import CppExecutable, CppLibrary, CppSources


# Consider https://www.gnu.org/software/automake/manual/html_node/Programs.html.
def rules():
  return []


def target_types():
  return [CppSources, CppLibrary, CppExecutable]
