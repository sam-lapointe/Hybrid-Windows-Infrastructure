#!/bin/bash
vms_status="$(jq '.resource_changes[] | {actions: .change.actions, name: .change.after.name}' tfplan.json | jq -s '.')"

for vm in $(echo "$vms_status" | jq -r '.[] | @base64'); do
  _jq() { echo ${vm} | base64 --decode | jq -r ${1}; }
  name=$(_jq '.name')
  action=$(_jq '.actions[0]')
  if [ "$name" != "null" ] && [ "$action" == "create" ]; then
    sed -i "/$name/ s/$/ status=new/" ./inventory
  fi
done