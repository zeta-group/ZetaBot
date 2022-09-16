class ZetaPR : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 857142;
		ZetaWeapon.MinAmmo 1;
		ZetaWeapon.AmmoType "Cell";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClass() == "PlasmaRifle";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return 1200 / sqrt(shooter.Distance3D(target)) * 3;
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		double pitch = 0;

		if (target != null && target.Distance2D(shooter) > 0)
			pitch = ((target.pos.z - shooter.pos.z) * 25 / target.Distance2D(shooter));

		shooter.SpawnMissileAngle("PlasmaBall", shooter.angle, pitch);
	}
}