#!/bin/bash

MICRONAUT_BRANCH=3.7.x
GRAALVM_BRANCH="master"

curl -s https://api.github.com/repos/oracle/graal/commits/$GRAALVM_BRANCH | jq -r .sha > .tmp_graalvm
curl -s https://api.github.com/repos/micronaut-projects/micronaut-core/commits/$MICRONAUT_BRANCH | jq -r .sha > .tmp_micronaut

GRAAL_PREVIOUS_COMMIT=$(cat .graalvm_commit)
GRAAL_NEW_COMMIT=$(cat .tmp_graalvm)

MN_PREVIOUS_COMMIT=$(cat .mn_commit)
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

    git checkout $CI_BUILD_REF_NAME
    git config user.email "$(echo $GITLAB_USER_EMAIL)"
    git config user.name "$(echo $GITLAB_USER_NAME)"

    cp .tmp_graalvm .graalvm_commit
    cp .tmp_micronaut .mn_commit

    git add .graalvm_commit .mn_commit
    git commit -m "[ci skip] Update Micronaut and GraalVM latest commits ${MICRONAUT_BRANCH}"

    git remote set-url --push origin "${CI_PUSH_REPO}"
    git push --all
fi;
