#include "ZetaCode/WeaponSupport/Heretic/ZetaBlaster.zsc"
#include "ZetaCode/WeaponSupport/Heretic/ZetaHereticCrossbow.zsc"
#include "ZetaCode/WeaponSupport/Heretic/ZetaGoldWand.zsc"
#include "ZetaCode/WeaponSupport/Heretic/ZetaSkullRod.zsc"
#include "ZetaCode/WeaponSupport/Heretic/ZetaMace.zsc"
#include "ZetaCode/WeaponSupport/Heretic/ZetaStaff.zsc"
#include "ZetaCode/WeaponSupport/Heretic/ZetaPhoenixRod.zsc"
#include "ZetaCode/WeaponSupport/Heretic/ZetaGauntlets.zsc"

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
