#!/usr/bin/env python3
"""Run content and Godot checks with isolated user data. No third-party packages."""
import argparse
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent.parent

def run(command, env):
    result = subprocess.run(command, cwd=ROOT, env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=90)
    print(result.stdout, end='')
    if result.returncode or 'SCRIPT ERROR:' in result.stdout or '\nERROR:' in result.stdout:
        raise SystemExit(result.returncode or 1)
    return result.stdout

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--godot', default=shutil.which('godot') or shutil.which('godot4'))
    args = parser.parse_args()
    if not args.godot:
        parser.error('Pass --godot /absolute/path/to/Godot (Godot 4.3+)')
    executable = str(Path(args.godot).resolve())
    with tempfile.TemporaryDirectory(prefix='tidewrack-tests-') as directory:
        env = os.environ.copy()
        # Linux user-data isolation; runtime tests also use separate filenames.
        env['XDG_DATA_HOME'] = directory
        run([sys.executable, 'tests/validate_dialogue.py'], env)
        run([sys.executable, '-m', 'unittest', 'discover', '-s', 'tests', '-p', 'test_*.py'], env)
        run([executable, '--headless', '--editor', '--path', str(ROOT), '--import', '--quit'], env)
        run([executable, '--headless', '--path', str(ROOT), '--quit-after', '10'], env)
        result = run([executable, '--headless', '--path', str(ROOT), 'res://tests/runtime_test.tscn'], env)
        match = re.search(r'RUNTIME TESTS: (\d+) checks; 0 failures', result)
        if not match:
            raise SystemExit('Runtime test completion marker missing')
        print(f'PASS: content checks, 5 validator tests, startup, {match.group(1)} runtime checks')

if __name__ == '__main__':
    main()
