#!/usr/bin/env python3

import os
import json
import argparse

parser = argparse.ArgumentParser(description="Print containers as JSON.")
parser.add_argument(
    'containers',
    type = str,
    nargs = '?',
    default = 'all',
    help = 'Comma-separated list of containers. Default is "all" to use all containers.'
)
args = parser.parse_args()

conts = os.listdir("containers")
if args.containers != 'all':
    containers = args.containers.split(",")
    conts = [ p for p in containers if p in conts ]
print(json.dumps(conts))
