class ZetaRL : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 5714285;
		ZetaWeapon.MinAmmo 1;
		ZetaWeapon.AmmoType "RocketAmmo";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClass() == "RocketLauncher";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		if ( shooter.Distance3D(target) < 128 )
			return -50;
	
		return 2000 / (1 + sqrt(shooter.Distance2D(target) * 1.6));
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		double pitch = 0;

		if (target != null && target.Distance2D(shooter) > 0)
			pitch = ((target.pos.z - shooter.pos.z) * 25 / target.Distance2D(shooter));

		shooter.SpawnMissileAngle("Rocket", shooter.angle, pitch);
	}
}
