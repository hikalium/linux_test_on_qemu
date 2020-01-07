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

const run_test = async (target_env, num_of_tries, cmd) => {
  const result = await run(
      'python3',
      ['test.py', '-c', num_of_tries, '-t', target_env, cmd]);
  return result.real_ave;
}

async function main() {
  const target_app = '/bin/pi15000.bin';
  const num_of_tries = 3;
  const target_env = 'real';
  const interval_list = [
    1,
    2,
    4,
    8,
    16,
  ];
  /*
  const interval_list = [
    0,
    32,
    64,
    128,
    256,
    512,
  ];
  */
  const result_table = [
    ['target_app', target_app],
    ['num_of_tries', num_of_tries],
    ['target_env', target_env],
    ['exec time without ckpt [s]', await run_test(target_env, num_of_tries, target_app)],
    ['date', localISOString(new Date())],
    [],
    ['ckpt interval [ms]', 'real [s]'],
  ];
  for (const interval_ms of interval_list) {
    const result = await run('python3', [
      'test.py', '-c', num_of_tries, '-t', target_env,
      `ndckpt run ${interval_ms} ${target_app}`
    ]);
    result_table.push([interval_ms, result.real_ave]);
  }
  console.log('RESULT:');
  for (const row of result_table) {
    console.log(row.join(', '));
  }
}

main();

