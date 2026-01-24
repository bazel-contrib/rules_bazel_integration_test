# Release Process

## Creating a New Release

To create a new release:

1. Navigate to the GitHub Actions tab in the repository
2. Select the **Create Release** workflow
3. Click **Run workflow**
4. Specify the release tag (e.g., `v1.2.3`)
5. Click **Run workflow** to start the process

The workflow will:

- Create a git tag with the specified version
- Generate release notes
- Publish the release on GitHub

## Publishing to Bazel Central Registry

Once the release is successfully created, the **Publish to BCR** workflow will automatically
trigger and:

- Create a pull request to the Bazel Central Registry
- Include all necessary metadata and configuration from the `.bcr/` directory

The BCR pull request will need to be reviewed and merged by the Bazel Central Registry
maintainers before the release becomes available to Bazel users.

## Manual Publishing

If needed, you can manually trigger the publish workflow:

1. Navigate to the GitHub Actions tab
2. Select the **Publish to BCR** workflow
3. Click **Run workflow**
4. Specify the release tag to publish (e.g., `v1.2.3`)
5. Click **Run workflow**
