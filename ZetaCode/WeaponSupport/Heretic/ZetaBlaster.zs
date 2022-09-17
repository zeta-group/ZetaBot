class ZetaBlaster : ZTMyWeapon {
	default {
		ZTMyWeapon.ZT_HITSCAN true;
		ZTMyWeapon.ZT_BULLETCUSTOMDAMAGE true;
		
		ZTMyWeapon.WeaponType "Blaster";
		ZTMyWeapon.BaseRating 800;
		ZTMyWeapon.RatingFade 1.2;
		ZTMyWeapon.Puff "BlasterPuff";
		ZTMyWeapon.ShootSound "weapons/blastershoot";
		ZTMyWeapon.BulletSpreadH 5.625;
		ZetaWeapon.FireInterval 1714285;
		ZetaWeapon.AmmoType "BlasterAmmo";
	}

	override int CustomHitscanDamage() {
		return 4 * Random(1, 8);
	}
}