#include "ZetaCode/WeaponSupport/Strife/ZetaAssaultGun.zsc"
#include "ZetaCode/WeaponSupport/Strife/ZetaCrossbow1.zsc"
#include "ZetaCode/WeaponSupport/Strife/ZetaCrossbow2.zsc"
#include "ZetaCode/WeaponSupport/Strife/ZetaDagger.zsc"
#include "ZetaCode/WeaponSupport/Strife/ZetaFlameThrower.zsc"
#include "ZetaCode/WeaponSupport/Strife/ZetaGrenade1.zsc"
#include "ZetaCode/WeaponSupport/Strife/ZetaGrenade2.zsc"
#include "ZetaCode/WeaponSupport/Strife/ZetaMauler1.zsc"
#include "ZetaCode/WeaponSupport/Strife/ZetaMauler2.zsc"
#include "ZetaCode/WeaponSupport/Strife/ZetaMiniMissile.zsc"

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
