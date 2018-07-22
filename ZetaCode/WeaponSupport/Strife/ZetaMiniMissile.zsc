class ZetaMiniMissile : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 5428571;
		ZetaWeapon.MinAmmo 1;
		ZetaWeapon.AmmoType "MiniMissiles";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClass() == "MiniMissileLauncher";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		if ( shooter.Distance3D(target) < 120 )
			return 300 - shooter.Distance3D(target) * 2;
	
		return 900 / sqrt(shooter.Distance2D(target)) * 2.5;
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		shooter.SpawnMissileAngle("MiniMissile", shooter.angle + ZetaWeapon.RandomAngle(11 - shooter.accuracy / 10), tan(ZetaWeapon.RandomAngle(11 - shooter.accuracy / 10)) + (target.pos.z - shooter.pos.z) * 20 / target.Distance2D(shooter));
	}
}
