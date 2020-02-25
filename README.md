# Concourse Git Test Queue Resource

This is a Concourse resource that can be used in order test a list of commits, not necessarily belonging to a branch or a PR.
There are resources that let you monitor new PRs (e.g. https://github.com/telia-oss/github-pr-resource) and others that let you monitor
branches (e.g. https://github.com/concourse/git-resource). There are also resources that let you update the GitHub state of a PR or a commit (e.g. https://github.com/colstrom/concourse-github-status). No combination of the above can implement the following scenario though:

You have a pipeline that given a Git commit, does a number of things (lints, builds, tests, publishes etc). You want to avoid duplication and reuse the same jobs and tasks no matter whether that commit is being tested because it's the HEAD of a PR or because it is the HEAD of master or because you manually added that in the queue to be tested. In any case you would want to let GitHub know what the state of your commit is. This way it would also update the state of PRs.

This Resource using AWS S3 as a "database" of commits to be tested. Each commit becomes a json file on S3 with some metadata in it when you put the resource (e.g. the state of the commit). When you get the resource, you get the same json file together with a checkout of that commit. Putting the resource also updated GitHub with the commit's state.


## Get

## Put

Non optional params: commit_path and state
Optional params: todo

## Check

## Example usage
