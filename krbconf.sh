krbconf() {
    if [[ -x /opt/archpkgs/impacket-stable/bin/python3 ]]; then
        declare -r python=/opt/archpkgs/impacket-stable/bin/python3
    else
        declare -r python=python3
    fi
    declare -x SHELL_PID="$$"
    declare result="$("${python}" ~/.local/share/impacket-shell-integration/krbconf.py "$@")"
    if (( $? == 0 )); then
        eval "${result}"
    else
        return "$?"
    fi
}

if [[ -n "$ZSH_VERSION" ]]; then
    compdef "_arguments '1:first arg:(import export set unset whoami exec)' '::optional arg:_files'" krbconf
elif [[ -n "$BASH_VERSION" ]]; then
    _krbconf_complete() {
        COMPREPLY=()
        declare cur="${COMP_WORDS[COMP_CWORD]}"
        declare prev="${COMP_WORDS[COMP_CWORD-1]}"
        if (( COMP_CWORD == 1 )); then
            COMPREPLY=($(compgen -W 'import export set unset whoami exec' -- "${cur}"))
            return 0
        fi
        if (( COMP_CWORD >= 2 )); then
            COMPREPLY=($(compgen -f -- "${cur}"))
            return 0
        fi
    }

    complete -F _krbconf_complete krbconf
fi
