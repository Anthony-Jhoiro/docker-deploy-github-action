#!/bin/bash

#JSON_INPUT=$1

# Json format [{"path": "my-deployment", "service": "my-service", image: "my-image"}]
JSON_INPUT='[{"path": "examples/my-deplyment", "service": "my-service", "image": "my-image:v123"}]'

echo "::set-output name=message-title::*Version updated :*"

message="*New versions :* \n"


function update_image() {
  local row="$1"
  local decoded=$(echo "$row" | base64 --decode)
  _jq() {
    echo "$decoded" | jq -r "$1"
  }

  local path
  local service
  local image

  path=$(_jq '.path')
  service=$(_jq '.service')
  image=$(_jq '.image')

  yq -i ".services.$service.image = \"$image\"" "$path/docker-compose.yml"
  message="$message- $path [$service] => $image\n"
}

for row in $(echo "$JSON_INPUT" | jq -r '.[] | @base64'); do
  update_image "$row"
done

echo "::set-output name=message::$message"
