#!/bin/bash
# Chay cac buoc can quyen root cua LAB-03 (perf + cyclictest). Cach dung:
#   sudo bash ~/embedded_lab3/tools/run_root_parts.sh
set -u
U=${SUDO_USER:-huy}; H=/home/$U; L=$H/embedded_lab3/logs; A=$H/embedded_lab3/apps
T=$H/embedded_lab3/tools/host
export PATH=$T/usr/bin:$PATH LD_LIBRARY_PATH=$T/usr/lib/x86_64-linux-gnu
mkdir -p $L

echo "=== C.3 perf (Host) ==="
cd $A
perf record -F 20000 -g -o $L/perf.data ./perf_target > /dev/null 2> $L/perf_record_msg.txt
perf report -i $L/perf.data --stdio --no-children > $L/perf_report.txt 2>/dev/null
perf report -i $L/perf.data --stdio --no-children --sort symbol,dso -g none > $L/perf_report_flat.txt 2>/dev/null
perf stat ./perf_target 2>&1 | tee $L/perf_stat.txt
perf stat -e task-clock,context-switches,page-faults,cycles,instructions,branches,branch-misses,cache-misses ./perf_target 2>&1 >/dev/null | tee -a $L/perf_stat.txt
# Flame graph (bonus)
perf record -F 9999 -g -o $L/perf_flame.data ./perf_target > /dev/null 2>&1
perf script -i $L/perf_flame.data > $L/perf_out.txt 2>/dev/null
$H/FlameGraph/stackcollapse-perf.pl $L/perf_out.txt > $L/perf_folded.txt
$H/FlameGraph/flamegraph.pl $L/perf_folded.txt > $L/flamegraph.svg

echo "=== D.2 cyclictest (Host, standard kernel) ==="
{
 echo "# uname -a";                 uname -a
 echo "# PREEMPT config";           grep -E 'PREEMPT' /boot/config-$(uname -r) | head -10
 echo "# cmdline";                  cat /proc/cmdline
 echo "# CPU";                      lscpu | grep -E 'Model name|^CPU\(s\)'
} > $L/kernel_info.txt 2>&1
stress-ng --cpu $(nproc) --io 4 --vm 2 --vm-bytes 256M --timeout 40s > $L/stress_ng.txt 2>&1 &
sleep 2
cyclictest --mlockall --threads=4 --priority=80 --interval=1000 --distance=500 --loops=10000 \
  --histogram=200 --histfile=$L/hist_standard.txt 2>&1 | tee $L/cyclictest_output.txt
wait

echo "=== D.3 gnuplot ==="
cat > $L/plot_latency.gnuplot <<GP
set terminal png size 1200,600
set output '$L/latency_histogram.png'
set title 'Cyclictest Latency Histogram - Standard Kernel (stress-ng load)'
set xlabel 'Latency (microseconds)'
set ylabel 'Number of occurrences'
set logscale y
set xrange [0:200]
set grid
set key top right
set style fill solid 0.5
plot '$L/hist_standard.txt' using 1:2 with boxes title 'Thread 0' lc rgb '#2E75B6', \
     '' using 1:3 with boxes title 'Thread 1' lc rgb '#C55A11', \
     '' using 1:4 with boxes title 'Thread 2' lc rgb '#548235', \
     '' using 1:5 with boxes title 'Thread 3' lc rgb '#7030A0'
GP
gnuplot-nox $L/plot_latency.gnuplot
chown -R $U:$U $L
echo DONE
