class ZetaFist : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 5142857;
		ZetaWeapon.AmmoUse 0;
		ZetaWeapon.WeaponName "Fist";

		Obituary "%k showed %o some witty & humilitating knuckle usage.";
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClass() == "Fist";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		if (shooter.Health < 30) {
			return -50;
		}

		if (shooter.CheckInventory("PowerStrength", 1) && shooter.Distance2D(target) < 256) {
			return shooter.Health * 5;
		}

		return -50;
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		shooter.LineAttack(shooter.angle, 32, 0, (shooter.CheckInventory("PowerStrength", 1) ? 20 : 2) * Random(1, 10), "Punch", "BulletPuff", 0);
	}
	
	override bool IsMelee()
	{
		return true;
	}
}
