class ZetaGoldWand : ZTMyWeapon {
	default {
		ZTMyWeapon.ZT_HITSCAN true;
		ZTMyWeapon.ZT_BULLETCUSTOMDAMAGE true;
		
		ZTMyWeapon.WeaponType "GoldWand";
		ZTMyWeapon.BaseRating 300;
		ZTMyWeapon.RatingFade 0.9;
		ZTMyWeapon.Puff "GoldWandPuff1";
		ZTMyWeapon.ShootSound "weapons/wandhit";
		ZTMyWeapon.BulletSpreadH 5.625;
		ZetaWeapon.FireInterval 3142857;
		ZetaWeapon.AmmoType "GoldWandAmmo";
	}

	override int CustomHitscanDamage() {
		return Random(7, 14);
	}
}
