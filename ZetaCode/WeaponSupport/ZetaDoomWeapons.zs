#include "ZetaCode/WeaponSupport/Doom/ZetaFist.zsc"
#include "ZetaCode/WeaponSupport/Doom/ZetaChainsaw.zsc"
#include "ZetaCode/WeaponSupport/Doom/ZetaPistol.zsc"
#include "ZetaCode/WeaponSupport/Doom/ZetaShotgun.zsc"
#include "ZetaCode/WeaponSupport/Doom/ZetaSSG.zsc"
#include "ZetaCode/WeaponSupport/Doom/ZetaChaingun.zsc"
#include "ZetaCode/WeaponSupport/Doom/ZetaRL.zsc"
#include "ZetaCode/WeaponSupport/Doom/ZetaPR.zsc"
#include "ZetaCode/WeaponSupport/Doom/ZetaBFG.zsc"

class ZetaDoomWeapons : ZetaWeaponModule
{
	override void LoadWeapons(ZetaWeaponModule loader)
	{
		loader.AddWeapon("ZetaFist");
		loader.AddWeapon("ZetaChainsaw");
		loader.AddWeapon("ZetaPistol");
		loader.AddWeapon("ZetaShotgun");
		loader.AddWeapon("ZetaSSG");
		loader.AddWeapon("ZetaChaingun");
		loader.AddWeapon("ZetaRL");
		loader.AddWeapon("ZetaPR");
		loader.AddWeapon("ZetaBFG");
	}
}
