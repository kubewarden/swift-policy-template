#!/usr/bin/env bats

@test "reject because name is denied" {
  run kwctl run policy.wasm -r Tests/Examples/PodRequest.json --settings-json '{"deniedNames": ["nginx"]}'

  # this prints the output when one the checks below fails
  echo "output = ${output}"

  # request rejected
  [ "$status" -eq 0 ]
  [ $(expr "$output" : '.*allowed.*false') -ne 0 ]
  [ $(expr "$output" : ".*resource name 'nginx' is not allowed.*") -ne 0 ]
}

@test "accept because name is not denied" {
  run kwctl run policy.wasm -r Tests/Examples/PodRequest.json --settings-json '{"deniedNames": ["foo"]}'
  # this prints the output when one the checks below fails
  echo "output = ${output}"

  # request accepted
  [ "$status" -eq 0 ]
  [ $(expr "$output" : '.*allowed.*true') -ne 0 ]
}

@test "accept because no name is denied" {
  run kwctl run policy.wasm -r Tests/Examples/PodRequest.json --settings-json '{}'
  # this prints the output when one the checks below fails
  echo "output = ${output}"

  # request accepted
  [ "$status" -eq 0 ]
  [ $(expr "$output" : '.*allowed.*true') -ne 0 ]
}
