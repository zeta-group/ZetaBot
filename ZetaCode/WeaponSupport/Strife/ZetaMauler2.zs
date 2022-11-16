class ZetaMauler2 : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 15428571;
		ZetaWeapon.MinAmmo 30;
		ZetaWeapon.AmmoUse 30;
		ZetaWeapon.AmmoType "EnergyPod";
		ZetaWeapon.WeaponName "Mauler";
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
		return other.GetClass() == "Mauler2";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return 500 - pow(shooter.Distance3D(target) / 5, 2);
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		shooter.SpawnMissile(target, "MaulerTorpedo", shooter);
		DamageMobj(shooter, null, 20, "Disintegrate");
		shooter.Thrust(7.8125, shooter.Angle+180.);
	}
}
