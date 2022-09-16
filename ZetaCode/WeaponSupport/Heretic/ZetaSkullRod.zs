class ZetaSkullRod : ZTMyWeapon {
    default {
        ZTMyWeapon.WeaponType "SkullRod";
        ZTMyWeapon.BaseRating 2000;
        ZTMyWeapon.RatingFade 1.5;

        ZetaWeapon.FireInterval 2285714;
        ZetaWeapon.AmmoType "SkullRodAmmo";
    }

    override void Fire(Actor shooter, Actor target)
	{
        double pitch = 0;

		if (target != null && target.Distance2D(shooter) > 0)
			pitch = ((target.pos.z - shooter.pos.z) * 25 / target.Distance2D(shooter));

        HornRodFX1 proj = HornRodFX1(shooter.SpawnMissileAngle("HornRodFX1", shooter.angle, pitch));

        if (proj != null) proj.SetState(proj.CurState.NextState);
	}
}