class ZetaFiremace : ZTMyWeapon {
	default {
		ZTMyWeapon.WeaponType "Mace";
		ZTMyWeapon.BaseRating 2000;
		ZTMyWeapon.RatingFade 5;

		ZetaWeapon.FireInterval 857143;
		ZetaWeapon.AmmoType "MaceAmmo";
	}

	override void Fire(Actor shooter, Actor target)
	{
		double pitch = 0;

		if (target != null && target.Distance2D(shooter) > 0)
			pitch = ((target.pos.z - shooter.pos.z) * 25 / target.Distance2D(shooter));

		pitch += tan(15);

		if (FRandom(0.1, 100) <= 89) { // https://zdoom.org/wiki/A_FireMacePL1 - "about 89% chance"
			MaceFX1 proj = MaceFX1(shooter.SpawnMissileAngle("MaceFX1", shooter.angle + FRandom(-4.219, 4.219), pitch));
			if (proj != null) proj.special1 = 16;
		}

		else { // "about 11% chance"
			MaceFX2 proj = MaceFX2(shooter.SpawnMissileAngleZ(28, "MaceFX2", shooter.angle, pitch + 2));
			if (proj != null) proj.A_PlaySound("weapons/maceshoot", CHAN_BODY);
		}
	}
}