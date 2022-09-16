#include "ZetaCode/WeaponSupport/SentientMushes/ZetaClaw.zsc"
#include "ZetaCode/WeaponSupport/SentientMushes/ZetaColt.zsc"
#include "ZetaCode/WeaponSupport/SentientMushes/ZetaSMShotgun.zsc"
#include "ZetaCode/WeaponSupport/SentientMushes/ZetaAK64.zsc"
#include "ZetaCode/WeaponSupport/SentientMushes/ZetaMinigun.zsc"
#include "ZetaCode/WeaponSupport/SentientMushes/ZetaRockox.zsc"
#include "ZetaCode/WeaponSupport/SentientMushes/ZetaRocketeer.zsc"
#include "ZetaCode/WeaponSupport/SentientMushes/ZetaKnife.zsc"
#include "ZetaCode/WeaponSupport/SentientMushes/ZetaHeavyMinigun.zsc"

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
