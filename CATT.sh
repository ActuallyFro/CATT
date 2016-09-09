#!/bin/bash

#Commit All The Things (CATT)

folders=`find -maxdepth 1 -type d | tr "/" "\n" | grep -v "\." | sort`

for CurDir in ${folders[*]}; do

   echo "Looking at: $CurDir"
   echo "======================================="
   cd $CurDir

   Status=`git status 2>&1`

   CancelledCommit="false"
   if [[ "`echo $Status| grep "nothing to commit"`" == "" ]] || [[ "`echo $Status | grep "Changes to be committed"`" != "" ]] && [[ "`echo $Status | grep "Not a git repository"`" == "" ]];then

      echo "Needs to commit changes!"
      echo ""
      git status

      read -r -p "Would you like to auto commit? [y/N] " Answer

      case $Answer in
         [yY][eE][sS]|[yY])
            read -r -p "Please enter a commit message: " Message
            git add *
            git commit -m"$Message"
         ;;
         *)
            echo "Please add files and commit by hand..."
            CancelledCommit="true"
         ;;
      esac
   else
      if [[ "`echo $Status | grep "Not a git repository"`" == "" ]];then
         echo "$CurDir is Good for commits!"
      else
         echo "$CurDir is NOT a git repo!"
      fi
   fi

   if [[ "$CancelledCommit" == "false" ]] && [[ "`echo $Status | grep "Not a git repository"`" == "" ]];then
      remotes=`cat .git/config | grep remote | grep "\[" | tr " " "\n" | grep "\]" | tr -d "\"\|\]"`

      for remote in ${remotes[*]}; do
         echo ""
         echo "Trying to Pull and Push $CurDir to: $remote"
         git pull $remote master
         git push $remote master
      done
   fi

   cd ..
   echo ""
   echo ""
done



