# ZetaBot
**The modern ZScript bot made for GZDoom**, made *by ZDoomers for ZDoomers*.

* Exactly **3748 lines** of code written **manually** (verified with `wc`)
* **Five** possible bot states (Wandering, Following, Attacking, Hunting and Fleeing)
* **Extensive debugging** (set by CVar `zb_debug`)
* Has the **attention of official ZDoom developers**
* Flexible **PK3 mod build script** solution (`build.sh`)
* Multiple male and female **voices**
* Pathnode system with **A\* pathfinding**
* Supports **any weapons and player classes** _(given there are modules for them, supplied by their respective modders))
* Constraints akin to **real** players _(max speed, max firing rate, etc etc)_
* Weapon **rating** system

---

# How to Play

### Universal

The easiest way is to go to the Releases section of the repository and
downloading the PK3 attached to the latest release. Otherwise, you need
to run the build script in order to zip up the PK3 and get the launch script.

### Linux

1. Run your terminal window and `cd` to the folder with the ZetaBot source.
2. Run the buildscript:

        ./build.sh [-f <output folder : out>] [-s <path to source port : /usr/bin/gzdoom>] -i <path to the mod's IWAD>
    
   It also supports optional CVar settings:

        [-c <name=value> [-c <name2=value2> ...]]
        
   And additional source port settings as well:
   
        [-e <option>[=<value>] [-e <option>[=<value>] ...]]
    
   For example:

        ./build.sh -f out -s gzdoom -i /usr/games/doom/doom2.wad -c zb_debug=1 -e "-nomonsters" -e "-skill=1" -e "+map=MAP18"
    
3. Launch:

        cd <output folder : build>
        ./ZetaBot
    
For other mods that use the same buildscript, try `ls` to find a file,
of the same name as the mod's PK3, but without the version and extension
in the filename.

You only need to do the steps 1 and 2 once (unless you want to change the
CVARs set). You can also use the output PK3 as a normal mod, instead of
using the launchscript :)

    
### Windows
    
For Windows you can just zip up all the files directly in the top folder of the repo,
along with the following folders:

* ZetaCode
* sprites
* sounds
* acs
* source
