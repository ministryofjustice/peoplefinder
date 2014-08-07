#!/bin/bash
SORTCMD=${SORT:-sort}

PREFIX="release/"
TAGS=$(git ls-remote -t 2>/dev/null | grep -o 'release/[0-9]\+\-[0-9]\+\-[0-9]\+T[0-9]\+\.[0-9]\+\.[0-9]\+Z$' | cut -d'/' -f 2 | $SORTCMD -nr)
LAST_TAG=$(echo "$TAGS" | tail -1)



set_tag() {
  TDATE=$(date -u +'%Y-%m-%dT%TZ')
  NEWTAG="${TDATE//:/.}"
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
  echo $TAGS
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
    version=$(echo $ref | grep -o 'release/[0-9]\+\-[0-9]\+\-[0-9]\+T[0-9]\+\.[0-9]\+\.[0-9]\+Z$' | cut -d'/' -f 2)
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
elif [ "$1" == "create" ]; then
  set_tag $2
elif [ "$1" == "show" ]; then
  show_tag $2
elif [ "$1" == "remove" ]; then
  remove_tag $2
else
  cat <<EOT
Usage: $0 [command]

Commands:
   last               - list the highest tag (default if no command specified)
   list               - list all tags
   ll                 - long list: contains committer/datestamp (required updated local repo)
   create             - creates a release with the current iso timestamp
   show <version>     - perform a git show on the specific version
   remove <version>   - remove a tag

EOT
fi