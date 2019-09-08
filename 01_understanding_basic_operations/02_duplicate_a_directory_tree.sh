#!/usr/bin/env  bash

# In this case find will also return . directory, so we need -p to ignore it or we set mindepth to 1 to omit it
find . -type d -exec mkdir -p /tmp/{} \;
find . -mindepth 1 -type d -exec mkdir /tmp/{} \;

# In many versions of find, {} operator won't work without whitespace seperating it from other arguments, we can use these:
find . -mindepth 1 -type d -print | sed 's@^@/tmp/@' | xargs mkdir
find . -mindepth 1 -type d -print | sed 's@^@mkdir @' | (cd /tmp; sh)
