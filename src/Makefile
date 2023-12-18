VOTE_REPO = samlotus/virtu-vote
RESULT_REPO = samlotus/virtu-result
WORKER_REPO = samlotus/virtu-worker
SEED_DATA_REPO = samlotus/virtu-seed-data
REPOSITORIES := samlotus/virtu-vote samlotus/virtu-result samlotus/virtu-worker samlotus/virtu-seed-data
TAGS := cmd comp
all: build push

build: build-cmd build-comp

build-cmd:
	docker build -t "${VOTE_REPO}":cmd ./cmd/vote/
	docker build -t "${RESULT_REPO}":cmd ./cmd/result/
	docker build -t "${WORKER_REPO}":cmd ./cmd/worker/
	docker build -t "${SEED_DATA_REPO}":cmd ./cmd/seed-data/

build-comp:
	docker build -t "${VOTE_REPO}":comp ./comp/vote/
	docker build -t "${RESULT_REPO}":comp ./comp/result/
	docker build -t "${WORKER_REPO}":comp ./comp/worker/
	docker build -t "${SEED_DATA_REPO}":comp ./comp/seed-data/

push:
	for repo in $(REPOSITORIES); do \
        for tag in $(TAGS); do \
            docker push "$$repo:$$tag" ; \
        done; \
    done