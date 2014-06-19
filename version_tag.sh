#!/bin/bash
SORTCMD=${SORT:-gsort}

PREFIX="release/"
TAGS=$(git ls-remote -t 2>/dev/null | grep -o 'release/[0-9]\+\.[0-9]\+\.[0-9]\+$' | cut -d'/' -f 2 | $SORTCMD -V)
LAST_TAG=$(echo "$TAGS" | tail -1)



set_tag() {
  MAJOR=$(echo $LAST_TAG | cut -d. -f 1)
  MINOR=$(echo $LAST_TAG | cut -d. -f 2)
  BUILD=$(echo $LAST_TAG | cut -d. -f 3)
  case $1 in
  (major)
     NEWTAG="$[$MAJOR+1].0.0"
     echo "incrementing major on $LAST_TAG to make $NEWTAG"
     ;;
  (minor)
     NEWTAG="$MAJOR.$[$MINOR+1].0"
     echo "incrementing minor on $LAST_TAG to make $NEWTAG"
     ;;
  (build)
     NEWTAG="$MAJOR.$MINOR.$[$BUILD+1]"
     echo "incrementing build on $LAST_TAG to make $NEWTAG"
     ;;
  (*)
     tmp=$(echo $1| grep -o '^[0-9]\+\.[0-9]\+\.[0-9]\+$')
     if [ "$?" != 0 ]; then
        echo "TAG must match d.d.d SEMVAR format"
        exit 2
     fi
     NEWTAG=$1
     echo "creating new tag $NEWTAG"
  esac
  
  for OLDTAG in ${TAGS}
  do
    if [ $OLDTAG == $NEWTAG ]; then
      echo "TAG $NEWTAG already exists"
      exit 2
    fi
  done
  git tag -a -m"Create TAG" ${PREFIX}${NEWTAG} && git push --tags
}


remove_tag() {
  TAG=$1
  if [ "$TAG" == "" ]; then
      echo "TAG not specified"
      exit 2
  fi
  echo "Removing local tag ${PREFIX}${TAG}"
  git tag -d ${PREFIX}${TAG}
  if [[ $TAGS =~ $TAG ]]; then
      echo "Removing remote TAG $TAG"
  else 
      echo "TAG $TAG does not exist"
      exit 2
  fi
  git push origin :refs/tags/${PREFIX}${TAG}
}

show_tag() {
  TAG=$2
  [ "$TAG" == "" ] && TAG=$LAST_TAG
  git show ${PREFIX}${TAG}
}


verbose_list() {
  OUTPUT=$(git for-each-ref refs/tags/release --format "%(objectname):%(refname):%(taggername):%(taggerdate:relative)")
  SaveIFS=$IFS
  IFS=":"
  echo "$OUTPUT" | while read commit ref author date 
  do 
    version=$(echo $ref | grep -o 'release/[0-9]\+\.[0-9]\+\.[0-9]\+$' | cut -d'/' -f 2)
    printf "%s %12s   %-30s  %s\n" "$commit" "$version" "$author" "$date"
  done
}


if [ "$#" -eq 0 ]; then
  echo "$TAGS" | tail -1
elif [ "$1" == "last" ]; then
  echo "$TAGS" | tail -1
elif [ "$1" == "ll" ]; then
 verbose_list 
elif [ "$1" == "list" ]; then
  echo "$TAGS"
elif [ "$1" == "set" ]; then
  set_tag $2
elif [ "$1" == "show" ]; then
  show_tag $2
elif [ "$1" == "remove" ]; then
  remove_tag $2
else 
  cat <<EOT
Usage: $0 [command]

Commands: 
   last               - list the highest semver tag (default if no command specified)
   list               - list all semver tags
   ll                 - long list: contains committer/datestamp (required updated local repo)
   set major          - create a tag with new major version
   set minor          - create a tag with new minor version
   set build          - create a tag with new build version
   set <version>      - create a tag with a specific semver version
   show <version>     - perform a git show on the specific version
   remove <version>   - remove a semver tag

EOT
fi
