class ZetaHereticCrossbow : ZTMyWeapon {
	default {
		ZTMyWeapon.WeaponType "Crossbow";
		ZTMyWeapon.BaseRating 1000;
		ZTMyWeapon.RatingFade 1.5;

		ZetaWeapon.FireInterval 6285714;
		ZetaWeapon.AmmoType "CrossbowAmmo";
		ZetaWeapon.WeaponName "Crossbow";
	}

	override void Fire(Actor shooter, Actor target)
	{
		double pitch = 0;

		if (target != null && target.Distance2D(shooter) > 0)
			pitch = ((target.pos.z - shooter.pos.z) * 25 / target.Distance2D(shooter));

		shooter.SpawnMissileAngle("CrossbowFX1", shooter.angle, pitch);
		shooter.SpawnMissileAngle("CrossbowFX3", shooter.angle - 4.5, pitch);
		shooter.SpawnMissileAngle("CrossbowFX3", shooter.angle + 4.5, pitch);
	}
}
