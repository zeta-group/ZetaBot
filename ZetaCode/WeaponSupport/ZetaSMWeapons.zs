#include "ZetaCode/WeaponSupport/SentientMushes/ZetaClaw.zs"
#include "ZetaCode/WeaponSupport/SentientMushes/ZetaColt.zs"
#include "ZetaCode/WeaponSupport/SentientMushes/ZetaSMShotgun.zs"
#include "ZetaCode/WeaponSupport/SentientMushes/ZetaAK64.zs"
#include "ZetaCode/WeaponSupport/SentientMushes/ZetaMinigun.zs"
#include "ZetaCode/WeaponSupport/SentientMushes/ZetaRockox.zs"
#include "ZetaCode/WeaponSupport/SentientMushes/ZetaRocketeer.zs"
#include "ZetaCode/WeaponSupport/SentientMushes/ZetaKnife.zs"
#include "ZetaCode/WeaponSupport/SentientMushes/ZetaHeavyMinigun.zs"

class ZetaSentientMushesWeapons : ZetaWeaponModule
{
	override void LoadWeapons(ZetaWeaponModule loader)
	{
		loader.AddWeapon("ZetaClaw");
		loader.AddWeapon("ZetaColt");
		loader.AddWeapon("ZetaSMShotgun");
		loader.AddWeapon("ZetaAK64");
		loader.AddWeapon("ZetaMinigun");
		loader.AddWeapon("ZetaRockox");
		loader.AddWeapon("ZetaRocketeer");
		loader.AddWeapon("ZetaKnife");
		loader.AddWeapon("ZetaHeavyMinigun");
	}
}
