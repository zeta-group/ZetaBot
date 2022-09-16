class ZetaSMShotgun : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 12000000;
		ZetaWeapon.MinAmmo 1;
        ZetaWeapon.AmmoType "ShotRifleShellClip";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClassName() == "ShotRifle";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return 650 / sqrt(shooter.Distance3D(target) / 2);
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		ZetaBullet.FireBullets(shooter, "Gold", target, random(2, 4), 20, 12, 10, "SMPuff");
		shooter.A_PlaySound("weapons/sr/shoot", CHAN_WEAPON);
        shooter.A_PlaySound("weapons/sr/reload", CHAN_WEAPON);
	}
}