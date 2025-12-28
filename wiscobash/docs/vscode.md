# vscode

sign-in to sync settings using `leewiscovitch` github account

>if prompted allow remote to overwrite locat settings

## configure

here is the base `settings.json` being used:

```json
{
    "python.showStartPage": false,
    "editor.renderWhitespace": "all",
    "yaml.customTags": [
        "!encrypted/pkcs1-oaep scalar",
        "!vault scalar",
        "!And",
        "!And sequence",
        "!If",
        "!If sequence",
        "!Not",
        "!Not sequence",
        "!Equals",
        "!Equals sequence",
        "!Or",
        "!Or sequence",
        "!FindInMap",
        "!FindInMap sequence",
        "!Base64",
        "!Join",
        "!Join sequence",
        "!Cidr",
        "!Ref",
        "!Sub",
        "!Sub sequence",
        "!GetAtt",
        "!GetAZs",
        "!ImportValue",
        "!ImportValue sequence",
        "!Select",
        "!Select sequence",
        "!Split",
        "!Split sequence"
    ],
    "redhat.telemetry.enabled": false,
    "json.schemas": [],
    "git.enableSmartCommit": true,
    "git.confirmSync": false,
    "git.autofetch": true,
    "git.postCommitCommand": "push"
}
```

## extensions

here is a list of currently installed extensions, obtained running `code --list-extensions`:

```shell
hashicorp.hcl
hashicorp.terraform
ms-python.debugpy
ms-python.python
ms-python.vscode-pylance
ms-vscode-remote.remote-containers
ms-vscode-remote.remote-ssh
ms-vscode-remote.remote-ssh-edit
redhat.ansible
redhat.vscode-yaml
yzhang.markdown-all-in-one
```