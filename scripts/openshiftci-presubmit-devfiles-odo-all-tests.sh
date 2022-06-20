#!/bin/sh

# fail if some commands fails
set -e
# show commands
set -x

git clone --depth=1 https://github.com/redhat-developer/odo $GOPATH/src/github.com/redhat-developer/odo
cp scripts/openshiftci-presubmit-devfiles-odo-all-tests.sh $GOPATH/src/github.com/redhat-developer/odo/scripts/

# Run performance tests on top of integration tests
sed -i 's/-randomizeAllSpecs/--noisyPendings=false/g' $GOPATH/src/github.com/redhat-developer/odo/Makefile
cd $GOPATH/src/github.com/redhat-developer/odo

export CI="openshift"
make configure-installer-tests-cluster
make bin
mkdir -p $GOPATH/bin
make goget-ginkgo
export PATH="$PATH:$(pwd):$GOPATH/bin"
export CUSTOM_HOMEDIR=$ARTIFACT_DIR

# Copy kubeconfig to temporary kubeconfig file
# Read and Write permission to temporary kubeconfig file
TMP_DIR=$(mktemp -d)
cp $KUBECONFIG $TMP_DIR/kubeconfig
chmod 640 $TMP_DIR/kubeconfig
export KUBECONFIG=$TMP_DIR/kubeconfig

# Login as developer
oc login -u developer -p password@123

# Check login user name for debugging purpose
oc whoami

make test-integration-devfile

cp -r $GOPATH/src/github.com/redhat-developer/odo/tests/integration/reports $ARTIFACT_DIR

oc logout
