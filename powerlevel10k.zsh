prompt_krbconf() {
    if [[ -e "$KRB5CCNAME" && -n "$KRB5CCNAME_DOMAIN" && -n "$KRB5CCNAME_USER" ]]; then
        if [[ -n "$KRB5CCNAME_HOST" ]]; then
            p10k segment -f 4 -i $'\xef\x80\x87' -t "$KRB5CCNAME_DOMAIN/$KRB5CCNAME_USER@$KRB5CCNAME_HOST"
        else
            p10k segment -f 4 -i $'\xef\x80\x87' -t "$KRB5CCNAME_DOMAIN/$KRB5CCNAME_USER"
        fi
    fi
}

prompt_proxyconf() {
    declare value="$(proxyconf whereami)"
    if [[ -n "${value}" ]]; then
        p10k segment -f 2 -i $'\xf3\xb0\x81\x95' -t "${value}"
    fi
}

prompt_tunnel() {
    if ip link show tun0 &> /dev/null; then
        p10k segment -f 1 -i $'\xf3\xb0\x81\x95' -t 'tun0'
    fi
}
