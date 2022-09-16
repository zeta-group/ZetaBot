#include "ZetaCode/WeaponSupport/Doom/ZetaFist.zs"
#include "ZetaCode/WeaponSupport/Doom/ZetaChainsaw.zs"
#include "ZetaCode/WeaponSupport/Doom/ZetaPistol.zs"
#include "ZetaCode/WeaponSupport/Doom/ZetaShotgun.zs"
#include "ZetaCode/WeaponSupport/Doom/ZetaSSG.zs"
#include "ZetaCode/WeaponSupport/Doom/ZetaChaingun.zs"
#include "ZetaCode/WeaponSupport/Doom/ZetaRL.zs"
#include "ZetaCode/WeaponSupport/Doom/ZetaPR.zs"
#include "ZetaCode/WeaponSupport/Doom/ZetaBFG.zs"

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
