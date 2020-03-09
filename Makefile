.PHONY: all test yamls
.FORCE:

GO_CMD := go

IMAGE_BUILD_CMD := docker build
IMAGE_BUILD_EXTRA_OPTS :=
IMAGE_PUSH_CMD := docker push

VERSION := $(shell git describe --tags --dirty --always)

IMAGE_REGISTRY := quay.io/kubernetes_incubator
IMAGE_NAME := node-feature-discovery
IMAGE_TAG_NAME := $(VERSION)
IMAGE_REPO := $(IMAGE_REGISTRY)/$(IMAGE_NAME)
IMAGE_TAG := $(IMAGE_REPO):$(IMAGE_TAG_NAME)
K8S_NAMESPACE := kube-system
KUBECONFIG :=
E2E_TEST_CONFIG :=

all: image

image:
	$(IMAGE_BUILD_CMD) --build-arg NFD_VERSION=$(VERSION) \
		-t $(IMAGE_TAG) \
		$(IMAGE_BUILD_EXTRA_OPTS) ./

mock:
	mockery --name=FeatureSource --dir=source --inpkg --note="Re-generate by running 'make mock'"
	mockery --name=APIHelpers --dir=pkg/apihelper --inpkg --note="Re-generate by running 'make mock'"
	mockery --name=LabelerClient --dir=pkg/labeler --inpkg --note="Re-generate by running 'make mock'"

test:
	$(GO_CMD) test ./cmd/... ./pkg/...

e2e-test:
	$(GO_CMD) test -v ./test/e2e/ -args -nfd.repo=$(IMAGE_REPO) -nfd.tag=$(IMAGE_TAG_NAME) -kubeconfig=$(KUBECONFIG) -nfd.e2e-config=$(E2E_TEST_CONFIG)

push:
	$(IMAGE_PUSH_CMD) $(IMAGE_TAG)
