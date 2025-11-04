# Impacket Shell Integration

![Screenshot](./assets/screenshot.png)

A bunch of scripts to reduce friction when pentesting Active Directory from Linux.

# Setup

First clone the repository.

~~~ bash
git clone --depth 1 https://github.com/dadevel/impacket-shell-integration.git ~/.local/share/impacket-shell-integration
~~~

Then append the following snippet to your `~/.bashrc` or `~/.zshrc`:

~~~ bash
source ~/.local/share/impacket-shell-integration/krbconf.sh
source ~/.local/share/impacket-shell-integration/proxyconf.sh
~~~

If you are using Bash with [ble.sh](https://github.com/akinomyoga/ble.sh) you get additional prompt elements.
Your `~/.bashrc` should look like this:

~~~ bash
source ~/.local/share/impacket-shell-integration/krbconf.sh
source ~/.local/share/impacket-shell-integration/proxyconf.sh
source ~/.local/share/impacket-shell-integration/ble.bash
source ~/.local/share/blesh/ble.sh --attach=none
...
# left prompt
PS1='\q{krbconf}$ '
# right prompt
bleopt prompt_rps1='\q{proxyconf}\q{tunnel}'
...
[[ ! "${BLE_VERSION-}" ]] || ble-attach
~~~

If you are using ZSH with [Powerlevel10k](https://github.com/romkatv/powerlevel10k) you get additional prompt elements as well.
Your `powerlevel10k.zsh` should look like this:

~~~ bash
...
() {
    ...
    typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
        ...
        krbconf
        ...
    )
    typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
        ...
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

If you are using Bash with [Starship](https://starship.rs/) you get additional prompt elements as well.
Your `starship.toml` should look like this:

~~~toml
# Example for https://starship.rs/presets/gruvbox-rainbow

format = """
...
${custom.proxyconf}\
...
$line_break${custom.krbconf}$character"""

[custom.krbconf]
command = '''bash -c 'echo "${KRB5CCNAME_USER}@${KRB5CCNAME_DOMAIN}"' '''
when = '[ -n "$KRB5CCNAME" ]'
# Select a icon and replace 'Place_a_icon_here'  https://www.nerdfonts.com/cheat-sheet
symbol = "Place_a_icon_here "
style = "color_green"
format = "[$symbol$output]($style)"

[custom.proxyconf]
command = '''bash -c 'echo "${PROXYCHAINS_ENDPOINT}"' '''
when = '[ -n "$PROXYCHAINS_ENDPOINT" ]'
# Select a icon and replace 'Place_a_icon_here'  https://www.nerdfonts.com/cheat-sheet
symbol = "Place_a_icon_here "
style = "fg:color_fg0 bg:color_green"
format = "[ $symbol$output ]($style)"

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
