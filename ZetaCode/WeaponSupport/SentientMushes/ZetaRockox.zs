class ZetaRockox : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 3714285;
		ZetaWeapon.MinAmmo 1;
		ZetaWeapon.AmmoType "RockoxClip";
		ZetaWeapon.WeaponName "Rockox";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClassName() == "Rockox";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		if ( shooter.Distance3D(target) < 250 )
			return 180 - shooter.Distance3D(target) * 2.5;
	
		return 1250 / sqrt(shooter.Distance2D(target)) * 2.5;
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		String rrs = "RockoxRocket";
		Class<Actor> rr = rrs;
	
		if ( rr )
		{
			shooter.SpawnMissileAngle(rr, shooter.angle, target == null ? 0 : ((target.pos.z - shooter.pos.z) * 20 / target.Distance2D(shooter)));
			shooter.A_PlaySound("rockox/fire", CHAN_WEAPON);
		}
	}
}
