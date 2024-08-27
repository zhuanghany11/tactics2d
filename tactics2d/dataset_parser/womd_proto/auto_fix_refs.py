#!/usr/bin/env python3

import os
import re
import sys

def fix_imports(file_path, base_path, pb_version):

    import_regex = r'^import (\w+_pb2) as (\w+_pb2)'


    with open(file_path, 'r') as file:
        content = file.readlines()


    new_content = []
    for line in content:

        match = re.match(import_regex, line)
        if match:

            new_module_path = f'tactics2d.dataset_parser.womd_proto.{pb_version}.{match.group(1)}'
            new_line = re.sub(import_regex, f'import {new_module_path} as {match.group(2)}', line)
            new_content.append(new_line)
        else:
            new_content.append(line)


    if new_content != content:
        with open(file_path, 'w') as file:
            file.writelines(new_content)
        print(f'Updated import statements in {file_path}')

def main():
    if len(sys.argv) != 4:
        print("Usage: python auto_fix_refs.py <file_path> <base_path> <pb_version>")
        sys.exit(1)

    file_path = sys.argv[1]
    base_path = sys.argv[2]
    pb_version = sys.argv[3]

    fix_imports(file_path, base_path, pb_version)

if __name__ == "__main__":
    main()