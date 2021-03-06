#!/bin/bash
ToolName="CATT"
Version="1.0.2"
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

if [[ "$1" == "--check-script" ]] || [[ "$1" == "--crc" ]];then
   CRCRan=`$0 --version | grep "md5" | tr ":" "\n" | grep -v "md5" | tr -d " "`
   CRCScript=`cat $0 | grep "less lines" | grep -v "md5sum" | grep -v "cat" | tr ":" "\n" | grep -v "md5" | tr -d " "`

   if [[ "$CRCRan" == "$CRCScript" ]]; then
      echo "$0 is good!"
   else
      echo "The checksums didn't match!"
      echo "1. $CRCRan  (vs.)"
      echo "2. $CRCScript"

   fi
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

      lastVersHack=`echo "$lastVers" | tr "." " " | awk '{printf("9%04d%04d%04d",$1,$2,$3)}'`
      newVersHack=`echo "$newVers" | tr "." " " | awk '{printf("9%04d%04d%04d",$1,$2,$3)}'`

      echo ""
      if [[ "$lastVersHack" -lt "$newVersHack" ]]; then
         echo "Updating $ToolName to $newVers"
         chmod +x /tmp/junk$ToolName

         echo "Checking the CRC..."
         CheckCRC=`/tmp/junk$ToolName --check-script | grep "good" | wc -l`

         if [[ "$CheckCRC" == "1" ]]; then
            echo "Installing ..."
            /tmp/junk$ToolName --install
         else
            echo "ERROR! The CRC failed, considering file to be bad!"
            rm /tmp/junk$ToolName
            exit
         fi
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

folders=`find . -maxdepth 1 -type d | tr "/" "\n" | grep -v "\." | sort`

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
      remotes=`cat .git/config | sed 's/remotes/remotes=/g' | grep "remote" | tr -d "\t" | tr -d " \|\[\|\]\|\\\|\*" | tr "=" "\n" | tr "\"" "\n" | grep -v "remote\|fetch" | tr "/" "\n" | grep -v '^$' | sort | uniq`

      if [[ "$remotes" == "" ]]; then
         echo ""
         echo "NO REMOTES FOUND!"
      else
         branches=`git branch | tr -d "*\| "`
         echo ""
         git fetch --all
         for remote in ${remotes[*]}; do
            echo "Trying to Merge all branches..."
            for branch in ${branches[*]}; do
               echo "   Merging: $remote/$branch"
               git merge "$remote/$branch"
            done
            echo ""
            echo "Trying to Push all branches from $CurDir to: $remote"
            git push $remote --all
            echo "Trying to Push all branches' tags"
            git push $remote --tags
         done
      fi
   fi

   cd ..
   echo ""
   echo ""
done

###md5 (less lines with ###): 19b5ac2537b469e43116d2ed25cb8cd6
