class ZetaMinigun : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 1714285;
		ZetaWeapon.AltFireInterval 6285714;
		ZetaWeapon.MinAmmo 1;
		ZetaWeapon.AmmoType "ColtAmmo";
		ZetaWeapon.AltMinAmmo 2;
		ZetaWeapon.AltAmmoType "ColtAmmo";
		ZetaWeapon.WeaponName "Minigun";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClassName() == "Minigun";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return true;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return shooter.Distance2D(target) / 1.5 + 90;
	}
	
	override double AltRateSelf(Actor shooter, Actor target)
	{
		return shooter.Distance2D(target);
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		ZetaBullet.FireBullets(shooter, "Gold", target, 9, 2, 2, 2, "SMPuff");
		shooter.A_PlaySound("minigun/fire", CHAN_WEAPON, 0.5);
	}
	
	override void AltFire(Actor shooter, Actor target)
	{
		ZetaBullet.FireBullets(shooter, "Gold", target, 12, 4, 2, 2, "SMPuff");
		shooter.A_PlaySound("minigun/fire", CHAN_WEAPON);
	}
	
}
