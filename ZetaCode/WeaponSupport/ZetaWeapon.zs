class ZetaWeapon : Actor
{
	property FireInterval: interval;
	property AltFireInterval: altinterval;
	property MinAmmo: minammo;
	property AmmoType: ammotype;
	property AltMinAmmo: altminammo;
	property AltAmmoType: altammotype;
    property AmmoUse: ammouse;
    property AltAmmoUse: altammouse;        
	
	int interval;
	int altinterval;
	int minammo;
	string ammotype;
	int altminammo;
	string altammotype;
    int ammouse;
    int altammouse;
	
	default
	{
		ZetaWeapon.FireInterval 10000000;
		ZetaWeapon.AltFireInterval 10000000;
		ZetaWeapon.MinAmmo 0;
		ZetaWeapon.AltMinAmmo 0;
        ZetaWeapon.AmmoUse 1;
        ZetaWeapon.AltAmmoUse 1;
		ZetaWeapon.AmmoType "Clip";
		ZetaWeapon.AltAmmoType "Clip";
	}
	
	static double RandomAngle(double range, double pivot = 0)
	{
        return FRandom(-range, range) + pivot;
	}

	virtual bool IsPickupOf(Weapon other)
	{
		return false;
	}
	
	virtual bool bHasAltFire(Actor shooter)
	{
		return true;
	}
	
	virtual double RateSelf(Actor shooter, Actor target)
	{
		return 0;
	}
	
	virtual double AltRateSelf(Actor shooter, Actor target)
	{
		return -1;
	}

	double GetRating(Actor shooter, Actor target)
	{
		if (target == null) return FRandom(0, 20);
		return RateSelf(shooter, target);
	}
	
	double GetAltRating(Actor shooter, Actor target)
	{
		if (target == null) return FRandom(0, 20);
		return AltRateSelf(shooter, target);
	}
	
	virtual bool CanFireAmmo(Actor shooter)
	{
		return true;
	}

	virtual bool CanFire(Actor shooter, bool bUseAmmo = false)
	{
		if (CVar.FindCVar("sv_infiniteammo").GetBool()) {
			return true;
		}
	
		Inventory inv = shooter.FindInventory(ammotype);

		if ( inv == null )
			return minammo <= 0;
			
		else
		{
			if ( bUseAmmo && inv.amount >= minammo )
			{
				inv.amount -= minammo;
				return true;
			}

			return inv.amount >= minammo;
		}
	}
	
	virtual bool CanAltFire(Actor shooter, bool bUseAmmo = false)
	{
        if ( !bHasAltFire(shooter) )
            return false;
    
		Inventory inv = shooter.FindInventory(altammotype);
		
		if ( inv == null )
			return altminammo <= 0;
		
		else
		{
			if ( bUseAmmo && inv.amount >= altminammo )
			{
				inv.amount -= altminammo;
				return true;
			}

			return inv.amount >= altminammo;
		}
	}
	
	virtual double IntervalSeconds()
	{
		return 1. * interval / 10000000;
	}
	
	virtual double AltIntervalSeconds()
	{
		return 1. * altinterval / 10000000;
	}
	
	virtual void Fire(Actor shooter, Actor target) {}
	virtual void AltFire(Actor shooter, Actor target) {}
	
	virtual bool IsMelee()
	{
		return false;
	}
}


// For simplicity.
class ZTMyWeapon : ZetaWeapon {
	bool bZT_SPLASHDANGER;
	bool bZT_ALTSPLASHDANGER;
	bool bZT_HASALT;
	bool bZT_MELEE;
	bool bZT_ALTMELEE;
	bool bZT_HITSCAN;
	bool bZT_ALTHITSCAN;
	bool bZT_BULLETCUSTOMDAMAGE;
	bool bZT_ALTBULLETCUSTOMDAMAGE;
	bool bZT_MELEECUSTOMDAMAGE;
	bool bZT_ALTMELEECUSTOMDAMAGE;

	property ZT_SPLASHDANGER: bZT_SPLASHDANGER;
	property bZT_ALTSPLASHDANGER: bZT_ALTSPLASHDANGER;
	property ZT_HASALT: bZT_HASALT;
	property ZT_MELEE: bZT_MELEE;
	property ZT_ALTMELEE: bZT_ALTMELEE;
	property ZT_HITSCAN: bZT_HITSCAN;
	property ZT_ALTHITSCAN: bZT_ALTHITSCAN;
	property ZT_BULLETCUSTOMDAMAGE: bZT_BULLETCUSTOMDAMAGE;
	property ZT_ALTBULLETCUSTOMDAMAGE: bZT_ALTBULLETCUSTOMDAMAGE;
	property ZT_MELEECUSTOMDAMAGE: bZT_MELEECUSTOMDAMAGE;
	property ZT_ALTMELEECUSTOMDAMAGE: bZT_ALTMELEECUSTOMDAMAGE;

	double DangerRadius;
	double AltDangerRadius;
	double MeleeDamage;
	double AltMeleeDamage;
	class<Actor> MissileType;
	class<Actor> AltMissileType;
	class<Weapon> WeaponType;
	double BulletMinDamage;
	double BulletMaxDamage;
	double AltBulletMinDamage;
	double AltBulletMaxDamage;
	double BaseRating;
	double AltBaseRating;
	double DangerRating;
	double AltDangerRating;
	double BulletSpreadH;
	double AltBulletSpreadH;
	double BulletSpreadV;
	double AltBulletSpreadV;
	double DangerFactor;
	double AltDangerFactor;
	string ShootSound;
	string AltShootSound;
	double RatingFade;
	double AltRatingFade;
	string Puff;
	string AltPuff;

	property MissileType: MissileType;
	property AltMissileType: MissileType;
	property MeleeDamage: MeleeDamage;
	property AltMeleeDamage: AltMeleeDamage;
	property BulletMinDamage: BulletMinDamage;
	property BulletMaxDamage: BulletMaxDamage;
	property AltBulletMinDamage: AltBulletMinDamage;
	property AltBulletMaxDamage: AltBulletMaxDamage;
	property BaseRating: BaseRating;
	property AltBaseRating: AltBaseRating;
	property DangerRating: DangerRating;
	property AltDangerRating: AltDangerRating;
	property DangerRadius: DangerRadius;
	property AltDangerRadius: AltDangerRadius;
	property WeaponType: WeaponType;
	property BulletSpreadH: BulletSpreadH;
	property AltBulletSpreadH: AltBulletSpreadH;
	property BulletSpreadV: BulletSpreadV;
	property AltBulletSpreadV: AltBulletSpreadV;
	property DangerFactor: DangerFactor;
	property AltDangerFactor: AltDangerFactor;
	property ShootSound: ShootSound;
	property AltShootSound: AltShootSound;
	property RatingFade: RatingFade;
	property AltRatingFade: AltRatingFade;
	property Puff: Puff;
	property AltPuff: AltPuff;

	default {
		ZTMyWeapon.DangerRadius 128;
		ZTMyWeapon.AltDangerRadius 128;
		ZTMyWeapon.MeleeDamage 3;
		ZTMyWeapon.AltMeleeDamage 5;
		ZTMyWeapon.MissileType "Rocket";
		ZTMyWeapon.AltMissileType "Rocket";
		ZTMyWeapon.BulletMinDamage 2;
		ZTMyWeapon.BulletMaxDamage 5;
		ZTMyWeapon.AltBulletMinDamage 3;
		ZTMyWeapon.AltBulletMaxDamage 7;
		ZTMyWeapon.BaseRating 500;
		ZTMyWeapon.DangerRating 300;
		ZTMyWeapon.AltDangerRating 300;
		ZTMyWeapon.BulletSpreadH 10;
		ZTMyWeapon.AltBulletSpreadH 10;
		ZTMyWeapon.BulletSpreadV 0;
		ZTMyWeapon.AltBulletSpreadV 0;
		ZTMyWeapon.DangerFactor 1.5;
		ZTMyWeapon.AltDangerFactor 1.5;
		ZTMyWeapon.ShootSound "";
		ZTMyWeapon.AltShootSound "";
		ZTMyWeapon.RatingFade 1;
		ZTMyWeapon.AltRatingFade 1;
		ZTMyWeapon.Puff "BulletPuff";
		ZTMyWeapon.AltPuff "BulletPuff";

		ZetaWeapon.MinAmmo 1;
		ZetaWeapon.AltMinAmmo 1;
		ZetaWeapon.AmmoUse 1;
		ZetaWeapon.AltAmmoUse 1;
	}

	virtual int CustomHitscanDamage() {
		return 5 * Random(1, 3);
	}

	virtual int CustomAltHitscanDamage() {
		return 5 * Random(1, 3);
	}

	virtual int CustomMeleeDamage() {
		return 5 * Random(1, 8);
	}

	virtual int CustomAltMeleeDamage() {
		return 5 * Random(1, 8);
	}

	int GetHitscanDamage() {
		if (bZT_BULLETCUSTOMDAMAGE)
			return CustomHitscanDamage();

		return Random(BulletMinDamage, BulletMaxDamage);
	}

	int GetAltHitscanDamage() {
		if (bZT_ALTBULLETCUSTOMDAMAGE)
			return CustomAltHitscanDamage();

		return Random(AltBulletMinDamage, AltBulletMaxDamage);
	}

	int GetMeleeDamage() {
		if (bZT_MELEECUSTOMDAMAGE)
			return CustomMeleeDamage();

		return MeleeDamage * Random(1, 8);
	}

	int GetAltMeleeDamage() {
		if (bZT_ALTMELEECUSTOMDAMAGE)
			return CustomAltMeleeDamage();

		return AltMeleeDamage * Random(1, 8);
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClass() == WeaponType;
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return bZT_HASALT;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		if (bZT_MELEE) {
			if (shooter.Distance2D(target) <= 32 + shooter.Radius + target.Radius)
				return BaseRating;

			return -1000;
		}

		if (bZT_SPLASHDANGER && shooter.Distance3D(target) < DangerRadius)
			return DangerRating * ((shooter.Distance3D(target) - DangerRadius) * DangerFactor) / DangerRadius;
	
		return BaseRating / sqrt(shooter.Distance2D(target) * Max(1, RatingFade));
	}

	override double AltRateSelf(Actor shooter, Actor target)
	{
		if (bZT_ALTMELEE) {
			if (shooter.Distance2D(target) <= 32 + shooter.Radius + target.Radius)
				return AltBaseRating;

			return -1000;
		}

		if (bZT_ALTSPLASHDANGER && shooter.Distance3D(target) < AltDangerRadius)
			return AltDangerRating * ((AltDangerRadius - shooter.Distance3D(target)) * AltDangerFactor) / AltDangerRadius;
	
		return AltBaseRating / sqrt(shooter.Distance2D(target) * Max(1, AltRatingFade));
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		if (bZT_MELEE)
			shooter.LineAttack(shooter.angle, 32, 0, GetMeleeDamage(), "Punch", Puff, 0);

		else if (bZT_HITSCAN)
			ZetaBullet.FireABullet(shooter, "Gold", target, random(BulletMinDamage, BulletMaxDamage), BulletSpreadH, BulletSpreadV, "Hitscan", Puff);

		else
			shooter.SpawnMissileAngle(MissileType, shooter.angle, target == null ? 0 : ((target.pos.z - shooter.pos.z) * 20 / target.Distance2D(shooter)));

		if (ShootSound != "")
			shooter.A_PlaySound(ShootSound, CHAN_WEAPON);
	}

	override void AltFire(Actor shooter, Actor target)
	{
		if (bZT_MELEE)
			shooter.LineAttack(shooter.angle, 32, 0, AltMeleeDamage, "Punch", AltPuff, 0);

		else if (bZT_ALTHITSCAN)
			ZetaBullet.FireABullet(shooter, "Gold", target, random(AltBulletMinDamage, AltBulletMaxDamage), AltBulletSpreadH, AltBulletSpreadV, "Hitscan", AltPuff);

		else
			shooter.SpawnMissileAngle(ALtMissileType, shooter.angle, target == null ? 0 : ((target.pos.z - shooter.pos.z) * 20 / target.Distance2D(shooter)));

		if (AltShootSound != "")
			shooter.A_PlaySound(ALtShootSound, CHAN_WEAPON);
	}
}
