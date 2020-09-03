#!/usr/bin/python3

import os
import glob
import shutil
import multiprocessing
import logging as log
import sys

log.basicConfig(stream=sys.stderr, level=os.environ.get("LOG_LEVEL", "WARNING"))

def is_valid_postconf_line(line):
    return not line.startswith("#") \
            and not line == ''

# Actual startup script

for postfix_file in glob.glob("/conf/*.cf"):
    conf.jinja(postfix_file, os.environ, os.path.join("/etc/postfix", os.path.basename(postfix_file)))
    
# Run Podop and Postfix
os.system("/usr/libexec/postfix/post-install meta_directory=/etc/postfix create-missing")
# Before starting postfix, we need to check permissions on /queue
# in the event that postfix,postdrop id have changed
os.system("postfix set-permissions")
os.system("postfix start-fg")
