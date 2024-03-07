# Helm push action

This action packages helm charts from specified paths and publishes them to your chartmuseum.

## Usage

### `workflow.yml` Example

Place in a `.yml` file such as this one in your `.github/workflows` folder. [Refer to the documentation on workflow YAML syntax here.](https://help.github.com/en/articles/workflow-syntax-for-github-actions)

```yaml
name: Build & Push helm charts
on: push

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - uses: athomas22/helm-push-action@v0
      env:
        PATHS: 'chart1/ chart2/'
        FORCE: 'True'
        CHARTMUSEUM_URL: 'https://chartmuseum.url'
        CHARTMUSEUM_USER: '${{ secrets.CHARTMUSEUM_USER }}'
```

### Configuration

The following settings must be passed as environment variables as shown in the example. Sensitive information, especially `CHARTMUSEUM_USER` and `CHARTMUSEUM_PASSWORD`, should be [set as encrypted secrets](https://help.github.com/en/articles/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables) — otherwise, they'll be public to anyone browsing your repository.

| Key | Value | Suggested Type | Required |
| ------------- | ------------- | ------------- | ------------- |
| `PATHS` | Space-separated list of paths to the charts in the repository | `env` | **Yes** |
| `CHARTMUSEUM_URL` | Chartmuseum URL | `env` | **Yes** |
| `CHARTMUSEUM_USER` | Username for Chartmuseum  | `secret` | **Yes** |
| `CHARTMUSEUM_PASSWORD` | Password for Chartmuseum | `secret` | **Yes** |
| `FORCE` | Force chart upload (if version exists in Chartmuseum, the upload will fail without `FORCE`). Defaults to `False` if not provided. | `env` | No |

## Action versions

- v2: helm v2.17.0
- v3: helm3 v3.14.2

## License

This project is distributed under the [MIT license](LICENSE.md).
