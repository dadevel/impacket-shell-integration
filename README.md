# Impacket Shell Integration

![Screenshot](./assets/screenshot.png)

A bunch of scripts to reduce friction when pentesting Active Directory from Linux.

# Setup

First clone the repository.

~~~ bash
git clone --depth 1 https://github.com/dadevel/impacket-shell-integration.git ~/.local/share/impacket-shell-integration
~~~

Then append the following snippet to your `~/.bashrc` or `~/.zshrc` in order to use `krbconf` and `proxyconf`.
Jump to [Usage](#Usage) to see what these commands can do.

~~~ bash
source ~/.local/share/impacket-shell-integration/krbconf.sh
source ~/.local/share/impacket-shell-integration/proxyconf.sh
~~~

## Bash Integration

If you are using regular Bash you can add additional prompt elements as well.
Your `~/.bashrc` should look like this:

~~~ bash
...
source ~/.local/share/impacket-shell-integration/krbconf.sh
source ~/.local/share/impacket-shell-integration/proxyconf.sh
source ~/.local/share/impacket-shell-integration/bash.sh

_prompt() {
    ...
    declare -r left_delimiter=''
    declare -r right_delimiter='  '
    declare -a elements=("$(_prompt_krbconf)" "$(_prompt_proxyconf)" "$(_prompt_tunnel)")
    declare element
    for element in "${elements[@]}"; do
        if [[ -n "${element}" ]]; then
            PS1+="${left_delimiter}"
            PS1+="${element}"
            PS1+="${right_delimiter}"
        fi
    done
    ...
}

PROMPT_COMMAND=_prompt
...
~~~

## Ble.sh Integration

If you are using Bash with [ble.sh](https://github.com/akinomyoga/ble.sh) you can add additional elements to your prompt.
Your `~/.bashrc` should look like this:

~~~ bash
...
source ~/.local/share/impacket-shell-integration/krbconf.sh
source ~/.local/share/impacket-shell-integration/proxyconf.sh
source ~/.local/share/impacket-shell-integration/ble.sh
source ~/.local/share/blesh/ble.sh --attach=none
...
# left prompt
PS1='...'
# right prompt
bleopt prompt_rps1='\q{krbconf}\q{proxyconf}\q{tunnel}'
...
[[ ! "${BLE_VERSION-}" ]] || ble-attach
...
~~~

## Zsh Integration

If you are using Zsh with [Powerlevel10k](https://github.com/romkatv/powerlevel10k) you can get additional prompt elements too.
Your `powerlevel10k.zsh` should look like this:

~~~ bash
...
source ~/.local/share/impacket-shell-integration/krbconf.sh
source ~/.local/share/impacket-shell-integration/proxyconf.sh
...
() {
    ...
    typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
        ...
        krbconf
        proxyconf
        tunnel
        ...
    )

    source ~/.local/share/impacket-shell-integration/powerlevel10k.zsh
    ...
}()
...
~~~

The prompts rely on icons from [Nerd Fonts](https://www.nerdfonts.com/).

## Starship Integration

If you are using any shell supported by [Starship](https://starship.rs/) you can also add additional prompt elements.
Your `starship.toml` should look like this:

~~~ toml
right_format = "${custom.krbconf}${custom.proxyconf}"

[custom.krbconf]
command = '[ -n "$KRB5CCNAME_HOST" ] && echo "$KRB5CCNAME_DOMAIN/$KRB5CCNAME_USER@$KRB5CCNAME_HOST" || echo "$KRB5CCNAME_DOMAIN/$KRB5CCNAME_USER"'
when = '[ -n "$KRB5CCNAME" ] && [ -n "$KRB5CCNAME_DOMAIN" ] && [ -n "$KRB5CCNAME_USER" ]'
symbol = ""
style = "fg:blue"
format = '[$symbol $output]($style) '

[custom.proxyconf]
command = 'echo "$PROXYCHAINS_ENDPOINT"'
when = '[ -n "$PROXYCHAINS_ENDPOINT" ] && [ "$LD_PRELOAD" = /usr/lib/libproxychains4.so ]'
symbol = "󰁕"
style = "fg:green"
format = '[$symbol $output]($style) '
~~~

# Usage

Configure a SOCKS proxy in the current shell with the help of [proxychains-ng](https://github.com/rofl0r/proxychains-ng).
The network traffic of all following commands will be tunneled over the proxy (as long as they link against libc).

~~~ bash
proxyconf set socks5 127.0.0.1 1080
nc -vz dc01.corp.local 445
~~~

Stop tunneling traffic over the proxy.

~~~ bash
proxyconf unset
~~~

Tell subsequent tools to use a specific Kerberos TGT or ST by setting the `$KRB5CCNAME` environment variable.

~~~ bash
krbconf set ./jdoeadm.ccache
impacket-smbclient -k -no-pass srv01.corp.local
~~~

If you additionally specify the hostname or FQDN of a domain controller with `-K` / `--kdc`, a suitable `$KRB5_CONFIG` is configured in the environment as well (thanks [@mpgn](https://twitter.com/mpgn_x64/status/1881252755131760659) for the idea).
This is required for some tools that use GSSAPI like [evil-winrm](https://github.com/Hackplayers/evil-winrm).

~~~ bash
krbconf set ./jdoeadm.ccache -K dc01
evil-winrm -r $KRB5CCNAME_DOMAIN -i srv01.corp.local
~~~

Stop using the ticket.

~~~ bash
krbconf unset
~~~

Execute a one-off command in the context of a given ticket.

~~~ bash
krbconf exec ./jdoeadm.ccache impacket-smbclient -k -no-pass srv01.corp.local
~~~

Import a ticket in Kirbi format from Windows (e.g. from [Rubeus](https://github.com/GhostPack/Rubeus)).

~~~ bash
krbconf import ./jdoe.kirbi
krbconf import base64:doIFrTCCBamgAwIB...
~~~
