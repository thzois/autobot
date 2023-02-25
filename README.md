# Autobot

*Did you ever have to update the same, file(s) in more than one repository and found it tiresome and overwhelming?*
So did we! That’s why we developed `Autobot`, a GitHub action that copies files from one branch of a repository
to a branch of another and automatically raises a Pull Request, ready to be merged!

Autobot allows us to modify a file in one repository and propagate the change to more than 30, taking away all the burden of maintenance!

<p align="center">
  <img src="./assets/autobot.png" width="350px">
</p>

## Inputs

| Input                         | Description                                                                                 | Required |
|-------------------------------|---------------------------------------------------------------------------------------------|----------|
| git_config_user_email         | The email of the user who will commit the changes                                           | **true** |
| git_config_user_name          | The username of the user who will commit the changes                                        | **true** |
| source_dir                    | Source repository directory to copy the files from                                          | **true** |
| source_dir_copy_glob          | During copying, you can use globbing to control the patterns that will be copied to the directory of the target repo. By default extglob, dotglob and globstar are enabled                                                             | false    |
| target_repo                   | Target repository to copy the files to                                                      | **true** |
| target_dir                    | Target repository directory where the files copied from the source directory will be pushed | **true** |
| pr_target_repo_base_branch    | The branch name in which the code will be merged                                            | false    |
| pr_target_repo_compare_branch | The branch name where the changes will be pushed                                            | false    |
| pr_title                      | Pull request title                                                                          | false    |
| pr_label                      | The label to assign to the pull request                                                     | false    |
| pr_description_text           | Pull request description text                                                               | false    |

## Default values

- pr_target_repo_base_branch: `main`
- pr_target_repo_compare_branch: `autobot/$(printf '%s' "$GITHUB_SHA" | cut -c 1-7)/$GITHUB_RUN_ID-$GITHUB_RUN_ATTEMPT`
- pr_title: `[autobot] [$(date '+%d-%m-%Y %H:%M:%S')] Automated changes`
- pr_label: `autobot`
- pr_description_text: `[autobot] [$(date '+%d-%m-%Y %H:%M:%S')] Automated changes`

## Example usage

```yaml
uses: thzois/autobot@v1.0.0
env:
  GH_ACCESS_TOKEN: ${{ secrets.GH_ACCESS_TOKEN }}
with:
  git_config_user_email: 'ffp-bot@github.com'
  git_config_user_name: 'ffp-bot'
  target_repo: 'thzois/repository'
  source_dir: 'docs/'
  source_dir_copy_glob: '!(*.yaml)'
  target_dir: ''
  pr_target_repo_base_branch: 'main'
  pr_target_repo_compare_branch: 'autobot/f7fd3c9/3759722240'
  pr_title: '[autobot] [2022-01-01 10:00:00] Automated changes'
  pr_description_text: '[autobot] [2022-01-01 10:00:00] Automated changes'
  pr_label: 'autobot'
```

## Access token

For the action to be able to raise PRs to other repositories,
a personal access token is required with the following permissions:

- repo: Full control of private repositories
- admin:org (only read:org)
- write:discussion
- read:discussion

## Notes

- Autobot will attempt to *create the destination path(s)* if they do not exist
- Autobot *will overwrite existing* files in the destination path(s)
- To copy the contents of the `source_dir` without copying the `source_dir` itself, you can use `dirname/.`. In case you use globbing however, using `dirname/.` might have unwanted effects
- Autobot uses `bash` to perform all the operations and `cp` to copy the files to the  `target_dir` of the `target_repo`.
- Regaring globbing you can read more [here](https://www.linuxjournal.com/content/bash-extended-globbing)
