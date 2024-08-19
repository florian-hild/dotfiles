# Actionlint

Lint GitHub actions

Source: [rhysd/actionlint](https://github.com/rhysd/actionlint)

# Build Docker image locally
```bash
docker build -t actionlint:local .
```

# Start Docker container and lint GitHub action files
```bash
cd $GIT_REPO_BASE
docker run --rm --name gh-actionlint -v ${PWD}:/work:ro actionlint:local
```

