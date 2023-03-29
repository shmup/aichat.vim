import openai
# pyright: reportUndefinedVariable=false, reportGeneralTypeIssues=false

plugin_root = vim.eval("s:plugin_root")
vim.command(f"py3file {plugin_root}/py/utils.py")
options = make_options()
file_content = vim.eval('trim(join(getline(1, "$"), "\n"))')
openai.api_key = load_api_key()
lines = file_content.splitlines()
messages = []

for line in lines:
    if line.startswith(">>> system"):
        messages.append({"role": "system", "content": ""})
    elif line.startswith(">>> user"):
        messages.append({"role": "user", "content": ""})
    elif line.startswith("<<< assistant"):
        messages.append({"role": "assistant", "content": ""})
    elif messages:
        messages[-1]["content"] += "\n" + line

if not messages:
    messages.append({"role": "user", "content": ">>> user\n\n" + file_content})

def send_vim_command(command):
    vim.command("redraw")
    vim.command(command)

try:
    if messages[-1]["content"].strip():
        send_vim_command("normal! Go\n<<< assistant\n\n")
        send_vim_command("echo 'Answering...'")

        response = openai.ChatCompletion.create(messages=messages, stream=True, **options)

        generating_text = False
        for resp in response:
            text = resp['choices'][0]['delta'].get('content', '')
            if not text.strip() and not generating_text:
                continue
            generating_text = True
            send_vim_command(f"normal! a{text}")
        send_vim_command("normal! a\n\n>>> user\n\n")
except KeyboardInterrupt:
    send_vim_command("normal! a Ctrl-C...")
except openai.error.Timeout:
    send_vim_command("normal! aRequest timeout...")
