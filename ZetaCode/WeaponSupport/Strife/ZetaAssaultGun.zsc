class ZetaAssaultGun : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 857142;
		ZetaWeapon.MinAmmo 1;
		ZetaWeapon.AmmoType "ClipOfBullets";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClass() == "AssaultGun";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return 600 - shooter.Distance2D(target) / 1.5;
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		ZetaBullet.FireABullet(shooter, "Gold", target, random[StrifeGun]() % 3 + 1, abs(Random2[StrifeGun]() * (22.5 / 256) * AccuracyFactor()), 0, "StrifePuff");
		
		shooter.A_PlaySound("weapons/assaultgun", CHAN_WEAPON);
	}
}
