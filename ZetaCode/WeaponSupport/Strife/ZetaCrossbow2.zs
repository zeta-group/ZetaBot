class ZetaCrossbow2 : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 9142857;
		ZetaWeapon.MinAmmo 1;
		ZetaWeapon.AmmoType "PoisonBolts";
		ZetaWeapon.WeaponName "Crossbow  (Poison Bolts)";

		Obituary "%o got deathly sick from %k's Crossbow.";
	}
	
	double pow(double a, uint b)
	{
		if ( b == 0 )
			return 1;
			
		else
			return a * pow(a, b - 1);
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClass() == "StrifeCrossbow2";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		if ( target.bNOBLOOD || target.bBOSS )
			return 80 / sqrt(shooter.Distance3D(target) / 4);
			
		return 900 / sqrt(shooter.Distance3D(target) / 4);
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		shooter.SpawnMissileAngle("PoisonBolt", ZetaWeapon.RandomAngle(5.625 / pow(2, floor(shooter.accuracy / 2)), shooter.angle), tan(ZetaWeapon.RandomAngle(5.625 / pow(2, floor(shooter.accuracy / 2)))) + (target.pos.z - shooter.pos.z) * 30 / target.Distance2D(shooter));
		shooter.A_PlaySound("weapons/xbowshoot", CHAN_WEAPON);
	}
}
