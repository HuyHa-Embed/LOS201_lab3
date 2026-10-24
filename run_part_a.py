import sys, subprocess, os, time
sys.path.insert(0, os.path.expanduser('~/embedded_lab3/tools'))
import qemu_session as q
H = os.path.expanduser('~/embedded_lab3')
c = q.boot(f'{H}/logs/qemu_part_a.txt')
c.sendline('gdbserver 0.0.0.0:1234 /usr/bin/buggy_app')
c.expect('Listening on port 1234')
time.sleep(1)
with open(f'{H}/logs/gdb_session.txt', 'w') as out:
    subprocess.run([f'{H}/tools/gdb-multiarch', '-batch', '-x', f'{H}/logs/gdb_commands.gdb'],
                   stdout=out, stderr=subprocess.STDOUT, timeout=300)
try:
    c.expect(r'/ # ', timeout=30)
except Exception as e:
    print('no prompt', e)
c.close(force=True)
