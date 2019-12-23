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

def launch_sol():
    p = pexpect.spawn("/home4/hikalium/SMCIPMITool_2.22.0_build.190701_bundleJRE_Linux_x64/SMCIPMITool 192.168.4.112 ADMIN ADMIN sol activate")
    p.expect(r"exit")
    print('SOL launched')
    return p

def read_time(dst, type_str):
    p.expect(type_str + r'\t(\d| |\.)+m(\d| |\.)+s')
    s = p.after.decode("utf-8");
    dst[type_str + '_str'] = s;
    print(s);
    parsed = parse.parse(type_str + '\t{:d}m {:f}s', s);
    dst[type_str] = (parsed[0] * 60 + parsed[1]);
    return dst[type_str]

def test_pi(p, script_path):
    num_of_tries = 3
    result = {
        'date': datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        'target': script_path,
        'num_of_tries': num_of_tries,
    }
    tries = []

    real_sum = 0
    user_sum = 0
    sys_sum = 0
    for i in range(num_of_tries):
        p.sendline("\ntime " + script_path)
        p.expect(script_path)
        print("process launched");
        this_try = {}
        sanity = []
        for x in range(10):
            p.expect(r"(OK|NG)")
            print(p.after.decode("utf-8"), end = " ", flush=True);
            sanity.append(p.after.decode("utf-8"))
        this_try['sanity'] = sanity;
        print("") 
        real_sum = real_sum + read_time(this_try, 'real');
        user_sum = user_sum + read_time(this_try, 'user');
        sys_sum = sys_sum + read_time(this_try, 'sys');
        tries.append(this_try);

    result['tries'] = tries;
    result['real_ave'] = real_sum / num_of_tries;
    result['user_ave'] = user_sum / num_of_tries;
    result['sys_ave'] = sys_sum / num_of_tries;

    print(json.dumps(result, indent=2))

if __name__ == "__main__":
    p = launch_sol()
    test_pi(p, "./test_pi15000.sh")
