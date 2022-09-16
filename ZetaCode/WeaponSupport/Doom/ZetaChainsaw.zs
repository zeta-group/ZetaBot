class ZetaChainsaw : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 2285714;
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClass() == "Chainsaw";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		return false;
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
		return ((shooter.Distance2D(target) < shooter.Radius + target.Radius + 32) ? 800 : 0);
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		shooter.LineAttack(shooter.angle, 32, 0, 2 * Random(1, 9), "Punch", "BulletPuff", 0);
		shooter.A_PlaySound("weapons/sawfull", CHAN_WEAPON);		
	}
	
	override bool IsMelee()
	{
		return true;
	}
}