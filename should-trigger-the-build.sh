#!/bin/bash

MICRONAUT_BRANCH=3.4.x

curl -s https://api.github.com/repos/micronaut-projects/micronaut-core/commits/$MICRONAUT_BRANCH | jq -r .sha > .tmp_micronaut

MN_PREVIOUS_COMMIT=$(cat .mn_commit)
MN_NEW_COMMIT=$(cat .tmp_micronaut)

echo "Micronaut previous commit: $MN_PREVIOUS_COMMIT"
echo "Micronaut new commit: $MN_NEW_COMMIT"

if [ "$MN_PREVIOUS_COMMIT" != "$MN_NEW_COMMIT" ] || [ "$MANUAL" == "true" ] ; then
    echo "Something changed, triggering the build..."
    curl -s -X POST \
         -F token=$JOB_TRIGGER_TOKEN \
         -F ref=$CI_BUILD_REF_NAME \
         -F "variables[MN_PREVIOUS_COMMIT]=$MN_PREVIOUS_COMMIT" \
         -F "variables[MN_NEW_COMMIT]=$MN_NEW_COMMIT" \
         https://gitlab.com/api/v4/projects/10315337/trigger/pipeline

    git checkout $CI_BUILD_REF_NAME
    git config user.email "$(echo $GITLAB_USER_EMAIL)"
    git config user.name "$(echo $GITLAB_USER_NAME)"

    cp .tmp_micronaut .mn_commit

    git add .mn_commit
    git commit -m "[ci skip] Update Micronaut latest commit ${MICRONAUT_BRANCH}"

    git remote set-url --push origin "${CI_PUSH_REPO}"
    git push --all
fi;
