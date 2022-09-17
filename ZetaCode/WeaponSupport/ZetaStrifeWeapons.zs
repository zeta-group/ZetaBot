#include "ZetaCode/WeaponSupport/Strife/ZetaAssaultGun.zs"
#include "ZetaCode/WeaponSupport/Strife/ZetaCrossbow1.zs"
#include "ZetaCode/WeaponSupport/Strife/ZetaCrossbow2.zs"
#include "ZetaCode/WeaponSupport/Strife/ZetaDagger.zs"
#include "ZetaCode/WeaponSupport/Strife/ZetaFlameThrower.zs"
#include "ZetaCode/WeaponSupport/Strife/ZetaGrenade1.zs"
#include "ZetaCode/WeaponSupport/Strife/ZetaGrenade2.zs"
#include "ZetaCode/WeaponSupport/Strife/ZetaMauler1.zs"
#include "ZetaCode/WeaponSupport/Strife/ZetaMauler2.zs"
#include "ZetaCode/WeaponSupport/Strife/ZetaMiniMissile.zs"

class ZetaStrifeWeapons : ZetaWeaponModule
{
	override void LoadWeapons(ZetaWeaponModule loader)
	{
		loader.AddWeapon("ZetaAssaultGun");
		loader.AddWeapon("ZetaCrossbow1");
		loader.AddWeapon("ZetaCrossbow2");
		loader.AddWeapon("ZetaDagger");
		loader.AddWeapon("ZetaFlameThrower");
		loader.AddWeapon("ZetaGrenade1");
		loader.AddWeapon("ZetaGrenade2");
		loader.AddWeapon("ZetaMauler1");
		loader.AddWeapon("ZetaMauler2");
		loader.AddWeapon("ZetaMiniMissile");
	}
}
