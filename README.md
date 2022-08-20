# ZetaBot

<div style="margin: 0 auto;">

![icon](ZetaBot-icon.svg)

</div>

**The modern ZScript bot made for GZDoom**, made *by ZDoomers for ZDoomers*.

* An **easy** way to replace the ZCajun with a bot that musters **actual intelligence**, competent in **both coop and deathmatch**
* **Five** possible bot states (Wandering, Following, Attacking, Hunting and Fleeing)
* **Multiple voice sets** to spice regular gameplay with the original hilarious DecoBot taunts and blurts
* **Advanced** pathing system, with a repertoire of over **thirteen path node types**
  * Ability to **edit paths while playing**, alongside conveniences like **showing all paths** (`zt_showpaths`), **saving and loading** the entire path network, and even **map-specific node lumps** to include in your mapset!
* Supports **any weapons and player classes** _(given there are modules for them, supplied by their respective modders)_
* Includes full support for Doom, Heretic, and Strife
  * Can pick up and use **any vanilla weapon and player class**
  * **High extensibility at the ZScript level** to add support for _modded weapons and player classes_
* **Extensive debugging** (set by CVar `zb_debug`)

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
