#!/usr/bin/env python3

import yaml
import json
import argparse

parser = argparse.ArgumentParser(description="Print R-builds platforms as JSON.")
parser.add_argument(
    'platforms',
    type = str,
    nargs = '?',
    default = 'all',
    help = 'Comma-separated list of platforms. Default is "all" to use all platforms.'
)
args = parser.parse_args()

with open("docker-compose.yml", "r") as stream:
    try:
        conf = yaml.safe_load(stream)
        serv = conf.get("services")
        keys = serv.keys()
        skeys = [ str(key) for key in keys ]
        if args.platforms != 'all':
            platforms = args.platforms.split(",")
            skeys = [ p for p in platforms if p in skeys ]
        print(json.dumps(skeys))

    except yaml.YAMLError as exc:
        print(exc)
