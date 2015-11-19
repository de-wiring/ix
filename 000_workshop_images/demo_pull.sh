#!/bin/bash

function clone_or_pull_github() {
	echo Updating "$1"/"$2"

	OWNER="$1"
	REPO="$2"
	TARGET="$3"

	P=${TARGET}/${REPO}

	if [[ ! -d ${TARGET} ]]; then
		mkdir "${TARGET}"
	fi

	if [[ ! -d $P ]]; then
		URL=https://github.com/$OWNER/$REPO
		( cd "$TARGET" || exit_on_error "ERROR: directory does not exist. Exiting."; git clone -q "$URL" >/dev/null)
	else
		( cd "$P" || exit_on_error "ERROR: directory does not exist. Exiting."; git pull -r >/dev/null)
	fi
}

function exit_on_error() {
    echo "$1"
    exit 1
}

if id -u demo >/dev/null 2>&1; then
  cd /home/demo || exit_on_error "ERROR: directory does not exist. Exiting."
  clone_or_pull_github de-wiring tests-docker-hardening .
  clone_or_pull_github de-wiring containerspec .
  clone_or_pull_github de-wiring ix .
  clone_or_pull_github de-wiring docker-selinux-playground .
  clone_or_pull_github de-wiring containerwallet .
  clone_or_pull_github docker docker third-party
  clone_or_pull_github docker docker-bench-security third-party
  clone_or_pull_github cisofy lynis third-party
  sudo chown -R root. /home/demo/third-party/lynis
  sudo chmod 640 /home/demo/third-party/lynis/include/consts
  sudo chmod 640 /home/demo/third-party/lynis/include/functions

  # extra docker 1.8.3
  ( cd /home/demo/third-party/docker || exit_on_error "ERROR: directory does not exist. Exiting.";  git fetch --tags; git checkout v1.8.3 )

else
  exit_on_error "ERROR: user demo does not exist. Exiting."
fi
