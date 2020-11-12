image_name := aiogram/telegram-bot-api
image_tag := $(shell date +%Y%m%d)

.PHONY: update
update:
	git submodule update --init --recursive --remote --merge

.PHONY: build
build:
	docker build -t $(image_name):$(image_tag) .
	docker tag $(image_name):$(image_tag) $(image_name):latest

.PHONY: publish
publish:
	docker push $(image_name):$(image_tag)
	docker push $(image_name):latest

.PHONY: release
release: update build publish
