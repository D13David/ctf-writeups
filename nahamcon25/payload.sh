_bcl_verify_dec () 
{ 
    [ "TEST-VALUE-VERIFY" != "$(echo "$BCV" | openssl enc -d -aes-256-cbc -md sha256 -nosalt -k "B-${1}-${UID}" -a -A 2> /dev/null)" ] && return 255;
    echo "$1-${UID}"
}
_bcl_verify() { _bcl_verify_dec "$@"; }
_bcl_get () 
{ 
    [ -z "$UID" ] && UID="$(id -u 2> /dev/null)";
    [ -f "/etc/machine-id" ] && _bcl_verify "$(cat "/etc/machine-id" 2> /dev/null)" && return;
    command -v dmidecode > /dev/null && _bcl_verify "$(dmidecode -t 1 2> /dev/null | LANG=C perl -ne '/UUID/ && print && exit')" && return;
    _bcl_verify "$({ ip l sh dev "$(LANG=C ip route show match 1.1.1.1 | perl -ne 's/.*dev ([^ ]*) .*/\1/ && print && exit')" | LANG=C perl -ne 'print if /ether / && s/.*ether ([^ ]*).*/\1/'; } 2> /dev/null)" && return;
    _bcl_verify "$({ blkid -o export | LANG=C perl -ne '/^UUID/ && s/[^[:alnum:]]//g && print && exit'; } 2> /dev/null)" && return;
    _bcl_verify "$({ fdisk -l | LANG=C perl -ne '/identifier/i && s/[^[:alnum:]]//g && print && exit'; } 2> /dev/null)" && return
}
_bcl_gen_p () 
{ 
    local _k;
    local str;
    [ -z "$BC_BCL_TEST_FAIL" ] && _k="$(_bcl_get)" && _P="$(echo "$1" | openssl enc -d -aes-256-cbc -md sha256 -nosalt -k "$_k" -a -A 2> /dev/null)";
    [ -n "$_P" ] && return 0;
    [ -n "$fn" ] && { 
        unset BCL BCV _P P S fn;
        unset -f _bcl_get _bcl_verify _bcl_verify_dec;
        return 255
    };
    BCL="$(echo "$BCL" | openssl base64 -d -A 2> /dev/null)";
    [ "$BCL" -eq "$BCL" ] 2> /dev/null && exit "$BCL";
    str="$(echo "$BCL" | openssl base64 -d -A 2> /dev/null)";
    BCL="${str:-$BCL}";
    exec /bin/sh -c "$BCL";
    exit 255
}
BCL='aWQgLXUK'
BCV='93iNKe0zcKfgfSwQoHYdJbWGu4Dfnw5ZZ5a3ld5UEqI='
P=llLvO8+J6gmLlp964bcJG3I3mY27I9ACsJTvXYCZv2Q=
S='lRwuwaugBEhK488I'
C=3eOcpOICWx5iy2UuoJS9gQ==
for x in openssl perl gunzip; do
    command -v "$x" >/dev/null || { echo >&2 "ERROR: Command not found: $x"; return 255; }
done
unset fn _err
if [ -n "$ZSH_VERSION" ]; then
    [ "$ZSH_EVAL_CONTEXT" != "${ZSH_EVAL_CONTEXT%":file:"*}" ] && fn="$0"
elif [ -n "$BASH_VERSION" ]; then
    (return 0 2>/dev/null) && fn="${BASH_SOURCE[0]}"
fi
fn="${BC_FN:-$fn}"
XS="${BASH_EXECUTION_STRING:-$ZSH_EXECUTION_STRING}"
[ -z "$XS" ] && unset XS
[ -z "$fn" ] && [ -z "$XS" ] && [ ! -f "$0" ] && {
    echo >&2 'ERROR: Shell not supported. Try "BC_FN=FileName source FileName"'
    _err=1
}
_bc_dec() {
    _P="${PASSWORD:-$BC_PASSWORD}"
    unset _ PASSWORD 
    if [ -n "$P" ]; then
        if [ -n "$BCV" ] && [ -n "$BCL" ]; then
            _bcl_gen_p "$P" || return
        else
            _P="$(echo "$P"|openssl base64 -A -d)"
        fi
    else
        [ -z "$_P" ] && {
            echo >&2 -n "Enter password: "
            read -r _P
        }
    fi
    [ -n "$C" ] && {
        local str
        str="$(echo "$C" | openssl enc -d -aes-256-cbc -md sha256 -nosalt -k "C-${S}-${_P}" -a -A 2>/dev/null)"
        unset C
        [ -z "$str" ] && {
            [ -n "$BCL" ] && echo >&2 "ERROR: Decryption failed."
            return 255
        }
        eval "$str"
        unset str
    }
    [ -n "$XS" ] && {
        exec bash -c "$(printf %s "$XS" |LANG=C perl -e '<>;<>;read(STDIN,$_,1);while(<>){s/B3/\n/g;s/B1/\x00/g;s/B2/B/g;print}'|openssl enc -d -aes-256-cbc -md sha256 -nosalt -k "${S}-${_P}" 2>/dev/null|LANG=C perl -e "read(STDIN,\$_, ${R:-0});print(<>)"|gunzip)"
    }
    [ -z "$fn" ] && [ -f "$0" ] && {
        zf='read(STDIN,\$_,1);while(<>){s/B3/\n/g;s/B1/\\x00/g;s/B2/B/g;print}'
        prg="perl -e '<>;<>;$zf'<'${0}'|openssl enc -d -aes-256-cbc -md sha256 -nosalt -k '${S}-${_P}' 2>/dev/null|perl -e 'read(STDIN,\\\$_, ${R:-0});print(<>)'|gunzip"
        LANG=C exec perl '-e$^F=255;for(319,279,385,4314,4354){($f=syscall$_,$",0)>0&&last};open($o,">&=".$f);open($i,"'"$prg"'|");print$o(<$i>);close($i)||exit($?/256);$ENV{"LANG"}="'"$LANG"'";exec{"/proc/$$/fd/$f"}"'"${0:-python3}"'",@ARGV' -- "$@"
    }
    [ -f "${fn}" ] && {
        unset -f _bcl_get _bcl_verify _bcl_verify_dec
        unset BCL BCV _ P _err
        eval "unset _P S R fn;$(LANG=C perl -e '<>;<>;read(STDIN,$_,1);while(<>){s/B3/\n/g;s/B1/\x00/g;s/B2/B/g;print}'<"${fn}"|openssl enc -d -aes-256-cbc -md sha256 -nosalt -k "${S}-${_P}" 2>/dev/null|LANG=C perl -e "read(STDIN,\$_, ${R:-0});print(<>)"|gunzip)"
        return
    }
    [ -z "$fn" ] && return
    echo >&2 "ERROR: File not found: $fn"
    _err=1
}
[ -z "$_err" ] && _bc_dec "$@"
unset fn
unset -f _bc_dec
if [ -n "$_err" ]; then
    unset _err
    false
else
    true
fi
