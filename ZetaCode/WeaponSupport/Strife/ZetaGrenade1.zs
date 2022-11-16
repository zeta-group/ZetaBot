class ZetaGrenade1 : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 8571428;
		ZetaWeapon.MinAmmo 1;
		ZetaWeapon.AmmoType "HEGrenadeRounds";
		ZetaWeapon.WeaponName "Grenade Launcher (High-Explosive)";

		Obituary "%k blew %o to smithereens with the Grenade Launcher!";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClass() == "StrifeGrenadeLauncher";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return 700 - shooter.Distance3D(target) / 1.25;
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		HEGrenade gr = HEGrenade(shooter.SpawnMissileAngle("HEGrenade", shooter.angle + ZetaWeapon.RandomAngle(11 - shooter.accuracy / 10), tan(shooter.pitch + ZetaWeapon.RandomAngle(11 - shooter.accuracy / 10))));
		
		if ( gr != null )
		{
			uint angoffs = (Random(0, 1) * 2 - 1) * 90;
		
			gr.vel.z = (-clamp(tan(shooter.pitch), -5, 5)) * gr.Speed + 8;
			
			Vector2 offset = shooter.AngleToVector(shooter.angle, shooter.radius + gr.radius);
			double an = shooter.angle + angoffs;
			offset += shooter.AngleToVector(an, 15);
			gr.SetOrigin(gr.Vec3Offset(offset.X, offset.Y, 0.), false);
		}
	}
}
