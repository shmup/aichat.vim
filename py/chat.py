import openai
# pyright: reportUndefinedVariable=false, reportGeneralTypeIssues=false

plugin_root = vim.eval("s:plugin_root")
vim.command(f"py3file {plugin_root}/py/utils.py")
file_content = vim.eval('trim(join(getline(1, "$"), "\n"))')
messages = parse_chat_messages(file_content)

try:
    if messages[-1]["content"].strip():
        send_vim_command("normal! Go<<< assistant\n")
        send_vim_command("echo 'Answering...'")
        request_options = make_options()
        openai.api_key = load_api_key()
        response = openai.ChatCompletion.create(messages=messages,
                                                stream=True,
                                                **request_options)
        # response_data = ''.join([str(item) for item in response])
        # with open("gpt_reponse.txt", "w") as f:
        #     f.write(response_data)
        text_chunks = map(lambda resp: resp['choices'][0]['delta'].get('content', ''),
                          response)
        render_text_chunks(text_chunks)
        send_vim_command("normal! a\n>>> user\n")
except KeyboardInterrupt:
    send_vim_command("normal! a Ctrl-C...")
except openai.error.Timeout:
    send_vim_command("normal! aRequest timeout...")
