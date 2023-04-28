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


def send_vim_command(command):
    vim.command("redraw")
    vim.command(command)


def render_text_chunks(chunks):
    generating_text = False
    for text in chunks:
        if not text.strip() and not generating_text:
            continue  # trim newlines from the beginning
        generating_text = True
        vim.command("normal! a" + text)
        vim.command("redraw")


def parse_chat_messages(chat_content):
    lines = chat_content.splitlines()
    messages = []
    for line in lines:
        if line.startswith(">>> system"):
            messages.append({"role": "system", "content": ""})
            continue
        if line.startswith(">>> user"):
            messages.append({"role": "user", "content": ""})
            continue
        if line.startswith("<<< assistant"):
            messages.append({"role": "assistant", "content": ""})
            continue
        if not messages:
            continue
        messages[-1]["content"] += "\n" + line

    for message in messages:
        # strip newlines from the content as it causes empty responses
        message["content"] = message["content"].strip()

    return messages
