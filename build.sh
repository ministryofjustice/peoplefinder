#!/bin/sh

# exit when any command fails
set -e

p() {
  printf "\e[33m$1\e[0m\n"
}

function _build() {

  # 1. Define variables for use in the script
  team_name=peoplefinder
  ecr_repo_name=peoplefinder-ecr
  component=peoplefinder

  region='eu-west-2'
  context='live-1'
  aws_profile='ecr-live-1-peoplefinder'

  git_remote_url="https://github.com/ministryofjustice/peoplefinder.git";
  docker_endpoint=754256621582.dkr.ecr.eu-west-2.amazonaws.com
  docker_registry=${docker_endpoint}/${team_name}/${ecr_repo_name}

  current_branch=$(git branch | grep \* | cut -d ' ' -f2)
  current_version=$(git rev-parse $current_branch)
  short_version=$(git rev-parse --short $current_branch)

  docker_build_tag=pf-${current_branch}-${short_version}
  docker_registry_tag=${docker_registry}:${docker_build_tag}

  # 2. Display status message - include warning if the working copy is not clean
  p "------------------------------------------------------------------------"
  p "Building Peoplefinder image for deployment"
  p "Git repository: $git_remote_url"
  p "Build tag: $docker_build_tag"
  p "Branch: $current_branch"
  p "Registry tag: $docker_registry_tag"

  if [ -z "$(git status --porcelain)" ]; then
    p "Deploying from a clean working directory..."
  else
    p "\e[31mWarning! Working directory contains new or modified files...\e[0m\n"
    git status --porcelain
  fi
  p "------------------------------------------------------------------------"

  # 3. Get a logged in context so we can push images to the ECR
  p "Docker login to registry (ECR)..."
  docker login -u AWS -p $(aws ecr get-login-password --profile "$aws_profile" --region "$region") $docker_endpoint

  # 4. Compose the URL for the remote git object we'll use as the Docker build context
  p "Using git repository as Docker context"
  git_fetch_url=$git_remote_url#$current_version

  # 5. Ensure the current checked out commit is the head of the current branch
  if  [ $(git rev-parse HEAD) == $(git rev-parse @{u}) ]; then
    p "Building app container image from git using $short_version"
  else
    p "\e[31mFatal error: Local git branch is out of sync with origin\e[0m"
    p "\e[31mExiting... run git push to sync changes\e[0m\n"
    return 0;
  fi

  # 6. Build the image using the application's docker file and the git build context above
  docker build \
          --build-arg VERSION_NUMBER=$docker_registry_tag \
          --build-arg BUILD_DATE=$(date +%Y-%m-%dT%H:%M:%S%z) \
          --build-arg COMMIT_ID=$current_version \
          --build-arg BUILD_TAG=$docker_build_tag \
          --pull \
          --tag ${docker_registry_tag} \
          --file ./Dockerfile \
          $git_fetch_url

  # 7. Tag and push the image to the ECR
  case $current_branch in
    master)
      latest_tag=${docker_registry}:${component}-latest
      ;;
    *)
      latest_tag=${docker_registry}:${component}-${current_branch}-latest
      ;;
  esac
  docker tag $docker_registry_tag $latest_tag

  p "Beginning push to ECR..."
  docker push $latest_tag
  docker push ${docker_registry_tag}
  p "...push to ECR complete"

  # 8. Display the tag to use for deployment
  p "Pushed to ${latest_tag}"
  p "Image created with unique tag: \e[32m$docker_build_tag\e[0m\n"

}

_build $@
