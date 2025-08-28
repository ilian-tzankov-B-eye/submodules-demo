#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

MODULES=`grep path .gitmodules | cut -c 9-`

echo -e "${BLUE}Resyncing submodules${NC}"
rm -rf $MODULES
git submodule update --init --recursive

for module in $MODULES; do
    echo -e "${YELLOW}Resyncing submodule $module${NC}"
    cd $module
    git checkout main
    git pull origin main
    cd ..
done

git add $MODULES
git commit -m "Resync HEADs to origin main"
git push

echo -e "${GREEN}Submodules resynced to origin main${NC}"
