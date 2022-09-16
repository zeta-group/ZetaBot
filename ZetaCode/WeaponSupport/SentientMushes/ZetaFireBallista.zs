class Minigun : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 1142857;
		ZetaWeapon.AltFireInterval 4571428;
		ZetaWeapon.MinAmmo 1;
		ZetaWeapon.AmmoType "BallistaAmmo";
		ZetaWeapon.AltMinAmmo 3;
        ZetaWeapon.AltAmmoUse 3;
		ZetaWeapon.AltAmmoType "BallistaAmmo";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClassName() == "FireBallista";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return true;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return shooter.Distance2D(target) + 150;
	}
	
	override double AltRateSelf(Actor shooter, Actor target)
	{
		return shooter.Distance2D(target) * 2.5;
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		shooter.SpawnMissileAngle("BallistaMissile", shooter.angle, target == null ? 0 : ((target.pos.z - shooter.pos.z) * 15 / target.Distance2D(shooter)));
		shooter.A_PlaySound("fireballista/shoot");
	}
    
	override void AltFire(Actor shooter, Actor target)
	{
        for ( int _ = 0; _ < 11; _++ )
            shooter.SpawnMissileAngle("DrunkBallistaMissile", shooter.angle + frandom(-3, 3), target == null ? 0 : ((target.pos.z - shooter.pos.z) * 15 / target.Distance2D(shooter)));
            
		shooter.A_PlaySound("fireballista/shoot");
	}
    
}
