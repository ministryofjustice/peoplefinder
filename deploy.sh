#!/bin/sh

# exit when any command fails
set -e

p() {
  printf "\e[33m$1\e[0m\n"
}

function _deploy() {

  # Define variables for use in the script
  team_name=peoplefinder
  ecr_repo_name=peoplefinder-ecr
  component=peoplefinder
  docker_endpoint=754256621582.dkr.ecr.eu-west-2.amazonaws.com
  docker_registry=${docker_endpoint}/${team_name}/${ecr_repo_name}

  usage="deploy -- deploy image from ECR to an environment
  Usage: ./deploy.sh image-tag environment
  Where:
    environment - one of development|staging|qa|production
    image-tag   - any valid ECR image tag for app generated by build script
  Prerequisites:
    Build an image to deploy using build.sh in a checked out
    copy of the head of the branch you want to deploy. Supply the
    resulting image tag to this deploy script.
  Example:
    # build the app to get an image tag
    ./build.sh
    ...many lines of output...
    Image created with tag: pf-CT-1234-6bece953

    # deploy image-tag to development
    ./deploy.sh pf-CT-1234-6bece953 development

    # deploy latest image of main to production
    ./deploy.sh pf-CT-1234-6bece953 production
    "

  # Ensure the script is called with two or three arguments
  if [ $# -lt 2 ] || [ $# -gt 3 ]
  then
    echo "$usage"
    return 0
  fi

  # Ensure that the first argument is a reasonable image name if not circleci (regexp diff in linux)
  if [[ "$3" == "circleci" ]]
  then
    image_tag=$1
  else
    if [[ "$1" =~ ^pf- ]]
    then
      image_tag=$1
    else
      p "\e[31mFatal error: Image tag not recognised: $1\e[0m"
      p "\e[31mPlease supply an image tag generated by the build script as the first argument\e[0m\n"
      echo "$usage"
      return 0
    fi
  fi

  # Ensure that the second argument is a valid stage
  case "$2" in
    development | staging | production)
      environment=$2
      ;;
    *)
      p "\e[31mFatal error: deployment environment not recognised: $2\e[0m"
      p "\e[31mEnvironment must be one of development | staging | qa | production\e[0m\n"
      echo "$usage"
      return 0
      ;;
  esac

  # Confirm what's going to happen and ask for confirmation if not circle ci
  docker_image_tag=${docker_registry}:${image_tag}

  namespace=$component-${environment}
  p "--------------------------------------------------"
  p "Deploying People Finder to kubernetes cluster: Live"
  p "Environment: \e[32m$environment\e[0m"
  p "Docker image: \e[32m$image_tag\e[0m"
  p "Target namespace: \e[32m$namespace\e[0m"
  p "--------------------------------------------------"

  if [[ "$3" != "circleci" ]]
  then
    if [[ $environment == "production" ]]
    then
      read -p "Do you wish to deploy this image to production? (Enter 'deploy' to continue): " confirmation_message
      if [[ $confirmation_message == "deploy" ]]
      then
        p "Deploying app to production..."
      else
        return 0
      fi
    else
      read -p "Do you wish to deploy this image to $environment? (Enter Y to continue): " confirmation_message
      if [[ $confirmation_message =~ ^[Yy]$ ]]
      then
        p "Deploying app to $environment..."
      else
        return 0
      fi
    fi
  fi

  if [[ "$3" == "circleci" ]]
  then
    #authenticate to live cluster
    p "Authenticating to live..."
    echo -n $KUBE_ENV_LIVE_CA_CERT | base64 -d > ./live_ca.crt
    kubectl config set-cluster $KUBE_ENV_LIVE_CLUSTER_NAME --certificate-authority=./live_ca.crt --server=https://$KUBE_ENV_LIVE_CLUSTER_NAME

    if [[ $environment == "development" ]]
    then
      live_token=$KUBE_ENV_LIVE_DEVELOPMENT_TOKEN
    fi

    if [[ $environment == "staging" ]]
    then
      live_token=$KUBE_ENV_LIVE_STAGING_TOKEN
    fi

    if [[ $environment == "production" ]]
    then
      live_token=$KUBE_ENV_LIVE_PRODUCTION_TOKEN
    fi

    kubectl config set-credentials circleci --token=$live_token
    kubectl config set-context $KUBE_ENV_LIVE_CLUSTER_NAME --cluster=$KUBE_ENV_LIVE_CLUSTER_NAME --user=circleci --namespace=$namespace
    kubectl config use-context $KUBE_ENV_LIVE_CLUSTER_NAME
    kubectl config current-context
    kubectl --namespace=$namespace get pods
  fi

  #deploy to live cluster
  p "Authenticated, deploying to live..."


  # Apply config map updates
  kubectl apply \
    -f config/kubernetes/${environment}/env-configmap.yaml -n $namespace

  # Apply image specific config
  kubectl set image -f config/kubernetes/${environment}/deployment.yaml \
          webapp=${docker_image_tag} \
          jobs=${docker_image_tag} --local --output yaml | kubectl apply -n $namespace -f -

  # Apply non-image specific config
  kubectl apply \
    -f config/kubernetes/${environment}/service.yaml \
    -f config/kubernetes/${environment}/ingress-live.yaml \
    -n $namespace

  #Add cron jobs if production
  if [[ $environment == "production" ]]
  then
    kubectl set image -f config/kubernetes/${environment}/cron-person-notifier.yaml \
            jobs=${docker_image_tag} --local --output yaml | kubectl apply -n $namespace -f -

    kubectl set image -f config/kubernetes/${environment}/cron-team-description-notifier.yaml \
            jobs=${docker_image_tag} --local --output yaml | kubectl apply -n $namespace -f -

    kubectl set image -f config/kubernetes/${environment}/cron-never-logged-in-notifier.yaml \
            jobs=${docker_image_tag} --local --output yaml | kubectl apply -n $namespace -f -

    kubectl set image -f config/kubernetes/${environment}/cron-person-update-reminder.yaml \
            jobs=${docker_image_tag} --local --output yaml | kubectl apply -n $namespace -f -

    kubectl set image -f config/kubernetes/${environment}/cron-user-behaviour-report.yaml \
            jobs=${docker_image_tag} --local --output yaml | kubectl apply -n $namespace -f -

    kubectl set image -f config/kubernetes/${environment}/cron-profile-completions-report.yaml \
            jobs=${docker_image_tag} --local --output yaml | kubectl apply -n $namespace -f -

    kubectl set image -f config/kubernetes/${environment}/cron-profile-changed-report.yaml \
            jobs=${docker_image_tag} --local --output yaml | kubectl apply -n $namespace -f -

    kubectl set image -f config/kubernetes/${environment}/cron-total-profiles-report.yaml \
            jobs=${docker_image_tag} --local --output yaml | kubectl apply -n $namespace -f -

    kubectl set image -f config/kubernetes/${environment}/cron-profile-percentage-report.yaml \
              jobs=${docker_image_tag} --local --output yaml | kubectl apply -n $namespace -f -

    kubectl set image -f config/kubernetes/${environment}/cron-photo-profiles-report.yaml \
            jobs=${docker_image_tag} --local --output yaml | kubectl apply -n $namespace -f -
  fi

}

_deploy $@
