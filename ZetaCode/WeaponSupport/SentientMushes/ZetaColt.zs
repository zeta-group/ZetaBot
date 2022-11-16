class ZetaColt : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 2857142;
		ZetaWeapon.MinAmmo 1;
		ZetaWeapon.AmmoType "ColtAmmo";
		ZetaWeapon.WeaponName "Hard Colt";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClassName() == "HardColt";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return sqrt(shooter.Distance3D(target)) / 2.5;
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		ZetaBullet.FireABullet(shooter, "Gold", target, frandom(8, 15), 2, 2, "SMPuff");
		shooter.A_PlaySound("weapons/hc/shoot", CHAN_WEAPON);
	}
}
