ble/prompt/backslash:krbconf() {
    if [[ -e "$KRB5CCNAME" && -n "$KRB5CCNAME_DOMAIN" && -n "$KRB5CCNAME_USER" ]]; then
        ble/prompt/print $'\e[32m'
        ble/prompt/print $'\xef\x80\x87'
        ble/prompt/print ' '
        if [[ -n "$KRB5CCNAME_HOST" ]]; then
            ble/prompt/print "$KRB5CCNAME_DOMAIN/$KRB5CCNAME_USER@$KRB5CCNAME_HOST"
        else
            ble/prompt/print "$KRB5CCNAME_DOMAIN/$KRB5CCNAME_USER"
        fi
        ble/prompt/print $'\e[0m'
        ble/prompt/print ' '
    fi
}

ble/prompt/backslash:proxyconf() {
    declare value="$(proxyconf whereami)"
    if [[ -n "${value}" ]]; then
        ble/prompt/print $'\e[32m'
        ble/prompt/print $'\xf3\xb0\x81\x95'
        ble/prompt/print ' '
        ble/prompt/print "${value}"
        ble/prompt/print $'\e[0m'
        ble/prompt/print ' '
    fi
}

ble/prompt/backslash:tunnel() {
    if ip link show tun0 &> /dev/null; then
        ble/prompt/print $'\e[31m'
        ble/prompt/print $'\xf3\xb0\x81\x95'
        ble/prompt/print ' '
        ble/prompt/print 'tun0'
        ble/prompt/print $'\e[0m'
        ble/prompt/print ' '
    fi
}
