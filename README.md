# flywheel/helm

Alpine-based utility image for Helm chart linting and validation.

## Usage

This image is used within the `test:helm-check` pre-commit hook and CI job in
[`tools/etc/qa-ci`](https://gitlab.com/flywheel-io/tools/etc/qa-ci).

To run the image directly on any project folder in debug mode:

```bash
docker run --rm -itv $(pwd):/src -e TRACE=1 flywheel/helm
```

## Included actions

- Update the helm chart version to that of the poetry package or git repo
- Update the helm image tag to that same version
- Run `helm dep up` to make sure the dependencies are available and up-to-date
- Run `helm-docs` to get auto-generated chart docs in `helm/README.md`
- Run [`helm lint`](https://helm.sh/docs/helm/helm_lint/)
- Run [`kubeval`](https://www.kubeval.com/)
- Run [`yamllint`](https://www.kubeval.com/) on the rendered tests

## Development

Install the `pre-commit` hooks before committing changes:

```bash
pre-commit install
```

To build the image locally:

```bash
docker build -t flywheel/helm .
```

## Publishing

Images are published on every successful CI build to
[dockerhub](https://hub.docker.com/repository/docker/flywheel/helm/tags?page=1&ordering=last_updated).

## License

[![MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)
