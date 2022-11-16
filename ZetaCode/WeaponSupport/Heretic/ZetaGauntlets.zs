class ZetaGauntlets : ZTMyWeapon {
	default {
		ZTMyWeapon.ZT_MELEE true;
		ZTMyWeapon.ZT_MELEECUSTOMDAMAGE true;
		
		ZTMyWeapon.WeaponType "Staff";
		ZTMyWeapon.BaseRating 1100;
		ZTMyWeapon.RatingFade 9;
		ZTMyWeapon.ShootSound "weapons/gauntletsuse";
		ZTMyWeapon.Puff "GauntletPuff1";
		ZetaWeapon.FireInterval 1142857;
		ZetaWeapon.MinAmmo 0;
		ZetaWeapon.AmmoUse 0;
		ZetaWeapon.WeaponName "Gauntlets";
	}

	override int CustomMeleeDamage() {
		return 2 * Random(1, 8);
	}

	override void Fire(Actor shooter, Actor target)
	{
		if (bZT_MELEE)
			shooter.LineAttack(shooter.angle, 256, 0, GetMeleeDamage(), "Punch", Puff, 0);

		else
			Super.Fire(shooter, target);
	}
}
