Commit All The Things (CATT)
============================
CATT will jump into all subdirectories, run `git status`, add all changes to a commit if desired, and then pushes the commit to all remotes.

TL;DR
------
I'm lazy; I figure push out all the data and deal with it later

Version Notes
-------------
- 0.1.0  - First Commit(s)
- 0.2.0  - Now will Args! (more importantly ... an installer)
- 0.2.1  - Now will an updater!
- 0.2.2  - Now will an updater that works!
- 0.2.3  - Decided to push/pull all; not just master
- 0.2.4  - Decided to push/fetch* all; not just master
- 0.2.5  - Branches!
- 0.2.6  - Formatting and book-keeping
- 0.2.7  - ?????
- 0.2.8  - PROFIT!
- 0.2.9  - Terrible Checking of file contents (but it works!)
- 0.2.10 - Verifying CRC with --install; fixing issues with mis-matched names/remotes
- 0.2.11 - Exits are for suckers!
- 0.2.12 - Fixed the update/crc check; move to consider a 1.0.0 release
- 1.0.0  - So the main features are all in... But there's always something :P

Issues
------
- **DO NOT MANUALLY MODIFY YOUR .GIT/CONFIG FILE!** CATT will 'best guess' as to how you mangled your remotes, but it's best left to git to bit 
twiddle.

![You know you want to ...](CATT.jpg)
