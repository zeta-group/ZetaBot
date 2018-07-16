#include "ZetaCode/WeaponSupport/SentientMushes/ClawAttack.zsc"

class ZetaClaw : ZetaWeapon
{
	default
	{
		ZetaWeapon.FireInterval 3142857;
		ZetaWeapon.AltFireInterval 3142857;
	}

	override bool IsPickupOf(Weapon other)
	{
		return other.GetClassName() == "WyvernPaw";
	}
	
	override bool bHasAltFire(Actor shooter)
	{
		// return true;
		return false; // not ready to do infection mechanism in the ZetaBot yet.
	}
	
	override double RateSelf(Actor shooter, Actor target)
	{
        if ( shooter.Distance3D(target) > 192 )
            return -500;
    
		return (25 + shooter.Radius + target.Radius) - shooter.Distance3D(target);
	}
    
    int CountInv(Actor other, string inv, bool subclass = false)
    {
        Inventory inv = Inventory(other.FindInventory(inv, subclass));
        
        if ( inv == null )
            return 0;
            
        return inv.amount;
    }
	
	override double AltRateSelf(Actor shooter, Actor target)
	{
        if ( shooter.Distance3D(target) > 192 )
            return -500;
    
		return -CountInv(target, "Immune") * shooter.Distance3D(target) / 96 + 45;
	}
	
	override void Fire(Actor shooter, Actor target)
	{
		ClawAttack cattack = ClawAttack(Spawn('ClawAttack'));
        
        if ( cattack == null )
            return;
            
        cattack.shooter = shooter;
        cattack.target = target;
        cattack.Attack(5, 1, 3, 7);
	}
	
	override bool IsMelee()
	{
		return true;
	}
}