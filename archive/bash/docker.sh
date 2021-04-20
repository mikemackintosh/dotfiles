# Start the docker machine instance
function ds() {
  IS_RUNNING=$((docker-machine ls | grep default | grep Running > /dev/null && echo $?) || echo 1)
  if [[ $IS_RUNNING -eq 1 ]]; then
    echo "Starting Docker Machine..."
    docker-machine start default
  fi
  echo "Setting Docker Machine environment..."
  eval $(docker-machine env default)
  export DOCKER_IP=$(docker-machine ip default)
  echo -n "Docker can be reached at: $DOCKER_IP"
}

# helper to restart docker machine
function dr() {
  docker-machine restart default
}

# Helpers to clean up docker
function dclean(){
  docker ps -a -f="status=exited" | awk '{print $1}' | xargs docker rm 2>/dev/null
  docker images | grep "<none>" | awk '{print $3}' | xargs docker rmi 2>/dev/null
}
