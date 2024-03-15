#!/usr/bin/env bash

WORKSPACE='/home/gd/workspace'
LINUX="${WORKSPACE}/linux"

find "${WORKSPACE}" -type f \( -name 'linux-*deb' -o -name 'linux-upstream*' \) -ctime +3 -exec rm {} \;

cd "${LINUX}" || exit

git checkout .
git checkout master --force

git branch | while read -r branch; do
    [[ "$branch" =~ ^v ]] && git branch -D "${branch}"
done

git pull

version=$(git tag | sort -V | grep -v -E '*-rc*' 2>/dev/null | tail -1)
git checkout tags/"${version}" -b "${version}"

make mrproper
yes "" | make localmodconfig
make -j"$(nproc --all)" bindeb-pkg
