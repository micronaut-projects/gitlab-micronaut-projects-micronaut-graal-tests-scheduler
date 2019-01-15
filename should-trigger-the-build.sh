#!/bin/bash

curl https://api.github.com/repos/oracle/graal/commits/master | jq '{sha: .sha}' > .tmp_graal
curl https://api.github.com/repos/micronaut-projects/micronaut-core/commits/master | jq '{sha: .sha}' > .tmp_micronaut

GRAAL_CURRENT_COMMIT=$(cat .graal_master_commit)
GRAAL_LAST_COMMIT=$(cat .tmp_graal)

MN_CURRENT_COMMIT=$(cat .mn_master_commit)
MN_LAST_COMMIT=$(cat .tmp_micronaut)

echo "Graal current commit: $GRAAL_CURRENT_COMMIT"
echo "Graal last commit: $GRAAL_LAST_COMMIT"
echo "Micronaut current commit: $MN_CURRENT_COMMIT"
echo "Micronaut last commit: $MN_LAST_COMMIT"

if [ "$GRAAL_CURRENT_COMMIT" != "$GRAAL_LAST_COMMIT" ] || [ "$MN_CURRENT_COMMIT" != "$MN_LAST_COMMIT" ]; then
    echo "Something changed, triggering the build..."
    curl -X POST -F token=$JOB_TRIGGER_TOKEN -F ref=$CI_BUILD_REF_NAME https://gitlab.com/api/v4/projects/10315337/trigger/pipeline


    # Commit the new hashes to the same branch
    export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i .ssh/id_rsa-gitlab-ci"

    mkdir -pvm 0700 .ssh
    echo "$SSH_PRIVATE_KEY" > .ssh/id_rsa-gitlab-ci
    chmod 0400 .ssh/id_rsa-gitlab-ci
    git checkout $CI_BUILD_REF_NAME
    git config user.email "$(echo $GITLAB_USER_EMAIL)"
    git config user.name "$(echo $GITLAB_USER_NAME)"

    cp .tmp_graal .graal_master_commit
    cp .tmp_micronaut .mn_master_commit

    git add .graal_master_commit .mn_master_commit
    git commit -m "[ci skip] Update Micronaut and GraalVM latest commits"

    git remote set-url --push origin $(perl -pe 's#.*@(.+?(\:\d+)?)/#git@\1:#' <<< $CI_REPOSITORY_URL)
    git push --all
fi;
