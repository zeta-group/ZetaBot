class ZetaChaingun : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 1142857;
		ZetaWeapon.MinAmmo 1;
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClass() == "Chaingun";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return sqrt(shooter.Distance2D(target)) * 1.3;
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		ZetaBullet.FireABullet(shooter, "Gold", target, random(1, 3) * 8, 5.6, 0);
		shooter.A_PlaySound("weapons/chngun", CHAN_WEAPON);
	}
}