#!/bin/bash

function clone_or_pull_github() {
	echo Updating $1/$2

	OWNER="$1"
	REPO="$2"
	TARGET="$3"

	P=${TARGET}/${REPO}

	if [[ ! -d ${TARGET} ]]; then
		mkdir ${TARGET}
	fi

	if [[ ! -d $P ]]; then
		URL=https://github.com/$OWNER/$REPO
		( cd $TARGET; git clone -q $URL >/dev/null)
	else
		( cd $P; git pull -r >/dev/null)
	fi
}

if id -u demo >/dev/null 2>&1; then
  cd /home/demo
  clone_or_pull_github de-wiring tests-docker-hardening .
  clone_or_pull_github de-wiring containerspec .
  clone_or_pull_github de-wiring ix .
  clone_or_pull_github de-wiring docker-selinux-playground .
  clone_or_pull_github de-wiring containerwallet .
  clone_or_pull_github docker docker third-party
  clone_or_pull_github docker docker-bench-security third-party
  clone_or_pull_github cisofy lynis third-party

  # extra docker 1.8.3
  ( cd /home/demo/third-party/docker;  git fetch --tags; git checkout v1.8.3 )

else
  echo "Error: user demo does not exist."
  exit 1
fi
