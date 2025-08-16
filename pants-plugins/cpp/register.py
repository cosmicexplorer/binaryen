from cpp.platform import rules as platform_rules
from cpp.target_types import CppExecutable, CppLibrary, CppSources


# Consider https://www.gnu.org/software/automake/manual/html_node/Programs.html.
def rules():
  return [*platform_rules()]


def target_types():
  return [CppSources, CppLibrary, CppExecutable]
