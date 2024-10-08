VERSION := $(shell grep version ./main.go|head -n1 | tr -d \"|cut -dv -f3)

build:
	go build -o jsonify-aws-dotfiles main.go

release:
ifndef GITHUB_TOKEN
	$(error GITHUB_TOKEN is not defined)
endif
	git commit -am 'Update version to $(VERSION)'||echo clean
	git tag -a $(VERSION) -m '$(VERSION)'
	git push origin $(VERSION)
	goreleaser --clean
