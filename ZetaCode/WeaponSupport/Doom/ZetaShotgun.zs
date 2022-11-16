class ZetaShotgun : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 10571428;
		ZetaWeapon.MinAmmo 1;
		ZetaWeapon.AmmoType "Shell";
		ZetaWeapon.WeaponName "Shotgun";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClass() == "Shotgun";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return 900 / (1 + sqrt(shooter.Distance2D(target) / 2));
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		ZetaBullet.FireBullets(shooter, "Gold", target, 10, 7, 5.6, 0, damage_spread: 5);
		shooter.A_PlaySound("weapons/shotgf", CHAN_WEAPON);
	}
}
