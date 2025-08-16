from functools import cache
import importlib.resources


# NB: these *could* be made available as an ExternalTool, but we'd prefer to avoid hitting gnu's git
#     repo with our users' CI traffic.
@cache
def config_guess_script() -> str:
  return importlib.resources.read_text('cpp.config', 'config.guess')


@cache
def config_sub_script() -> str:
  return importlib.resources.read_text('cpp.config', 'config.sub')
