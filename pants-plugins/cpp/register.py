from cpp.target_types import CppExecutable, CppLibrary, CppSources
from cpp.toolchain import rules as toolchain_rules


# Consider https://www.gnu.org/software/automake/manual/html_node/Programs.html.
def rules():
  return [*toolchain_rules()]


def target_types():
  return [CppSources, CppLibrary, CppExecutable]
