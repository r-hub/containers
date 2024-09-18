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

# some hardcoded platforms and secrets
testplatforms = {
    's390x': 'linux/s390x'
}
platforms = {
    's390x': 'linux/s390x',
    'rhel8': 'linux/amd64,linux/arm64',
    'rhel9': 'linux/amd64,linux/arm64'
}
conf = [ {
    'container': c,
    'testplatform': testplatforms[c] if c in testplatforms else 'linux/amd64',
    'platform': platforms[c] if c in platforms else 'linux/amd64'
} for c in conts ]

print(json.dumps(conf))
