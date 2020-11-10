# Micronaut Graal Tests Scheduler #

This is a companion project of https://gitlab.com/micronaut-projects/micronaut-graal-tests used to trigger the execution
 of the pipeline.

To keep track of the latest GraalVM and Micronaut commits, the files `.graal_commit` and `.mn_commit` are used and updated
 during the execution. This means that it is necessary to commit changes in this repository from the pipeline execution.

- Generate a [Personal Access Token](https://gitlab.com/profile/personal_access_tokens) with `write_repository` permissions.
- Define an "Environment variable" (Settings -> CD/CI -> Environment variables) named `CI_PUSH_REPO` with the url of the
repository that includes your username and the access token generated. For example, for this repository is
`https://USERNAME:TOKEN@gitlab.com/micronaut-projects/micronaut-graal-tests-scheduler.git`

To trigger the pipeline execution in the main repository it is also necessary to define the "Environment variable" `JOB_TRIGGER_TOKEN`.

There are also some [scheduled jobs](https://gitlab.com/micronaut-projects/micronaut-graal-tests-scheduler/pipeline_schedules)
(link only visible by members of the project) per branch and GraalVM release, that is triggered every hour to check if
there are new changes in either GraalVM or Micronaut repositories and trigger the pipeline in the main repository.

The prefix of the branch is the Micronaut version that the job is related to. The suffix of the branch is the GraalVM version:

- `dev`: GraalVM master branch (i.e: `21.0.0-dev`)
- `release`: Next GraalVM release (i.e: `20.3.0-dev`)
- `stable`: Latest GraalVM stable release (i.e: `20.3.0`)

![scheduling-pipelines](scheduling-pipelines.png)
