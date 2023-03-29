import os
import configparser
# pyright: reportUndefinedVariable=false, reportGeneralTypeIssues=false


def load_api_key():
    config_name = 'setup.cfg'
    config = configparser.ConfigParser()
    plugin_root = vim.eval('s:plugin_root')
    config_path = os.path.join(plugin_root, config_name)

    try:
        config.read(config_path)
        api_key = config.get('openai', 'api_key').strip()
    except Exception as e:
        raise ValueError(f'error reading {config_name}: {str(e)}')
    return api_key


def make_options():
    options_default = vim.eval("options_default")
    options_user = vim.eval("options")
    options = {**options_default, **options_user}
    options['request_timeout'] = float(options['request_timeout'])
    options['temperature'] = float(options['temperature'])
    options['max_tokens'] = int(options['max_tokens'])
    return options
