#!/bin/sh

#docker rm -f deployer_shell > /dev/null 2>&1

# make sure the helion/k8sdeployer images is built
./build.sh

# setup a docker container that abstracts the steps required to
# setup a k8s cluster
#docker run -it --name deployer_shell -h DEPLOYER\
docker run -it --rm -h DEPLOYER\
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
       --entrypoint $( [ $# -eq 0 ] && echo /bin/bash || echo ansible) localhost/k8sdeployer $( [ $# -ne 0 ] && echo "-i /inventory.dat") $@
