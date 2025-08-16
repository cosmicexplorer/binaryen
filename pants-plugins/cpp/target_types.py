from enum import Enum

from pants.engine.target import (
  COMMON_TARGET_FIELDS,
  Dependencies,
  MultipleSourcesField,
  SingleSourceField,
  StringField,
  StringSequenceField,
  Target,
)
from pants.util.strutil import softwrap


_c_source_extensions = ('.c',)
_cpp_source_extensions = ('.cpp', '.cp', '.cc', '.cxx', '.C', '.c++')
_c_header_extensions = ('.h',)
_cpp_header_extensions = ('.hpp', '.tpp', '.hxx')
_cpp_module_extensions = ('.ixx', '.cppm')

_cpp_sources_alias = 'cpp_sources'
_cpp_library_alias = 'cpp_library'
_cpp_executable_alias = 'cpp_executable'


class CppSourcesField(MultipleSourcesField):
  expected_file_extensions = (
    _c_source_extensions + _cpp_source_extensions + _c_header_extensions + _cpp_header_extensions +
    _cpp_module_extensions
  )
  help = 'C or C++ source files.'


class CppSources(Target):
  alias = _cpp_sources_alias
  core_fields = (*COMMON_TARGET_FIELDS, Dependencies, CppSourcesField)
  help = softwrap(f'''
  A collection of C or C++ source files.

  This does not produce an exported library or executable. Use {_cpp_library_alias}() or
  {_cpp_executable_alias}() for that.
  ''')


class ExeExportField(SingleSourceField):
  expected_file_extensions = (_c_source_extensions + _cpp_source_extensions)
  required = False
  default = None
  help = softwrap(f'''
  A single C or C++ source file.

  This may be used to define the `main()` method if not provided by any
  {_cpp_sources_alias}() dependency.
  ''')


class LibExportField(SingleSourceField):
  expected_file_extensions = (_c_source_extensions + _cpp_source_extensions)
  required = False
  default = None
  help = softwrap('''
  A single C or C++ source file.

  This may be used to define global symbols specific to the library target.
  ''')


class Linkage(Enum):
  STATIC = 'static'
  SHARED = 'shared'


class ExeLinkage(StringField):
  alias = 'linkage'
  valid_choices = Linkage
  required = True
  help = 'The linking behavior for C or C++ executables.'


class LibraryLinkage(StringSequenceField):
  alias = 'linkages'
  valid_choices = Linkage
  default = tuple(l.value for l in Linkage)
  help = softwrap('''
  The allowed linking behavior for C or C++ libraries.

  This defaults to generating both shared and static linkage. An explicit value can be provided in
  order to avoid generating both variants.
  ''')


# TODO: https://www.pantsbuild.org/stable/docs/writing-plugins/common-plugin-tasks/allowing-tool-export
# Consider https://www.gnu.org/software/automake/manual/html_node/A-Library.html, as well as
# https://www.gnu.org/software/automake/manual/html_node/A-Shared-Library.html.
class CppLibrary(Target):
  alias = _cpp_library_alias
  core_fields = (*COMMON_TARGET_FIELDS, Dependencies, LibraryLinkage, LibExportField)
  help = 'An exported C ABI library.'


# Consider https://www.gnu.org/software/automake/manual/html_node/A-Program.html.
class CppExecutable(Target):
  alias = _cpp_executable_alias
  core_fields = (*COMMON_TARGET_FIELDS, Dependencies, ExeLinkage, ExeExportField)
  help = 'An exported C ABI executable.'
