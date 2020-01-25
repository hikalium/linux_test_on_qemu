'use strict';
const {spawn} = require('child_process');
const {promisify} = require('util');

const localISOString = function() {
  const d = new Date(),
        pad =
            function(n) {
          return n < 10 ? '0' + n : n;
        },
        tz = d.getTimezoneOffset()  // mins
      ,
        tzs = (tz > 0 ? '-' : '+') + pad(parseInt(Math.abs(tz / 60)));

  if (tz % 60 != 0) tzs += pad(Math.abs(tz % 60));

  if (tz === 0)  // Zulu time == UTC
    tzs = 'Z';

  return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' +
      pad(d.getDate()) + 'T' + pad(d.getHours()) + ':' + pad(d.getMinutes()) +
      ':' + pad(d.getSeconds()) + tzs;
};

function spawnCommand(cmd, args, callback) {
  console.log(`run: ${cmd + ' ' + args.join(' ')}`)
  var command = spawn(cmd, args);
  var result = '';
  command.stdout.on('data', (data) => {
    result += data.toString();
  });
  command.stderr.on('data', (data) => {
    console.log(data.toString());
  });
  command.on('error', (err) => {
    return callback(err);
  });
  command.on('close', (code) => {
    return callback(null, JSON.parse(result));
  });
}

const run = promisify(spawnCommand);

const run_test =
    async (target_env, num_of_tries, cmd) => {
  const result = await run(
      'python3', ['test.py', '-c', num_of_tries, '-t', target_env, cmd]);
  return result.real_ave;
}

async function measure_app(
    target_info, num_of_tries, target_env, interval_list) {
  const result_table = [
    ['target_app', target_info.name],
    ['cmd', target_info.cmd],
    ['num_of_tries', num_of_tries],
    ['target_env', target_env],
    ['date', localISOString(new Date())],
  ];
  if(interval_list.includes(-1)) {
    result_table.push([
      'exec time without ckpt [s]',
      await run_test(target_env, num_of_tries, target_info.cmd)
    ]);
  }
  result_table.push([]);
  result_table.push(['ckpt interval [ms]', 'real [s]', 'num of ckpt']);
  for (const interval_ms of interval_list) {
    if(interval_ms < 0) continue;
    const result = await run('python3', [
      'test.py', '-c', num_of_tries, '-t', target_env,
      `ndckpt run ${interval_ms} ${target_info.cmd}`
    ]);
    result_table.push([interval_ms, result.real_ave, result.num_of_ckpt_via_ptrace_ave]);
  }
  console.log('RESULT:');
  for (const row of result_table) {
    console.log(row.join(', '));
  }
  return result_table;
}

async function
main() {
  const num_of_tries = 3;
  const target_env = 'real';
  const interval_list = [
    -1,
    1*1000,
    5*1000,
    10*1000,
    50*1000,
    0,
  ];
  const app_list = [
    {
      name: 'pi_15000',
      cmd:
          'bin/pi15000.bin',
    },
    {
      name: 'pi_30000',
      cmd:
          'bin/pi30000.bin',
    },
    /*
    {
      name: 'xz_s_ref_cld_16',
      cmd:
          '657.xz_s/xz_s 657.xz_s/cld.tar.xz 16 19cf30ae51eddcbefda78dd06014b4b96281456e078ca7c13e1c0c9e6aaea8dff3efb4ad6b0456697718cede6bd5454852652806a657bb56e07d61128434b474 536995164 539938872 8',
    },
    {
      name: 'xz_s_ref_cld_8',
      cmd:
          '657.xz_s/xz_s 657.xz_s/cld.tar.xz 8 19cf30ae51eddcbefda78dd06014b4b96281456e078ca7c13e1c0c9e6aaea8dff3efb4ad6b0456697718cede6bd5454852652806a657bb56e07d61128434b474 536995164 539938872 8',
    },
    {
      name: 'xz_s_ref_cld_32',
      cmd:
          '657.xz_s/xz_s 657.xz_s/cld.tar.xz 32 19cf30ae51eddcbefda78dd06014b4b96281456e078ca7c13e1c0c9e6aaea8dff3efb4ad6b0456697718cede6bd5454852652806a657bb56e07d61128434b474 536995164 539938872 8',
    },
    {
      name: 'xz_s_ref_cld_64',
      cmd:
          '657.xz_s/xz_s 657.xz_s/cld.tar.xz 64 19cf30ae51eddcbefda78dd06014b4b96281456e078ca7c13e1c0c9e6aaea8dff3efb4ad6b0456697718cede6bd5454852652806a657bb56e07d61128434b474 536995164 539938872 8',
    },
    {
      name: 'xz_s_ref_docs',
      cmd:
          '657.xz_s/xz_s 657.xz_s/cpu2006docs.tar.xz 6643 055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae 1036078272 1111795472 4',
    },
    {
      name: 'xz_s_ref_cld_32',
      cmd:
          '657.xz_s/xz_s 657.xz_s/cld.tar.xz 32 19cf30ae51eddcbefda78dd06014b4b96281456e078ca7c13e1c0c9e6aaea8dff3efb4ad6b0456697718cede6bd5454852652806a657bb56e07d61128434b474 536995164 539938872 8',
    },
    {
      name: 'xz_s_ref_cld_8',
      cmd:
          '657.xz_s/xz_s 657.xz_s/cld.tar.xz 8
    19cf30ae51eddcbefda78dd06014b4b96281456e078ca7c13e1c0c9e6aaea8dff3efb4ad6b0456697718cede6bd5454852652806a657bb56e07d61128434b474
    536995164 539938872 8',
    },
     {
       name: 'xz_s_ref_docs_64',
       cmd:
           '657.xz_s/xz_s 657.xz_s/cpu2006docs.tar.xz 64
     055ce243071129412e9dd0b3b69a21654033a9b723d874b2015c774fac1553d9713be561ca86f74e4f16f22e664fc17a79f30caa5ad2c04fbc447549c2810fae
     1036078272 1111795472 4',
     },
    {
      name: 'xz_s_combined',
      cmd:
          '657.xz_s/xz_s 657.xz_s/input.combined.xz 40
    a841f68f38572a49d86226b7ff5baeb31bd19dc637a922a972b2e6d1257a890f6a544ecab967c313e370478c74f760eb229d4eef8a8d2836d233d3e9dd1430bf
    6356684 -1 8',
    },
    */
  ];
  const result_list = [];
  for (const app of app_list) {
    const result =
        await measure_app(app, num_of_tries, target_env, interval_list);
    result_list.push(result);
  }
  console.log('RESULTS:');
  for (const result of result_list) {
    console.log('----');
    for (const row of result) {
      console.log(row.join(', '));
    }
  }
}

main();

