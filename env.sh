# Moi truong cong cu cuc bo (khong can sudo) cho LAB-03
T=$HOME/embedded_lab3/tools/host
export PATH=$T/usr/bin:$PATH
export LD_LIBRARY_PATH=$T/usr/lib/x86_64-linux-gnu
export VALGRIND_LIB=$T/usr/libexec/valgrind
alias gdb-multiarch="$T/usr/bin/gdb-multiarch --data-directory=/usr/share/gdb"
