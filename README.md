# flywheel/helm

Alpine-based utility image for helm linting and validation.

## Usage

```bash
docker run -itv $(pwd):/src --rm flywheel/helm
```

## Included actions

- Update the helm chart version to that of the poetry package or git repo
- Update the helm image tag to that same version
- Run `helm dep up` to make sure the dependencies are available and up-to-date
- Run `helm-docs` to get auto-generated chart docs in `helm/README.md`
- Run [`helm lint`](https://helm.sh/docs/helm/helm_lint/)
- Run [`kubeval`](https://www.kubeval.com/)

## Publishing

Images are published on every successful CI build to
[dockerhub](https://hub.docker.com/repository/docker/flywheel/helm/tags?page=1&ordering=last_updated).

## Development

Enable [pre-commit](https://pre-commit.com) on the project:

```bash
pre-commit install
```

## License

[![MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)
