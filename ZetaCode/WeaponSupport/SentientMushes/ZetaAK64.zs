class ZetaAK64 : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 5000000;
		ZetaWeapon.MinAmmo 1;
		ZetaWeapon.AmmoType "ColtAmmo";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClassName() == "AK64";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return 800 - shooter.Distance2D(target);
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		ZetaBullet.FireABullet(shooter, "Gold", target, 11, 3, 2, "SMPuff");
		shooter.A_PlaySound("ak64/shoot", CHAN_WEAPON);
	}
}