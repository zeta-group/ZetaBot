class ZetaFist : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 5142857;
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
		return -50;
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		shooter.LineAttack(shooter.angle, 32, 0, 20 * Random(1, 8), "Punch", "BulletPuff", 0);
	}
	
	override bool IsMelee()
	{
		return true;
	}
}