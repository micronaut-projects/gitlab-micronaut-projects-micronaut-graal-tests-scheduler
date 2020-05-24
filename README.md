# Micronaut Graal Tests Scheduler #

This is a companion project of https://gitlab.com/micronaut-projects/micronaut-graal-tests used to trigger the execution of the pipeline.

To keep track of the latest GraalVM and Micronaut commits the files `.graal_commit` and `.mn_commit` are used and updated during the execution. This means that it is necessary to commit changes in this repository from the pipeline execution. 
To do that it is necessary to generate a ssh private/public key pair and:
- Define an "Environment variable" (Settings -> CD/CI -> Environment variables) named `SSH_PRIVATE_KEY` with the private key content.
- Define a "Deploy key" (Settings -> Repository -> Deploy keys) using the public key and grant it "write access".

To trigger the pipeline execution in the main repository it is also necessary to define the "Environment variable" `JOB_TRIGGER_TOKEN`.

There is also an [scheduled job](https://gitlab.com/micronaut-projects/micronaut-graal-tests-scheduler/pipeline_schedules) (link only visible by members of the project) per branch that is triggered every hour to check if there are new changes in either GraalVM or Micronaut repositories and trigger the pipeline in the main repository.

![scheduling-pipelines](scheduling-pipelines.png)
