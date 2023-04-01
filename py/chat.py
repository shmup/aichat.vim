import openai
# pyright: reportUndefinedVariable=false, reportGeneralTypeIssues=false

plugin_root = vim.eval("s:plugin_root")
vim.command(f"py3file {plugin_root}/py/utils.py")


def get_role(line):
    if line.startswith(">>> system"):
        return "system"
    elif line.startswith(">>> user"):
        return "user"
    elif line.startswith("<<< assistant"):
        return "assistant"
    else:
        return None


def create_message(role, content=""):
    return {"role": role, "content": content}


file_content = vim.eval('trim(join(getline(1, "$"), "\n"))')
lines = file_content.splitlines()
messages = []

for line in lines:
    role = get_role(line)
    if role:
        messages.append(create_message(role))
    elif messages:
        messages[-1]["content"] += "\n" + line.strip()

if not messages:
    messages.append(create_message("user", ">>> user\n" + file_content.strip()))

try:
    if messages[-1]["content"].strip():
        send_vim_command("normal! Go<<< assistant\n")
        send_vim_command("echo 'Answering...'")

        options = make_options()
        openai.api_key = load_api_key()
        response = openai.ChatCompletion.create(messages=messages, stream=True, **options)

        generating_text = False
        for resp in response:
            text = resp['choices'][0]['delta'].get('content', '')
            if not text.strip() and not generating_text:
                continue
            generating_text = True
            send_vim_command(f"normal! a{text}")
        send_vim_command("normal! a\n>>> user\n")
except KeyboardInterrupt:
    send_vim_command("normal! a Ctrl-C...")
except openai.error.Timeout:
    send_vim_command("normal! aRequest timeout...")
