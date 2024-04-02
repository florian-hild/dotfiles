# Mit diesen Einstellungen gibt es Probleme wenn der DSP mit C (ANSI) gestartet wird es aber eine UTF8 DB ist oder andersrum
#if locale -a | grep -q ^C.UTF-8; then
#  export LANG=C.UTF-8
#  export LC_ALL=C.UTF-8
#else
#  export LANG=C
#  export LC_ALL=C
#fi

# Expand Vars in bash tab completion
shopt | grep -qw '^direxpand' && shopt -s direxpand

# Set backspace erase key to ^H
# stty erase '^?'
