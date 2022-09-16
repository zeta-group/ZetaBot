#include "ZetaCode/WeaponSupport/Heretic/ZetaBlaster.zs"
#include "ZetaCode/WeaponSupport/Heretic/ZetaHereticCrossbow.zs"
#include "ZetaCode/WeaponSupport/Heretic/ZetaGoldWand.zs"
#include "ZetaCode/WeaponSupport/Heretic/ZetaSkullRod.zs"
#include "ZetaCode/WeaponSupport/Heretic/ZetaMace.zs"
#include "ZetaCode/WeaponSupport/Heretic/ZetaStaff.zs"
#include "ZetaCode/WeaponSupport/Heretic/ZetaPhoenixRod.zs"
#include "ZetaCode/WeaponSupport/Heretic/ZetaGauntlets.zs"

class ZetaHereticWeapons : ZetaWeaponModule
{
	override void LoadWeapons(ZetaWeaponModule loader)
	{
		loader.AddWeapon("ZetaBlaster");
		loader.AddWeapon("ZetaHereticCrossbow");
		loader.AddWeapon("ZetaGoldWand");
		loader.AddWeapon("ZetaFiremace");
		loader.AddWeapon("ZetaSkullRod");
		loader.AddWeapon("ZetaStaff");
		loader.AddWeapon("ZetaPhoenixRod");
		loader.AddWeapon("ZetaGauntlets");
	}
}
