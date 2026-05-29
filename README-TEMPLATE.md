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

---

## AI-assisted upgrade of `.cloudopsworks/vars` configuration files

This section is a machine-readable protocol for AI agents performing a seamless, non-destructive upgrade of all configuration files under `.cloudopsworks/vars/` when a new template version is released. Follow the steps below in order.

### Upgrade overview

The template version locked into this repository is recorded in `.cloudopsworks/_VERSION`. The canonical upstream source is the GitHub repository `cloudopsworks/node-app-template`, pinned to the tag that matches the content of `_VERSION`.

An upgrade merges new keys, updated comments, and structural changes from the upstream template into local files **without overwriting values the operator has already set**.

---

### Step 1 — determine current and target versions

1. Read `.cloudopsworks/_VERSION` to get the **current locked version** (e.g., `v1.4.15`).
2. The **target version** is either supplied by the operator or is the latest release tag on `cloudopsworks/node-app-template`.
3. Fetch any upstream file from GitHub using the pattern:
   ```
   https://raw.githubusercontent.com/cloudopsworks/node-app-template/<version>/<path>
   ```
   Example:
   ```
   https://raw.githubusercontent.com/cloudopsworks/node-app-template/v1.4.15/.cloudopsworks/vars/inputs-global.yaml
   ```

---

### Step 2 — identify the deployment type for each environment file

Each `inputs-<name>.yaml` file under `.cloudopsworks/vars/` maps to a specific upstream template. Determine the type using the following priority order:

**Priority 1 — `Agents:` header comment**

If the file contains an `# Agents:` line in its header block, read `cloud` and `cloud_type` directly from it:

```yaml
# Agents: cloud=aws ; cloud_type=lambda
```

Multiple valid combinations may be listed separated by `|`:

```yaml
# Agents: cloud=aws|gcp|azure ; cloud_type=kubernetes
```

**Priority 2 — fallback to `inputs-global.yaml`**

If no `# Agents:` line is present, read the active `cloud` and `cloud_type` values from `.cloudopsworks/vars/inputs-global.yaml` and apply the mapping table below.

**`cloud` / `cloud_type` → upstream template file:**

| `cloud`                  | `cloud_type`                   | Upstream template file         |
|--------------------------|--------------------------------|--------------------------------|
| `aws`                    | `eks` or `kubernetes`          | `inputs-KUBERNETES-ENV.yaml`   |
| `azure`                  | `aks` or `kubernetes`          | `inputs-KUBERNETES-ENV.yaml`   |
| `gcp`                    | `gke` or `kubernetes`          | `inputs-KUBERNETES-ENV.yaml`   |
| `aws`                    | `lambda`                       | `inputs-LAMBDA-ENV.yaml`       |
| `aws`                    | `beanstalk`                    | `inputs-BEANSTALK-ENV.yaml`    |
| `gcp`                    | `appengine`                    | `inputs-APPENGINE.yaml`        |
| `gcp`                    | `cloudrun`                     | `inputs-CLOUDRUN.yaml`         |
| `aws` / `gcp` / `azure`  | `none` or library mode         | `inputs-LIB-ENV.yaml`          |

`inputs-global.yaml` always maps to the upstream `inputs-global.yaml` regardless of cloud type.

---

### Step 3 — upgrade deployment target files

The deployment target files identified by the Step 2 mapping table — such as `inputs-KUBERNETES-ENV.yaml`, `inputs-LAMBDA-ENV.yaml`, `inputs-BEANSTALK-ENV.yaml`, `inputs-APPENGINE.yaml`, `inputs-CLOUDRUN.yaml`, `inputs-LIB-ENV.yaml`, and mobile equivalents such as `inputs-ANDROID-ENV.yaml` and `inputs-XCODE-ENV.yaml` — are **scaffolding templates**. They provide placeholder structures and documented examples, not finalized operator configuration.

**Do not merge these files. Overwrite them.**

Upgrade procedure for each deployment target file:

1. **Before overwriting** — inspect the local file and record any operator-configured values (keys that have been uncommented and set to non-placeholder values).
2. **Replace the file** — overwrite the local file entirely with the upstream template version.
3. **Re-apply operator values** — after overwriting, set each previously recorded operator-configured value at its corresponding key in the new file.
4. **Copy in absent files** — if a deployment target file is present in the upstream template but absent locally, copy it in from the upstream template as a new file.

---

### Step 4 — merge `inputs-global.yaml`

`inputs-global.yaml` requires special handling because it contains mandatory operator identity fields alongside a large body of optional commented-out sections.

Merge procedure:

1. **Retain the four mandatory identity fields** verbatim at the top of the file:
   ```yaml
   organization_name: "..."
   organization_unit: "..."
   environment_name: "..."
   repository_owner: "..."
   ```
2. **Retain `cloud` and `cloud_type`** exactly as the operator set them.
3. **For every optional commented-out section** in the upstream template, check the local file:
   - If the operator **has uncommented and configured it** — keep the operator's values; update only surrounding comment text if it changed upstream.
   - If the section **is still fully commented out locally** — replace the entire commented block with the upstream version, capturing any new fields or updated documentation within it.
4. **Append new optional sections** that appear in the upstream template but are entirely absent locally, in fully commented-out form, preserving their upstream position and comments.

---

### Step 5 — upgrade subdirectory files

Apply the merge rules from Step 4 to every file in the following subdirectories, matching each local file to its corresponding upstream file at the same relative path:

- `.cloudopsworks/vars/preview/inputs.yaml`
- `.cloudopsworks/vars/preview/values.yaml`
- `.cloudopsworks/vars/apigw/apis-global.yaml`
- `.cloudopsworks/vars/apigw/apis-dev.yaml`
- `.cloudopsworks/vars/apigw/apis-uat.yaml`
- `.cloudopsworks/vars/apigw/apis-prod.yaml`
- `.cloudopsworks/vars/helm/values-dev.yaml`
- `.cloudopsworks/vars/helm/values-uat.yaml`
- `.cloudopsworks/vars/helm/values-prod.yaml`

---

### Step 6 — update `_VERSION`

After all merges are verified correct, write the target version string (e.g., `v1.4.16`) to `.cloudopsworks/_VERSION`. This is the final step.

---

### Upgrade invariants

An agent performing this upgrade must **never**:

- Overwrite a field the operator has explicitly set to a non-placeholder value.
- Remove a commented-out operator value without first reporting it.
- Change the YAML structure of any active (uncommented) operator section.
- Alter a file's opening description comment (`# This file contains...`) unless the upstream version changed it.
- Modify `.cloudopsworks/cloudopsworks-ci.yaml`, `gitversion_*.yaml`, or any file under `.github/workflows/` as part of a vars upgrade — those follow their own upgrade path.
- Update `_VERSION` before all file merges are complete.

---

### Conflict resolution

When a merge cannot be resolved automatically (for example, the upstream template restructured a section that the operator has customized):

1. Emit a diff showing both the upstream template block and the local operator block side by side.
2. Pause and present the conflict to the operator, asking which version to keep or whether a manual merge is needed.
3. Never silently choose one side.

---

## Release Workflow — use `cw-release`

All releases **must** be performed using the `cw-release` skill from the CloudOps Works skill set. Do **not** create release branches, hotfix branches, version tags, or release PRs manually — the skill owns the full GitFlow-aware release lifecycle for this repository.

### When to invoke `cw-release`

Use it whenever you are asked to:
- Release, ship, or publish a new version (patch, minor, or major)
- Create a hotfix or patch release
- Create a release branch or feature-merge PR
- Tag and publish a version

### How to run it

In Claude Code (CLI, IDE extension, or web):

```
/cw-release
```

### What the skill does

1. Detects the GitVersion flow in use (`gitversion_gitflow.yaml` or `gitversion_githubflow.yaml`).
2. Reads the repo-local release policy from `.cloudopsworks/cloudopsworks-ci.yaml`.
3. Drives the shared tronador `make` / `gh` release path end-to-end.
4. Creates the correct branch, PR, tag, and GitHub Release in the right sequence.

> **Do not** run `git tag`, `gh release create`, or `make release` directly. Always let `cw-release` orchestrate these steps to keep version history and CI consistent.
