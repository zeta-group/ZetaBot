class ZetaChainsaw : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 2285714;
		ZetaWeapon.AmmoUse 0;
		ZetaWeapon.WeaponName "Chainsaw";
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
		if (shooter.Health < 30) {
			return -50;
		}

		if (shooter.Distance2D(target) < shooter.Radius + target.Radius + 50) {
			return 600;
		}

		return 0;
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
