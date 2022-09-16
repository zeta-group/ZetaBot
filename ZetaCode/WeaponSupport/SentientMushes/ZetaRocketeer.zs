class ZetaRocketeer : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 5714285;
		ZetaWeapon.AltFireInterval 5714285;
		ZetaWeapon.MinAmmo 1;
		ZetaWeapon.AltMinAmmo 1;
        ZetaWeapon.AltAmmoUse 0;
		ZetaWeapon.AmmoType "RocketAmmo";
		ZetaWeapon.AltAmmoType "RocketAmmo";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClassName() == "Rocketeer";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return true;
	}
    
	override double RateSelf(Actor shooter, Actor target) // Rocketeer grenade
	{
		return sqrt(shooter.Distance2D(target)) * 2 - 150;
	}
	
	override double AltRateSelf(Actor shooter, Actor target) // Rocketeer cluster bomb
	{
		if ( shooter.Distance3D(target) < 150 )
			return 300 - shooter.Distance3D(target) * 2;
	
		return 1000 / sqrt(shooter.Distance2D(target)) * 2.5;
	}
	
	override void Fire(Actor shooter, Actor target)
	{
        let ggs = "RRGrenade";
        Class<Actor> gg = ggs;
        
        if ( gg )
            shooter.SpawnMissileAngle(gg, shooter.angle, target == null ? 0 : ((target.pos.z - shooter.pos.z) * 25 / target.Distance2D(shooter)));
	}
    
    override void AltFire(Actor shooter, Actor target)
    {
        let cbs = "RRClusterBomb";
        let rfs = "RocketFog";
        
        Class<Actor> cb = cbs;
        Class<Actor> rf = rfs;
    
        if ( cb && rf )
        {
            shooter.SpawnMissileAngle(cb, shooter.angle, target == null ? 0 : ((target.pos.z - shooter.pos.z) * 19 / target.Distance2D(shooter)));
            shooter.SpawnMissileAngle(rf, shooter.angle, shooter.pitch);
        }
    }
}
