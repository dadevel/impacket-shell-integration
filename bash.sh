_prompt_krbconf() {
    if [[ -e "$KRB5CCNAME" && -n "$KRB5CCNAME_DOMAIN" && -n "$KRB5CCNAME_USER" ]]; then
        echo -n $'\e[39m\xef\x80\x87 '
        if [[ -n "$KRB5CCNAME_HOST" ]]; then
            echo -n "$KRB5CCNAME_DOMAIN/$KRB5CCNAME_USER@$KRB5CCNAME_HOST"
        else
            echo -n "$KRB5CCNAME_DOMAIN/$KRB5CCNAME_USER"
        fi
        echo -n $'\e[0m'
    fi
}

_prompt_proxyconf() {
    declare value="$(proxyconf whereami)"
    if [[ -n "${value}" ]]; then
        echo -n $'\e[39m\xf3\xb0\x81\x95 '
        echo -n "${value}"
        echo -n $'\e[0m'
    fi
}

_prompt_tunnel() {
    if ip link show tun0 &> /dev/null; then
        echo -n $'\e[31m\xf3\xb0\x81\x95 '
        echo -n 'tun0'
        echo -n $'\e[0m'
    fi
}
