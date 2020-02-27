# Concourse Git Test Queue Resource

This is a Concourse resource that can be used in order test a list of commits, not necessarily belonging to a branch or a PR.
There are resources that let you monitor new PRs (e.g. https://github.com/telia-oss/github-pr-resource) and others that let you monitor
branches (e.g. https://github.com/concourse/git-resource). There are also resources that let you update the GitHub state of a PR or a commit (e.g. https://github.com/colstrom/concourse-github-status). No combination of the above can implement the following scenario though:

You have a pipeline that given a Git commit, does a number of things (lints, builds, tests, publishes etc). You want to avoid duplication and reuse the same jobs and tasks no matter whether that commit is being tested because it's the HEAD of a PR or because it is the HEAD of master or because you manually added that in the queue to be tested. In any case you would want to let GitHub know what the state of your commit is. This way it would also update the state of PRs.

This Resource using AWS S3 as a "database" of commits to be tested. Each commit becomes a json file on S3 with some metadata in it when you put the resource (e.g. the state of the commit). When you get the resource, you get the same json file together with a checkout of that commit. Putting the resource also updated GitHub with the commit's state.

## Check

The check action of this resource returns all the new files that appeared in the configured AWS S3 bucket since the last known version (as per: https://concourse-ci.org/implementing-resource-types.html#resource-check). The file names are in the form of `datetime-commit_sha` so they are always ordered by the date of creation (because otherwise the S3 api returns them in the order of last updated).

## Get

The get action of this resource fetches the file from AWS S3 and checks out the matching commit from the configured remote. You can configure your get step like this:

```
resources:
- name: commit-to-test
  type: concourse-git-queue
  source:
    bucket: ((build-queue-aws-s3-bucket))
    bucket_subfolder: build-queue
    aws_access_key_id: ((aws-access-key))
    aws_secret_access_key: ((aws-secret-key))
    access_token: ((github-access-token))

- get: commit-to-test
  trigger: true
```

Two additional files will be created for your convenience:

```
.git/resource/ref
.git/resource/version
```

The first one is the commit sha and the second is the version as understood by Concourse. You will probably need both files in the put action (see below).

## Put

The put action of this resource, updates the S3 file and sends the commit status to GitHub (https://developer.github.com/v3/repos/statuses/). The first time you call the put action,
you probably want to queue a new build. That means, you want to create a file that doesn't exist. Simply omitting the `version_path` parameter will do exactly that.
Here is an example of a put action that creates a new file on S3:

```
- put: commit-to-test
  params: &commit-status
    commit_path: "pr-resource/.git/resource/head_sha"
    remote_path: "output/remote"
    description: "Queued"
    state: "pending"
    contexts: >
      lint,build,deploy,test,publish
    trigger: "PR"
```

Here is what each param means:

- commit_path [mandatory]: Points to a file with the commit_sha. Various resources (e.g. [github-pr-resource](https://github.com/telia-oss/github-pr-resource), [git-resource](https://github.com/concourse/git-resource)) provide this file on a different path. This will be the commit you are going to test.
- remote_path: Points to a file with the GitHub remote. For example the correct value for this repository would be `SUSE/concourse-git-queue`. You need this because if you are trying to test a commit from a fork (e.g. someone opened a PR against your repository from their own fork), the commit won't exist in your repository so you have to let the resource know where to find the commit.
- remote: You can use this variable instead of `remote_path` if you want to hardcode the value. For example with `git-resource` you always know your remote thus it can be hardcoded. If you specify both `remote` and `remote_path` then `remote` takes precedence.
- description: This is sent to GitHub as the explanation of the commit status.
- state [mandatory]: This is the state written in the S3 file for the specified contexts (see next) and also sent to GitHub as the commit status for the specified contexts.
- contexts: A comma separated list of contexts. Normally each job in your pipeline would like to update one of the contexts (e.g. test, build etc) but you may want to set them all to `pending` with one put command.
- trigger: This is simply metadata in order to keep track of what kind of resource queued the build in the first place. This is free text.


After running a job (e.g. your run lint on your code), you may want to simply send the status of that specific context to GitHub. You can achieve that with a smaller set of params. E.g.

```
put: commit-to-test
params:
  description: "Lint was successful"
  commit_path: "commit-to-test/.git/resource/ref"
  version_path: "commit-to-test/.git/resource/version"
  state: "success"
  contexts: "lint"
```

Here you can see why the 2 files created by the `in` action are needed. You don't want to create a new file on S3 but you want to update an existing one. For the resource to be able to find the correct file you need to tell it what the version is. Although the resource could find the commit SHA from the S3 file, we force the use of `commit_sha` in every case so you don't have to remember if you need that or not (and we save some logic in the `out` scripts :) ). The example above will only change the status of the lint context inside the S3 file and also update that context on GitHub. Good to remember that "there is a limit of 1000 statuses per sha and context within a repository" on GitHub (https://developer.github.com/v3/repos/statuses/#create-a-status).

**Remember**: If you don't specify `version_path` in put params, you will create a new version of the resource every time!

## Example

A more complete example of how this resource can be used is this:

```
TODO:
```
