class ZetaHeavyMinigun : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 1142857;
		ZetaWeapon.MinAmmo 1;
		ZetaWeapon.AmmoType "ColtAmmo";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClassName() == "HeavyMinigun";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return shooter.Distance2D(target) / 1.5;
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		ZetaBullet.FireABullet(shooter, "Gold", target, frandom(12, 20), 5, 3);
		shooter.A_PlaySound("ak64/shoot", CHAN_WEAPON);
        shooter.A_Recoil(0.6);
	}
}
