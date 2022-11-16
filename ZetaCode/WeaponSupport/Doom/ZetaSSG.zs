class ZetaSSG : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 15428571;
		ZetaWeapon.MinAmmo 2;
		ZetaWeapon.AmmoUse 2;
		ZetaWeapon.AmmoType "Shell";
		ZetaWeapon.WeaponName "Super Shotgun";

		Obituary "%k turned %o into Swiss cheese with the %w!";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClass() == "SuperShotgun";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return 2000 / (1 + sqrt(shooter.Distance2D(target) * 1.8));
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		ZetaBullet.FireBullets(shooter, "Gold", target, random(1, 3) * 8, 20, 11.2, 7.1);
		shooter.A_PlaySound("weapons/sshotf", CHAN_WEAPON);
	}
}
