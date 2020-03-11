#!/bin/bash

MICRONAUT_BRANCH=master

curl -s https://api.github.com/repos/oracle/graal/commits/master | jq -r .sha > .tmp_graal
curl -s https://api.github.com/repos/micronaut-projects/micronaut-core/commits/$MICRONAUT_BRANCH | jq -r .sha > .tmp_micronaut

GRAAL_PREVIOUS_COMMIT=$(cat .graal_master_commit)
GRAAL_NEW_COMMIT=$(cat .tmp_graal)

MN_PREVIOUS_COMMIT=$(cat .mn_master_commit)
MN_NEW_COMMIT=$(cat .tmp_micronaut)

echo "Graal previous commit: $GRAAL_PREVIOUS_COMMIT"
echo "Graal new commit: $GRAAL_NEW_COMMIT"
echo "Micronaut previous commit: $MN_PREVIOUS_COMMIT"
echo "Micronaut new commit: $MN_NEW_COMMIT"

if [ "$GRAAL_PREVIOUS_COMMIT" != "$GRAAL_NEW_COMMIT" ] || [ "$MN_PREVIOUS_COMMIT" != "$MN_NEW_COMMIT" ] || [ "$MANUAL" == "true" ] ; then
    echo "Something changed, triggering the build..."
    curl -s -X POST \
         -F token=$JOB_TRIGGER_TOKEN \
         -F ref=$CI_BUILD_REF_NAME \
         -F "variables[GRAAL_PREVIOUS_COMMIT]=$GRAAL_PREVIOUS_COMMIT" \
         -F "variables[GRAAL_NEW_COMMIT]=$GRAAL_NEW_COMMIT" \
         -F "variables[MN_PREVIOUS_COMMIT]=$MN_PREVIOUS_COMMIT" \
         -F "variables[MN_NEW_COMMIT]=$MN_NEW_COMMIT" \
         https://gitlab.com/api/v4/projects/10315337/trigger/pipeline


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
