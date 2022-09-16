class ZetaMauler1 : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 9428571;
		ZetaWeapon.MinAmmo 20;
        ZetaWeapon.AmmoUse 20;
		ZetaWeapon.AmmoType "EnergyPod1";
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
		return other.GetClass() == "Mauler";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
        return 600 - pow(shooter.Distance3D(target) / 3, 2);
	}
	
	override void Fire(Actor shooter, Actor target)
	{
        for (int i = 0 ; i < 20 ; i++)
		{
            int damage = 5 * random[Mauler1](1, 3);
            double ang = angle + Random2[Mauler1]() * (11.25 / 256);
        
            shooter.angle += ang;
        
            ZetaBullet.FireABullet(shooter, "Purple", target, 4 * (random[StrifeGun]() % 3 + 1), Random2[Mauler1]() * (7.097 / 256), FRandom(-4, 4), "MaulerPuff");
            shooter.A_PlaySound("weapons/mauler1", CHAN_WEAPON);
            
            shooter.angle -= ang;
        }
	}
}
