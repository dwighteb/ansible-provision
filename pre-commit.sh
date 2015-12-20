#!/bin/sh -e

for x in `find playbook serverspec -name secrets.*`
do
  if egrep -q '^\$ANSIBLE_VAULT.*AES256' ${x}
  then
    :
  else
    echo "${x} has not been encrypted."
    exit 1
  fi
done
