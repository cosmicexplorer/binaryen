# Consider https://www.gnu.org/software/automake/manual/html_node/index.html#SEC_Contents,
# and in particular https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.72/html_node/Specifying-Target-Triplets.html#Specifying-Names.
# Also consider https://www.gnu.org/software/automake/manual/html_node/configure.html.

# See https://www.gnu.org/software/automake/manual/html_node/Public-Macros.html for the programs it
# needs, and https://www.gnu.org/software/automake/manual/html_node/List-of-Automake-options.html
# for the entire bevy of inputs to the ./configure script.

# See https://www.gnu.org/software/automake/manual/html_node/C_002b_002b-Support.html for C++, and
# https://www.gnu.org/software/automake/manual/html_node/Assembly-Support.html for assembly.

# See https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.72/html_node/Particular-Programs.html#Particular-Programs
# for all programs predefined.

from dataclasses import dataclass

from pants.engine.fs import CreateDigest, Digest, FileContent
from pants.engine.rules import collect_rules, Get, rule
from pants.option.option_types import StrOption
from pants.option.subsystem import Subsystem
from pants.util.strutil import softwrap

from cpp.config import config_guess_script, config_sub_script


class PlatformSubsystem(Subsystem):
  options_scope = 'platform'
  help = softwrap('''
    The system types involved in the current compilation process.

    These option names mirror the corresponding terminology and semantics from GNU autoconf: https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.72/html_node/Specifying-Target-Triplets.html
    ''')

  build = StrOption(
    default=None,
    advanced=True,
    help=softwrap('''
      The type of system which pants is executing on.

      This defaults to the result of running `config.guess`.
      ''')
  )

  host = StrOption(
    default=None,
    advanced=False,
    help=softwrap('''
      The type of system which pants should build output for.

      By default it is the same as the build machine.
      ''')
  )


@dataclass(frozen=True)
class ConfigGuess:
  digest: Digest


@dataclass(frozen=True)
class ConfigSub:
  digest: Digest


@rule
async def config_guess() -> ConfigGuess:
  digest = await Get(
    Digest,
    CreateDigest([
      FileContent('config.guess', config_guess_script().encode('utf-8'), is_executable=True)
    ])
  )
  return ConfigGuess(digest)


@rule
async def config_sub() -> ConfigSub:
  digest = await Get(
    Digest,
    CreateDigest([
      FileContent('config.sub', config_sub_script().encode('utf-8'), is_executable=True)
    ])
  )
  return ConfigSub(digest)


def rules():
  return [
    *collect_rules(),
    *PlatformSubsystem.rules(),
  ]
