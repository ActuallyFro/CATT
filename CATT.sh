#!/bin/bash
ToolName="CATT"
Version="0.2.2"
url="https://raw.githubusercontent.com/ActuallyFro/CATT/master/CATT.sh"

read -d '' HelpMessage << EOF
Commit ALL THE THINGS (CATT) v$Version
===================================
This 'tool' jumps into ALL subdirectories, run git status, add all changes to a
commit if desired, and then pushes the commit to all remotes.

Other Options
-------------
--license - print license
--version - print version number
--install - copy this script to /bin/$ToolName
--update  - update to the most recent GitHub commit
EOF

read -d '' License << EOF
Copyright (c) 2016 Brandon Froberg

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
EOF

#Check For Passed Args
#=====================
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]];then
   echo ""
   echo "$HelpMessage"
   exit
fi

if [[ "$1" == "--version" ]];then
   echo ""
   echo "Version: $Version"
   echo "md5 (less lines with ###): "`cat $0 | grep -v "###" | md5sum | awk '{print $1}'`
   exit
fi

if [[ "$1" == "--license" ]];then
   echo ""
   echo "$License"
   exit
fi

if [[ "$1" == "--update" ]];then

   echo ""

   if [[ "`which wget`" != "" ]]; then
      echo "Grabbing latest GitHub commit..."
      wget $url -O /tmp/junk$ToolName

   elif [[ "`which curl`" != "" ]]; then
      echo "Grabbing latest GitHub commit...with curl...ew"
      curl $url > /tmp/junk$ToolName
   else
      echo "... or I cant; Install wget or curl"
   fi

   if [[ -f /tmp/junk$ToolName ]]; then
      lastVers="$Version"
      newVers=`cat /tmp/junk$ToolName | grep "Version=" | grep -v "cat" | tr "\"" "\n" | grep "\."`

      lastVersHack=`echo "9$lastVers" | tr -d "."`  #LEADING ZERO HACK!
      newVersHack=`echo "9$newVers" | tr -d "."`  #LEADING ZERO HACK!

      echo ""
      if [[ "$lastVersHack" -lt "$newVersHack" ]]; then
         echo "Updating $ToolName to $newVers"
         chmod +x /tmp/junk$ToolName
         /tmp/junk$ToolName --install
         rm /tmp/junk$ToolName
      else
         echo "You are up to date! ($lastVers)"
      fi
   else
      echo "Well ... that happened. (Check your Inet; the new $ToolName couldn't be grabbed!"
   fi

   exit
fi

if [[ "$1" == "--install" ]];then
   echo ""
   echo "Attempting to install $0 to /bin"

   User=`whoami`
   if [[ "$User" != "root" ]]; then
      echo "[WARNING] Currently NOT root!"
   fi
   cp $0 /bin/$ToolName
   Check=`ls /bin/$ToolName | wc -l`
   if [[ "$Check" == "1" ]]; then
      echo "$ToolName installed successfully!"
   fi

   exit
fi

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

      if [[ "$remotes" == "" ]]; then
         echo ""
         echo "NO REMOTES FOUND!"
      else
         for remote in ${remotes[*]}; do
            echo ""
            echo "Trying to Pull and Push $CurDir to: $remote"
            git pull $remote master
            git push $remote master
         done
      fi
   fi

   cd ..
   echo ""
   echo ""
done

###md5 (less lines with ###): cde91189aadc0667e2e583d5e2ac5ef0
