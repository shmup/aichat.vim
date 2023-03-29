import os
import configparser
# pyright: reportUndefinedVariable=false, reportGeneralTypeIssues=false
# Error detected while processing CursorHold Autocommands for "*":


def load_api_key():
    config = configparser.ConfigParser()
    config_path = os.path.join(vim.eval('s:plugin_root'), 'setup.cfg')

    try:
        config.read(config_path)
        return config.get('openai', 'api_key').strip()
    except Exception as e:
        raise ValueError(f'error reading setup.cfg: {str(e)}')


def make_options():
    options = {**vim.eval("options_default"), **vim.eval("options")}

    try:
        options['request_timeout'] = float(options['request_timeout'])
        options['temperature'] = float(options['temperature'])
        options['max_tokens'] = int(options['max_tokens'])
    except ValueError as e:
        raise ValueError(f'Error converting option values: {str(e)}')

    return options
