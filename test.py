#!/usr/bin/env python3
import pexpect
import time
import itertools
import csv
import random
import os
import platform
import datetime
import sys
import json
import parse
import argparse

def launch_sol():
    p = pexpect.spawn("/home4/hikalium/SMCIPMITool_2.22.0_build.190701_bundleJRE_Linux_x64/SMCIPMITool 192.168.4.112 ADMIN ADMIN sol activate")
    p.expect(r"exit")
    print('SOL launched', file=sys.stderr, flush=True, end="")
    return p
def launch_qemu_serial():
    p = pexpect.spawn("telnet localhost 1235")
    p.expect(r"Connected")
    print('QEMU serial connected', file=sys.stderr, flush=True, end="")
    p.sendline();
    p.expect(r"/ #")
    print('Prompt found', file=sys.stderr, flush=True, end="")
    return p

def read_time(dst, type_str):
    p.expect(type_str + r'\t(\d| |\.)+m(\d| |\.)+s')
    s = p.after.decode("utf-8");
    dst[type_str + '_str'] = s;
    print(s, file=sys.stderr, flush=True, end='');
    parsed = parse.parse(type_str + '\t{:d}m {:f}s', s);
    dst[type_str] = (parsed[0] * 60 + parsed[1]);
    return dst[type_str]

def read_int(dst, type_str):
    p.expect(type_str + r': \d+')
    s = p.after.decode("utf-8");
    print(s, file=sys.stderr, flush=True, end='');
    parsed = parse.parse(type_str + ': {:d}', s);
    dst[type_str] = parsed[0];
    return dst[type_str]

def removeControlCharacter(s):
    ret = ''
    for c in s:
        ord_num = ord(c)
        #制御文字
        if(ord_num <= 31):
            continue;
        ret += c
    return ret

def test_pi(p, script_path, num_of_tries):
    result = {
        'date': datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        'target': script_path,
        'num_of_tries': num_of_tries,
    }
    tries = []

    real_sum = 0
    user_sum = 0
    sys_sum = 0
    num_of_ckpt_via_ptrace_sum = 0
    for i in range(num_of_tries):
        marker = str(int(time.time()));
        p.sendline("");
        p.sendline("echo " + marker);
        p.expect(marker)  # Read out echo
        print('Marker found', file=sys.stderr, flush=True, end="")
        p.expect('\r\n')

        cmd = "ndckpt init && time sh -c '" + script_path + " && end_of=END_OF_ && test_run=TESTRUN && echo ${end_of}${test_run}'";
        p.sendline(cmd)
        print("process launched: " + cmd, file=sys.stderr, flush=True, end="");
        this_try = {}
        while True:
            idx = p.expect(["END_OF_TESTRUN", "NDCKPT_CHILD_EXITED", r"\r\n"], timeout=60*30)
            if idx == 0:
                break
            if idx == 1:
                read_int(this_try, 'child_pid');
                read_int(this_try, 'child_retv');
                num_of_ckpt_via_ptrace_sum += read_int(this_try, 'num_of_ckpt_via_ptrace');
                break
            print(removeControlCharacter(p.before.decode("utf-8")), end = "", flush=True, file=sys.stderr);
        print("exited", file=sys.stderr, flush=True, end="") 
        real_sum = real_sum + read_time(this_try, 'real');
        user_sum = user_sum + read_time(this_try, 'user');
        sys_sum = sys_sum + read_time(this_try, 'sys');
        tries.append(this_try);

    result['tries'] = tries;
    result['real_ave'] = real_sum / num_of_tries;
    result['user_ave'] = user_sum / num_of_tries;
    result['sys_ave'] = sys_sum / num_of_tries;
    result['num_of_ckpt_via_ptrace_ave'] = num_of_ckpt_via_ptrace_sum / num_of_tries;

    print(json.dumps(result, indent=2))
    print("done\n", file=sys.stderr, flush=True, end="") 
    p.expect(r"/ #")
    print('Prompt found', file=sys.stderr, flush=True, end="")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='NDCKPT evaluator')
    parser.add_argument('command', metavar='CMD',
                        help='Command to evaluate')
    parser.add_argument('-c', '--count', type=int, dest='count', default=3, help='Iteration count. default = %(default)s')
    parser.add_argument('-t', dest='target', choices=['qemu', 'real'], default='qemu', help='Target machine')
    args = parser.parse_args()

    if args.target == 'qemu':
        p = launch_qemu_serial()
    else:
        p = launch_sol()
    test_pi(p, args.command, args.count)
