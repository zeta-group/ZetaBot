class ZetaBFG : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 11428571;
		ZetaWeapon.MinAmmo 40;
		ZetaWeapon.AmmoUse 40;
		ZetaWeapon.AmmoType "Cell";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClass() == "BFG9000";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return 300 * target.Health / (shooter.Distance2D(target));
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		double pitch = 0;

		if (target != null && target.Distance2D(shooter) > 0)
			pitch = ((target.pos.z - shooter.pos.z) * 25 / target.Distance2D(shooter));

		shooter.SpawnMissileAngle("BFGBall", shooter.angle, pitch);
	}
}
