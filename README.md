# [L4D2] Director "ProhibitBosses" for Versus
This is a SourceMod Plugin that allows level designers to use the "ProhibitBosses" director key for VScripts as well as "director_no_bosses" CVar in Versus mode. This can be useful if you want to prevent Boss Infected from spawning during a certain event; for example, when the elevator is going up on C8M4 and you want to avoid having the Tank climb all the way up in which the player would likely use control.

# Hammer Editor Example
![Screenshot_1](https://github.com/justin-chellah/director-prohibit-bosses-versus/assets/26851418/1175c97c-762c-4b5d-9886-9e9d3d8c3dae)
![Screenshot_2](https://github.com/justin-chellah/director-prohibit-bosses-versus/assets/26851418/6bc7cda1-cb23-448b-bbcd-59ac6aca66e3)

# [Stripper: Source](https://www.bailopan.net/stripper/) Example
Create a file named `c8m4_interior.cfg` and insert the following code:
```
; elevator button at the bottom
modify:
{
	match:
	{
		"origin" "13491 15102 477.5"
	}
	
	insert:
	{
		"OnPressed" "directorRunScriptCodeDirectorScript.DirectorOptions.ProhibitBosses <- true0-1"
	}
}
{
	match:
	{
		"targetname" "elevator"
	}
	
	insert:
	{
		"OnReachedTop" "directorRunScriptCodeDirectorScript.DirectorOptions.ProhibitBosses <- false0-1"
	}
}
```

# Requirements
- [SourceMod 1.11+](https://www.sourcemod.net/downloads.php?branch=stable)

# Docs
- [L4D2 Director Scripts](https://developer.valvesoftware.com/wiki/L4D2_Director_Scripts)
- [L4D2 Vscripts](https://developer.valvesoftware.com/wiki/L4D2_Vscripts)

# Supported Platforms
- Windows
- Linux
