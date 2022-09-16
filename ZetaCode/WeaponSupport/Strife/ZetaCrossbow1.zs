class ZetaCrossbow1 : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 9142857;
		ZetaWeapon.MinAmmo 1;
		ZetaWeapon.AmmoType "ElectricBolts";
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
		return other.GetClass() == "StrifeCrossbow";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
        if ( target.bNOBLOOD )
            return 800 / sqrt(shooter.Distance3D(target) / 2);
            
        return 300 / sqrt(shooter.Distance3D(target) / 2);
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		shooter.SpawnMissileAngle("ElectricBolt", ZetaWeapon.RandomAngle(5.625 / pow(2, floor(shooter.accuracy / 2)), shooter.angle), tan(ZetaWeapon.RandomAngle(5.625 / pow(2, floor(shooter.accuracy / 2)))) + (target.pos.z - shooter.pos.z) * 30 / target.Distance2D(shooter));
		shooter.A_PlaySound("weapons/xbowshoot", CHAN_WEAPON);
	}
}
