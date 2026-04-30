# Node App Template Usage Guide

This repository is a **starter template** for Node.js services that use the Cloud Ops Works GitHub Actions and deployment conventions.
It is not an example application by itself; you are expected to copy it, rename it, and fill in the Cloud Ops Works configuration files for your target platform.

## What this template gives you

- A Node.js package skeleton in `package.json`
- Cloud Ops Works CI/CD configuration in `.cloudopsworks/`
- GitHub Actions workflows in `.github/workflows/`
- Deployment input samples for multiple targets under `.cloudopsworks/vars/`
- API Gateway sample definitions under `apifiles/`
- Release/version helpers in `Makefile`

## Repository layout

```text
.
├── .cloudopsworks/
│   ├── _VERSION
│   ├── cloudopsworks-ci.yaml
│   ├── gitversion_gitflow.yaml
│   ├── gitversion_githubflow.yaml
│   └── vars/
├── .github/workflows/
├── apifiles/
├── Makefile
├── README-TEMPLATE.md
└── package.json
```

## Quick start

### 1. Create a repository from the template

Use GitHub's **Use this template** flow or copy the repository into a new repo.

After cloning your new repository locally:

```bash
git clone <your-new-repo-url>
cd <your-new-repo>
```

### 2. Bootstrap the package metadata

The root `Makefile` includes a `code/init` target that updates `package.json` using the current repository owner and folder name.

```bash
make code/init
```

What it does:

- sets `package.json.name` to `@<github-owner>/<repo-name>`
- sets `package.json.version` from GitVersion's `MajorMinorPatch`

### 3. Set the base application metadata

Review and update at least:

- `package.json`
- `README.md`
- `README-TEMPLATE.md` if you keep it in derived repos

At minimum, change:

- package name
- description
- scripts (`build`, `test`, `start`, etc.)
- dependencies/devDependencies

## How versioning works

This template now ships **two GitVersion presets**:

- `.cloudopsworks/gitversion_gitflow.yaml`
- `.cloudopsworks/gitversion_githubflow.yaml`

### Which one should you use?

Use **GitFlow** when your delivery process uses branches such as:

- `develop`
- `feature/*`
- `release/*`
- `hotfix/*`
- `support/*`

Use **GitHub Flow** when your delivery process is centered on:

- `main` / `master`
- short-lived feature branches
- pull requests
- optional `release/*` branches only

### Important note about the split config

This repository stores the two strategies as separate presets. If your downstream automation expects a single `gitversion.yaml`, copy the preset you want into the expected filename or update that automation to point to the desired preset explicitly.

Example:

```bash
cp .cloudopsworks/gitversion_gitflow.yaml .cloudopsworks/gitversion.yaml
```

or:

```bash
cp .cloudopsworks/gitversion_githubflow.yaml .cloudopsworks/gitversion.yaml
```

### Local version helper

The root `Makefile` also provides:

```bash
make version
```

This writes the computed version to `VERSION` and updates `package.json` without creating a git tag.

## Cloud Ops Works configuration

The main repository-level configuration lives in:

```text
.cloudopsworks/cloudopsworks-ci.yaml
```

This file controls:

- zip/include and exclude rules for build artifacts
- repository protection and reviewer configuration
- GitFlow enablement
- deployment environment mapping (`develop`, `test`, `release`, `prerelease`, `hotfix`, `support`)

### Key sections to review

#### `config`
Use this section to tune:

- branch protection
- required reviewers
- owners/reviewers
- contributor access
- GitFlow support

#### `cd`
Use this section to define how branches and tags map to environments such as:

- `dev`
- `uat`
- `prod`
- `demo`
- `hotfix`

## Environment input files

Template deployment inputs live in:

```text
.cloudopsworks/vars/
```

### Required starting point: `inputs-global.yaml`

Update this file first. It defines shared settings such as:

- `repository_owner`
- `frontend`
- Node version overrides
- Snyk / Semgrep / Trivy / SonarQube toggles
- JIRA integration
- Dependency Track
- preview environments
- observability
- target cloud and `cloud_type`

### Choose one deployment target file

Pick the file that matches the platform you will deploy to and fill it in:

- `inputs-BEANSTALK-ENV.yaml` for AWS Elastic Beanstalk
- `inputs-LAMBDA-ENV.yaml` for AWS Lambda
- `inputs-KUBERNETES-ENV.yaml` for Kubernetes/EKS/AKS/GKE-style deployments
- `inputs-CLOUDRUN.yaml` for Google Cloud Run
- `inputs-APPENGINE.yaml` for Google App Engine
- `inputs-LIB-ENV.yaml` for library-style packaging

Typical values you must replace include placeholders such as:

- `REGISTRY`
- `CLUSTER_NAME`
- `NAMESPACE`
- `AWS_REGION`
- `VERSIONS_BUCKET`
- `ORG_NAME`
- `REPO_OWNER`

## Deployment target guidance

### Kubernetes-style deployments

Use `inputs-KUBERNETES-ENV.yaml` when the application is containerized and deployed through Helm/Kubernetes.

Common fields:

- `container_registry`
- `cluster_name`
- `namespace`
- `helm_values_overrides`
- cloud-specific secret/identity sections under `aws`, `azure`, or `gcp`

### Lambda deployments

Use `inputs-LAMBDA-ENV.yaml` when the application is an AWS Lambda service.

Common fields:

- `versions_bucket`
- `container_registry` (if needed)
- `aws.region`
- `lambda.handler`
- `lambda.runtime`
- `lambda.environment.variables`
- optional schedules, VPC settings, tracing, and triggers

## API definitions

Sample API Gateway/OpenAPI files are stored in:

```text
apifiles/
```

Examples included:

- `sample-http.yaml`
- `sample-rest-custom-sqs.yaml`
- `sample-rest-lambda.yaml`
- `sample-rest-vpc-link.yaml`

If your service publishes APIs through the Cloud Ops Works gateway flow:

1. copy the closest sample
2. rename it for your service
3. replace the placeholder integrations and schema details
4. enable API deployment in `inputs-global.yaml` if needed

If your API specs live somewhere else, set:

```yaml
api_files_dir: "relative-path-to-apidefs"
```

## GitHub Actions in this template

The workflows under `.github/workflows/` provide the automation surface for:

- pull request builds
- main branch builds
- deploys
- security scanning
- automerge helpers
- environment cleanup/unlock
- JIRA integration
- slash-command flows

You usually do **not** edit all workflows immediately. Start by configuring the Cloud Ops Works input files; many workflow behaviors are driven from those files.

## Recommended onboarding sequence for a derived repository

1. Create a repo from this template.
2. Run `make code/init`.
3. Update `package.json` scripts and dependencies.
4. Choose your branching model and GitVersion preset.
5. Configure `.cloudopsworks/cloudopsworks-ci.yaml`.
6. Fill in `.cloudopsworks/vars/inputs-global.yaml`.
7. Fill in the target-specific `inputs-*.yaml` file you actually use.
8. Add or replace API specs in `apifiles/` if your service exposes APIs.
9. Update `README.md` to describe the real service.
10. Open the first PR and validate CI/CD behavior.

## Minimum checklist before first release

- [ ] `package.json` name, description, scripts, and dependencies are real
- [ ] one GitVersion strategy is selected for your automation
- [ ] `.cloudopsworks/cloudopsworks-ci.yaml` matches your repo rules
- [ ] placeholders in `.cloudopsworks/vars/*.yaml` are replaced
- [ ] unused deployment target files are either ignored or clearly left as templates
- [ ] `README.md` describes your actual service
- [ ] CI passes on a pull request

## Notes for maintainers of this template

When changing template behavior:

- keep `README-TEMPLATE.md` aligned with files that actually exist
- document any new required placeholders or bootstrap steps
- document changes to branching/versioning conventions
- call out whether downstream repos must copy, rename, or select new preset files manually
