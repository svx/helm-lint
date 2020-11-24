# flywheel/helm

Alpine-based utility image for helm linting and validation.

## Usage

```bash
docker run -itv $(pwd):/src --rm flywheel/helm helm lint helm/*
```

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
