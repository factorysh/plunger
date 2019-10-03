NAME:=$(shell basename `pwd`)
PACKAGE:=$(shell echo $(NAME) | sed -e 's/-/_/g')
SCRIPT=$(NAME)

venv:
	python3 -m venv venv
	./venv/bin/pip install -U pip
	./venv/bin/pip install wheel
	./venv/bin/pip install -r requirements.txt

freeze: clean venv
	venv/bin/pip install -Ue .
	venv/bin/pip freeze | sed -e 's/-e .*/-e ./' \
		| grep -v pkg-resources \
		> requirements.txt

docker-freeze:
	mkdir -p ~/.cache/pip
	docker run --rm -u `id -u` \
		-w /opt/plunger \
		-v $(PWD):/opt/plunger \
		-v $(HOME)/.cache:/.cache \
		-e PIP_CACHE_DIR=/.cache \
		bearstech/python-dev:3
		make freeze

release:
	# zest.releaser must be installed somewhere in your PATH
	fullrelease

clean:
	rm -rf venv *.egg-info pip-selfcheck.json .Python .coverage .pytest_cache */__pycache__
