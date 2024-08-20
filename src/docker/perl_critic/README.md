# Perl linter - Perl Critic

Lint Perl scripts and modules

# Build Docker image locally
```bash
docker buildx build -t local/perl-critic:local .
```

# Start Docker container and lint files
```bash
cd $GIT_REPO_BASE
docker run --rm --name perl-critic -v ${PWD}:/work:ro local/perl-critic:local
```

