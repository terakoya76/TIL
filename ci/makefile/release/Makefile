DEFAULT_BRANCH=master

release.setup:
	@if [ -z `which bump 2> /dev/null` ]; then \
		GO111MODULE=on go get github.com/haya14busa/bump; \
		go mod tidy; \
	fi
	@if [ -z `which git-chglog 2> /dev/null` ]; then \
		GO111MODULE=on go get github.com/git-chglog/git-chglog/cmd/git-chglog; \
		go mod tidy; \
	fi
	@if [ -z `which hub 2> /dev/null` ]; then \
		GO111MODULE=on go get github.com/github/hub; \
		go mod tidy; \
	fi
	git fetch upstream --tags
	git pull --rebase upstream ${DEFAULT_BRANCH}

release.major: release.setup
	$(eval NEXT_TAG:=$(shell bump major))
	git checkout -b "release_${NEXT_TAG}"
	git-chglog --next-tag ${NEXT_TAG} -o CHANGELOG.md
	git add CHANGELOG.md
	git commit -m "docs: update CHANGELOG.md"
	hub pull-request -o -p -f -m "Release ${NEXT_TAG}" -l "bump:major" -b ${DEFAULT_BRANCH}

release.minor: release.setup
	$(eval NEXT_TAG:=$(shell bump minor))
	git checkout -b "release_${NEXT_TAG}"
	git-chglog --next-tag ${NEXT_TAG} -o CHANGELOG.md
	git add CHANGELOG.md
	git commit -m "docs: update CHANGELOG.md"
	hub pull-request -o -p -f -m "Release ${NEXT_TAG}" -l "bump:minor" -b ${DEFAULT_BRANCH}

release.patch: release.setup
	$(eval NEXT_TAG:=$(shell bump patch))
	git checkout -b "release_${NEXT_TAG}"
	git-chglog --next-tag ${NEXT_TAG} -o CHANGELOG.md
	git add CHANGELOG.md
	git commit -m "docs: update CHANGELOG.md"
	hub pull-request -o -p -f -m "Release ${NEXT_TAG}" -l "bump:patch" -b ${DEFAULT_BRANCH}

release.init: release.setup
	$(eval NEXT_TAG:="v0.0.1")
	git checkout -b "release_${NEXT_TAG}"
	git-chglog --init
	git-chglog --next-tag ${NEXT_TAG} -o CHANGELOG.md
	git add .
	git commit -m "docs: update CHANGELOG.md"
	hub pull-request -o -p -f -m "Release ${NEXT_TAG}" -l "bump:patch" -b ${DEFAULT_BRANCH}
