class ZetaKnife : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 4857142;
		ZetaWeapon.AltFireInterval 3142857;
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClassName() == "IronKnife";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return true;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return 125;
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		shooter.LineAttack(shooter.angle, 32, 0, Random(54, 108), "Punch", "");
	}
	
	override double AltRateSelf(Actor shooter, Actor target)
	{
		return 125;
	}
	
	override void AltFire(Actor shooter, Actor target)
	{
		shooter.LineAttack(shooter.angle, 32, 0, Random(10, 22), "Punch", "");
	}
	
	override bool IsMelee()
	{
		return true;
	}
}