class ZetaBotPawn : Actor {
	property DefaultInv: defweap;
	String defweap;
	bool bMoved;
	double forward;
	double rightward;

	int ColorRangeStart, ColorRangeEnd;

	property ColorRangeStart: ColorRangeStart;
	property ColorRangeEnd: ColorRangeEnd;

	Default {
		PainChance 100;
		Speed 1;
		ZetaBotPawn.DefaultInv "";
		Health 100;
		Radius 16;
		Height 56;
		Mass 100;
		PainChance 255;
		Species "ZetaBotGuy";
		
		+SOLID
		+SHOOTABLE
		+DROPOFF
		+PICKUP
		+FRIENDLY
		+SLIDESONWALLS
		//+CANUSEWALLS
		//+CANPUSHWALLS
		+CANPASS
		+FLOORCLIP
		+WINDTHRUST
		+THRUSPECIES
		+TELESTOMP
		+NOBLOCKMONST
		//+ACTIVATEMCROSS
		+PUSHABLE
		+ISMONSTER
		//+BLOCKASPLAYER

		-CANPUSHWALLS
	}

	virtual void SetColor(float red, float green, float blue) {
		// translation does not work for now -- rely on team markers instead
	
		/*
		Translation trans;

		for (int i = ColorRangeStart; i < ColorRangeEnd; i++) {
			float value = trans.colors[i].r * 0.2126 + trans.colors[i].g * 0.7152 + trans.colors[i].b * 0.0722;
			trans.colors[i] = Color(red * value, green * value, blue * value);
		}

		translation = trans.AddTranslation();
		*/
	}

	static String GetSomeType() {
		Array<String> rset;
		Array<String> types;
		Array<String> parms;
		
		let btypes = CVar.FindCVar('zb_btypes').GetString();
		btypes.Split(types, ';');
		
		for ( uint i = 0; i < types.Size(); i++ ) {
			parms.Clear();
			types[i].Split(parms, ':');
			
			if ( parms.Size() < 2 )
				continue;
		
			let iter = ThinkerIterator.Create(parms[1]);
			
			// if ( anchor != null ) anchor.A_Log(parms[0]..': '..parms[1]);
			
			if ( iter.Next() )
				rset.Push(parms[0]);
		}
		
		//if ( anchor != null ) anchor.A_Log('Plausible types: '..rset.Size());
		
		if ( rset.Size() > 0 )
			return rset[Random(0, rset.Size() - 1)];
			
		else
			return "";
	}
	
	enum MovementModifier {
		MM_None,
		MM_Run,
		MM_Crouch,
	};
	
	MovementModifier moveType;
	bool bShooting; // for visual purposes
	ZTBotController cont;
	const speedMod = 1;
	
	void BotThrust(double maxSpeed, double angle) {
		Thrust(maxSpeed * speedMod, angle);
	}

	void CapSpeed(double maxSpeed) {
		if (vel.x > maxSpeed * speedMod)
			vel.x = min(vel.x, maxSpeed * speedMod);

		else if (vel.x < -maxSpeed * speedMod) 
			vel.x = max(vel.x, -maxSpeed * speedMod);

		if (vel.y > maxSpeed * speedMod)
			vel.y = min(vel.y, maxSpeed * speedMod);

		else if (vel.y < -maxSpeed * speedMod) 
			vel.y = max(vel.y, -maxSpeed * speedMod);
	}
	
	override void BeginPlay() {
		Array<String> dweap;
		defweap.split(dweap, ",");

		ChangeStatNum(STAT_DEFAULT);
		
		for ( int i = 0; i < dweap.Size(); i++ )
			GiveInventoryType(dweap[i]);
			
		Array<String> eweap;
		let extra = CVar.GetCVar("zb_extraweap").GetString();
			
		if ( extra != "" ) {
			extra.split(eweap, ",");	// not ";" to support Bash command
										//line parameter setting
			
			for ( int i = 0; i < eweap.Size(); i++ )
				GiveInventoryType(eweap[i]);
		}
	}

	void ApplyMovement() {
		if (forward > 0 ) {
			forward = max(forward - 1.0, 0);
			if (pos.z - floorz < 2) RealMoveForward();
		}

		else if (forward <= -1 ) {
			forward = min(forward + 1.0, 0);
			if (pos.z - floorz < 2) RealMoveBackward();
		}

		else if (forward < 0 ) {
			forward = min(forward + 0.8, 0);
			if (pos.z - floorz < 2) RealStepBackward();
		}

		if (rightward > 0 ) {
			rightward = max(rightward - 1.0, 0);
			if (pos.z - floorz < 2) RealMoveRight();
		}

		else if (rightward < 0 ) {
			rightward = max(rightward + 1.0, 0);
			if (pos.z - floorz < 2) RealMoveLeft();
		}

		forward /= 1.5;
		rightward /= 1.5;
		CapSpeed(10);
	}

	void RealMoveForward() {
		BotThrust(moveType == MM_Run ? 5 : (moveType == MM_Crouch ? 1.2 : 2.5), angle);
	}

	void RealMoveBackward() {
		BotThrust(moveType == MM_Run ? -4.5 : (moveType == MM_Crouch ? -1 : -2), angle);
	}

	void RealStepBackward() {
		BotThrust(moveType == MM_Run ? -3 : (moveType == MM_Crouch ? -0.8 : -1.35), angle);
	}
	
	void RealMoveRight() {
		BotThrust(moveType == MM_Run ? 5 : (moveType == MM_Crouch ? 1.2 : 2.5), angle + 90);
	}
	
	void RealMoveLeft() {
		BotThrust(moveType == MM_Run ? 5 : (moveType == MM_Crouch ? 1.2 : 2.5), angle - 90);
	}
	
	void MoveForward() {
		forward += 1;
	}

	void MoveBackward() {
		forward -= 1;
	}

	void StepBackward() {
		forward -= 0.4;
	}
	
	void MoveRight() {
		rightward += 1;
	}
	
	void MoveLeft() {
		rightward -= 1;
	}

	void SetMoveType(uint nmoveType) {
		moveType = nmoveType;
		
		if ( moveType == MM_CROUCH )
			Height = Default.Height / 2;
			
		else
			Height = Default.Height;
	}
	
	void BeginShoot() {
		bShooting = true;
	}
	
	void EndShoot() {
		bShooting = false;
	}
	
	void Jump() {
		if ( pos.z - floorZ > 1 || vel.z > 0 )
			return;
			
		vel.z += 10;
		vel.x /= 1.1;
		vel.y /= 1.1;

		A_PlaySound("ztmisc/jump", CHAN_BODY);
	}
	
	void A_BotPain() {
		if ( cont != null )
			cont.PlayPain();
	}
	
	override String GetObituary(Actor victim, Actor inflictor, Name mod, bool playerattack) {
		if (!cont) {
			return Super.GetObituary(victim, inflictor, mod, playerattack);
		}

		if (PlayerPawn(victim) && PlayerPawn(victim).player && cont.IsEnemy(PlayerPawn(victim), self)) {
			cont.ScoreFrag();
		}

		ZetaWeapon bestWeap;
		bool _bAltFire;

		[ bestWeap, _bAltFire ] = cont.BestWeaponAllTic();

		let obituary = (mod == 'Telefrag') ? "%k invaded %o's personal space." : Stringtable.Localize(bestWeap.GetObituary(victim, inflictor, mod, playerattack));
		obituary.replace("%k", cont.myName);
		obituary.replace("%w", bestWeap.weapName);

		return obituary;
	}

	override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath) {
		Super.Die(source, inflictor, dmgflags, MeansOfDeath);

		if (cont != null) {
			cont.OnDeath(source, inflictor, dmgflags, MeansOfDeath);
		}
			
		A_DropWeapons();
	}
	
	void A_DropWeapons() {
		if (CVar.FindCVar("sv_dropweapons").GetBool() && !CVar.FindCVar("zb_alwaysdropweapons").GetBool()) {
			return;
		}

		if (CVar.FindCVar("zb_neverdropweapons").GetBool()) {
			return;
		}

		let iter = ThinkerIterator.Create("Weapon");
		
		Weapon w;
		
		while ( w = Weapon(iter.Next()) )
			if ( w != null && w.Owner == self ) {
				Weapon w = Weapon(Spawn(w.GetClass(), Vec3Offset(0, 0, 2)));				
				
				if ( w != null ) {
					w.vel.x = vel.x + FRandom(-5, 5);
					w.vel.y = vel.y + FRandom(-5, 5);
					w.vel.z = vel.z + FRandom(2, 7);
					
					Inventory ammo1 = FindInventory(w.AmmoType1);
					Inventory ammo2 = FindInventory(w.AmmoType2);
					
					w.AmmoGive1 = (ammo1 ? ammo1.Amount : 0);
					w.AmmoGive2 = (ammo2 ? ammo2.Amount : 0);
				}
			}
	}
	
	override void Tick() {
		Super.Tick();
		bMoved = false;
	}
}
