#!/usr/bin/env python
"""
Copyright (C) 2016 Mike Mackintosh
All Rights Reserved.
"""

import zipfile
import requests
import sys
import os
import json
import re
import itertools
from os.path import basename

# Output Colors
RED="\033[38;5;196m"
ORANGE="\033[38;5;214m"
GREEN="\033[38;5;156m"
BLUE="\033[38;5;45m"
CLEAR="\033[0m"

# Output Statuses
SUCCESS="{}+{}".format(GREEN, CLEAR)
ERROR="{}#{}".format(RED, CLEAR)
WARNING="{}!{}".format(ORANGE, CLEAR)

# Configurable strings and checks
RISKY_PERMISSIONS = [
    "http://*/*",
    "https://*/*",
    "ftp://*/*",
    "<all_urls>",
    "proxy",
    "webRequest",
    "webRequestBlocking",
    "background"
]
SCAN_REGEX = re.compile(r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|https?:\/\/(?:www\.|(?!www)|[\w\.]+)[^\s\.]+\.[^\s]{2,}|www\.[^\s]+\.[^\s]{2,}|fetch\(.*?\)|get\(.*?\)|post\(.*?\))', re.MULTILINE)

# Default extension download target = NOTHING
EXTENSION_TARGET = ""

# downloadExtension will download the extension
def downloadExtension(id):
    url = "https://clients2.google.com/service/update2/crx?response=redirect&os=mac&arch=x86-64&nacl_arch=x86-64&prod=chromecrx&prodchannel=stable&prodversion=89.0&x=id%3D{}%26uc".format(id)
    local_filename = "/tmp/{}.zip".format(id)
    # NOTE the stream=True parameter
    r = requests.get(url, stream=True, allow_redirects=True)
    with open(local_filename, 'wb') as f:
        for chunk in r.iter_content(chunk_size=1024):
            if chunk:
                f.write(chunk)
    return local_filename

# Read the manifest from the downloaded ZIP file
def readManifest():
    manifest = []
    with zipfile.ZipFile(EXTENSION_TARGET) as z:
        for filename in z.namelist():
            if not os.path.isdir(filename):
                # read the file
                if filename == "manifest.json":
                    with z.open(filename) as f:
                        for line in f:
                            manifest.append(line)
    return "".join(manifest)

# Validate the manifest permissions
def validateManifestPermissions(permissions):
    for perm in permissions:
        color = GREEN
        flagged = ""
        if perm in RISKY_PERMISSIONS:
            color = RED
            flagged = " [*]"
        print("     - {}{}{}{}".format(color, perm, flagged, CLEAR))

# Loop throught the arrays of scripts
def checkScripts(scripts):
    for js in scripts:
        print("  {}{}:{}".format(ORANGE, js, CLEAR))
        for d in scanCode(js):
            print("    {}{}{}: {}{}".format(GREEN, d["lineno"], CLEAR, d["line"], CLEAR))

# Perform basic static code analysis
def scanCode(filename):
    matched_lines = []
    i = 0
    with zipfile.ZipFile(EXTENSION_TARGET) as z:
        with z.open(filename) as f:
            for line in f:
                i = i + 1
                if SCAN_REGEX.search(line):
                    line = re.sub(SCAN_REGEX, r"{}\1{}".format(RED, CLEAR), line)
                    matched_lines.append({"lineno": i, "line": line})
    return matched_lines

# Default function
def analyseExtension(id):
    # First step is to download the extension
    print("[{}] Downloading extension source".format(SUCCESS))
    sourcezip = downloadExtension(id)

    # Next step is to grab the manifest
    print("[{}] Grabbing Manifest.json".format(SUCCESS))
    manifest = json.loads(readManifest())

    # If name key exists, print it out
    if "name" in manifest:
        print("           Name: {}{}{}".format(GREEN, manifest["name"], CLEAR))

    # If short_name key exists, print it out
    if "short_name" in manifest:
        print("     Short Name: {}{}{}".format(GREEN, manifest["short_name"], CLEAR))

    # If description is set, print it out
    if "description" in manifest:
        print("    Description: {}{}{}".format(GREEN, manifest["description"], CLEAR))

    # If version set, print it out
    if "version" in manifest:
        print("        Version: {}{}{}".format(GREEN, manifest["version"], CLEAR))

    # Grab the permissions of the extension
    if "permissions" in manifest:
        print("[{}] Grabbing Permissions".format(SUCCESS))
        print("    Permissions:")
        validateManifestPermissions(manifest["permissions"])
    else:
        print("[{}] Grabbing Permissions".format(WARNING))

    # Grab the scripts that make up the code, and scan them
    if "content_scripts" in manifest:
        print("[{}] Grabbing content Scripts".format(SUCCESS))
        for scripts in manifest["content_scripts"]:
            if "js" in scripts:
                checkScripts(scripts["js"])
    else:
        print("[{}] Grabbing content scripts  [none exist]".format(WARNING))

    # Grab background scripts and scan them
    if "background" in manifest:
        print("[{}] Grabbing background scripts".format(SUCCESS))
        if "scripts" in manifest["background"]:
            checkScripts(manifest["background"]["scripts"])
        if "page" in manifest["background"]:
            scanCode(manifest["background"]["page"])
    else:
        print("[{}] Grabbing background scripts  [none exist]".format(WARNING))

    # Grab browser actions scripts and scan them
    if "browser_action" in manifest:
        print("[{}] Grabbing browser actions".format(SUCCESS))
        if "default_popup" in manifest["browser_action"]:
            scanCode(manifest["browser_action"]["default_popup"])
    else:
        print("[{}] Grabbing browser actions  [none exist]".format(WARNING))

    # Grab options page scripts and scan them
    if "options_page" in manifest:
        print("[{}] Grabbing options page".format(SUCCESS))
        scanCode(manifest["options_page"])
    else:
        print("[{}] Grabbing options page  [none exist]".format(WARNING))

# MAIN
if __name__ == '__main__':
    if len(sys.argv) == 1:
        print("Please provide a Chrome Extension ID")
        os._exit(1)

    EXTENSION_TARGET = '/tmp/{}.zip'.format(sys.argv[1])
    print("[{}] Starting Analysis of: {}{}{}".format(SUCCESS, BLUE, sys.argv[1], CLEAR))
    analyseExtension(sys.argv[1])
