class ZetaWeaponModule : Actor
{
	Array<ZetaWeapon> weaponsLoaded;
	
	void LoadModule(ZetaWeaponModule module)
	{
		module.LoadWeapons(self);
	}
	
	virtual void LoadWeapons(ZetaWeaponModule loader)
	{
		loader.A_Log("\cbCan not call LoadWeapons in a ZetaWeaponModule; use a subclass instead!");
	}
	
	void AddWeapon(String weap) // subclass ZetaWeapon, not Weapon!
	{
		ZetaWeapon spawnedWeap = ZetaWeapon(Spawn(weap));
		weaponsLoaded.Push(spawnedWeap);
	}
	
	ZetaWeapon CheckType(Weapon other)
	{
		for ( int i = 0; i < weaponsLoaded.Size(); i++ ) {
			ZetaWeapon zw = weaponsLoaded[i];
			bool isp = zw.IsPickupOf(other);
		
			if ( isp )
				return zw;
		}
			
		return null;
	}
}