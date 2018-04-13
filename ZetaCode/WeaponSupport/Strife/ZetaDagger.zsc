class ZetaDagger : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 4857142;
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClass() == "PunchDagger";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return 10;
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		let power = min(shooter.stamina / 10, 10);
	
		if ( shooter.LineAttack(ZetaWeapon.RandomAngle(5.625, shooter.angle), 32, 0, (power + 2) * Random(0, power * 7), "Dagger", "StrifeSpark", 0) != null )
			shooter.A_PlaySound("misc/swish");
			
		else
			shooter.A_PlaySound("misc/meathit");
	}
	
	override bool IsMelee()
	{
		return true;
	}
}
