
# Get your container's ID and IP

# List docker network ID's

```sh
docker network ls
```

# Note the applicable container id

```sh
export MY_CONTAINER_ID=<PUT_HASH_VALUE_HERE>
```

# Get IP address(es)

```sh
docker network inspect -f \
  '{{json .Containers}}' $MY_CONTAINER_ID  | \
  jq '.[] | .Name + ":" + .IPv4Address'
```
