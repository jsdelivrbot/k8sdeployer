#!/bin/sh

# check if vagrant up needs to be called
vagrant status | grep "not created" -q
[ $? -eq 0 ] && vagrant up

# build the deployer image first
./build.sh

# setup a docker container that abstracts the steps required to
# setup a k8s cluster
docker run -itd --name deployer -h DEPLOYER\
       -v /var/run/docker.sock:/var/run/docker.sock\
       -v `pwd`/docker-machine-conf:/root/.docker/machine\
       -v `pwd`/ssh_config:/root/.ssh\
       -v `pwd`/inventory.yml:/inventory.yml\
       -v `pwd`/inventory.dat:/inventory.dat\
       -v `pwd`/playbooks:/playbooks\
       -v `pwd`/scripts:/scripts\
       -v `pwd`/helm_repo:/root/.helm/repository\
       -e KUBECONFIG=/playbooks/kubelet.conf\
       -e http_proxy=$http_proxy\
       -e https_proxy=$https_proxy\
       -e no_proxy=$(grep no_proxy inventory.yml | cut -d":" -f2)\
       --entrypoint /bin/bash localhost/k8sdeployer

[ $? -ne 0 ] && exit $?

docker exec -it deployer /scripts/deploy.sh
