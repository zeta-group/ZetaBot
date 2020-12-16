class ZetaFlameThrower : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 571428;
		ZetaWeapon.MinAmmo 1;
		ZetaWeapon.AmmoType "EnergyPod";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClass() == "FlameThrower";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return 1000 - shooter.Distance2D(target) * 1.75;
	}
	
	override void Fire(Actor shooter, Actor target)
	{
        shooter.angle += Random2[Flamethrower]() * (5.625/256.);
		
		FlameMissile f = FlameMissile(shooter.SpawnMissile(target, "FlameMissile", shooter));
		
		if ( f != null )
            f.vel.z += 5; // based on gzdoom.pk3 ZScript
	}
}
