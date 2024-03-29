class ZetaPistol : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 4000000;
		ZetaWeapon.MinAmmo 1;
		ZetaWeapon.AmmoType "Clip";
		ZetaWeapon.WeaponName "Pistol";

		Obituary "%o atoned before %k's mighty pea shooter.";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClass() == "Pistol";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return 200 / (1 + sqrt(shooter.Distance3D(target)));
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		ZetaBullet.FireABullet(shooter, "Gold", target, random(1, 3) * 8, 5.6, 0);
		shooter.A_PlaySound("weapons/pistol", CHAN_WEAPON);
	}
}
