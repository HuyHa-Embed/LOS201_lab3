import sys, os, time
sys.path.insert(0, os.path.expanduser('~/embedded_lab3/tools'))
import qemu_session as q
H = os.path.expanduser('~/embedded_lab3')
c = q.boot(f'{H}/logs/qemu_part_bc.txt')
out = {}
def r(name, cmd, t=600):
    out[name] = q.run(c, cmd, t)
    print('>>', cmd); print(out[name])
r('uname', 'uname -a; free | head -3; cat /proc/cpuinfo | grep -E "model name|Features" | head -2')
# B.5: do VmSize/VmRSS truoc & sau khi chay (ung dung tu doc /proc/self/status)
r('mem_leaky', 'leaky_app_arm 2>&1 | grep -E "truoc|sau"')
r('mem_fixed', 'leaky_app_arm_fixed 2>&1 | grep -E "truoc|sau"')
# B.5: quan sat process dang song qua /proc/PID/status va maps
r('proc_pid', 'sleep 30 & PID=$!; grep -E "VmSize|VmRSS|VmData|VmStk" /proc/$PID/status; echo ---maps---; head -20 /proc/$PID/maps; kill $PID')
# C.4: ARM profile
r('time_arm', 'time perf_target_arm')
r('strace_arm', 'strace -c perf_target_arm 2>&1')
r('strace_arm_full', 'strace -o /tmp/trace.txt perf_target_arm >/dev/null; wc -l /tmp/trace.txt; head -25 /tmp/trace.txt')
c.close(force=True)
import json; json.dump(out, open(f'{H}/logs/qemu_bc.json','w'), indent=1)
