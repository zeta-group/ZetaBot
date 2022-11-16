class ZetaPhoenixRod : ZTMyWeapon {
	default {
		ZTMyWeapon.ZT_SPLASHDANGER true;

		ZTMyWeapon.WeaponType "PhoenixRod";
		ZTMyWeapon.BaseRating 10000;
		ZTMyWeapon.RatingFade 2;

		ZTMyWeapon.DangerRadius 112;
		ZTMyWeapon.DangerRating 8000;
		ZTMyWeapon.DangerFactor 2;

		ZetaWeapon.FireInterval 5714286;
		ZetaWeapon.AmmoType "PhoenixRodAmmo";
		ZetaWeapon.WeaponName "Phoenix Rod";
	}

	override void Fire(Actor shooter, Actor target)
	{
		double pitch = 0;

		if (target != null && target.Distance2D(shooter) > 0)
			pitch = ((target.pos.z - shooter.pos.z) * 25 / target.Distance2D(shooter));

		shooter.SpawnMissileAngle("PhoenixFX1", shooter.angle, pitch);
		shooter.Thrust(-4);
	}
}
