class ZetaSMushes : ZetaBotPawn
{
	Default
	{
		Health 100;
		Radius 16;
		Height 56;
		Mass 100;
		PainChance 255;
		ZetaBotPawn.DefaultInv "WyvernPaw,AIDSGun,FireBreath";
	}

	bool A_SpeedCheck()
	{
		if ( moveType == MM_CROUCH )
		{
			if ( bShooting )
				return SetStateLabel("CrouchMissile");
		
			if ( vel.x * vel.x + vel.y * vel.y > 2 )
				return SetStateLabel("CrouchMove");
				
			return SetStateLabel("CrouchStand");
		}
		
		else
		{
			if ( bShooting )
				return SetStateLabel("Missile");
		
			if ( vel.x * vel.x + vel.y * vel.y > 2 )
				return SetStateLabel("Run");
				
			return SetStateLabel("Stand");
		}
	}

	States
	{
		Spawn:
			DRGN A 1;
			DRGN A 0 A_SpeedCheck;
			Stop;
			
		Stand:
			DRGN A 4;
			DRGN A 0 A_SpeedCheck;
			Stop;
			
		Run:
			DRGN ABCD 3;
			PLAY A 0 A_SpeedCheck;
			Stop;
		
		CrouchStand:
			DRGN A 4;
			DRGN A 0 A_SpeedCheck;
			Stop;
			
		CrouchMove:
			DRGN ABCD 7;
			DRGN A 0 A_SpeedCheck;
			Stop;
			
		Missile:
			DRGN H 8 Bright;
			DRGN H 0 A_SpeedCheck;
			Stop;
			
		CrouchMissile:
			PLYC H 8 Bright;
			PLYC H 0 A_SpeedCheck;
			Stop;
			
		Pain:
            DRGN I 0 A_PlaySound("player/dragon/pain");
			DRGN I 4 A_JumpIf(moveType == MM_CROUCH, "CrouchPain");
			DRGN I 4 A_BotPain;
			PLAY A 0 A_SpeedCheck;
			Stop;
			
		CrouchPain:
			DRGN I 4;
			DRGN I 4 A_BotPain;
			DRGN A 0 A_SpeedCheck;
			Stop;
			
		Death:
			DRGN I 6 A_OnDeath;
			DRGN J 8 A_PlaySound("player/dragon/death");
			DRGN K 9 A_NoBlocking;
			DRGN L 8;
			DRGN N -1;
			Stop;
			
		XDeath:
			TNT1 A 0 {
				A_OnDeath();
				
				string gibClassName = "GibFX";
				class<Actor> gibClass = gibClassName;
				
				if ( gibClass )
					A_SpawnItemEx(gibClass, 0, 0, 32);
			}
			BDPL A 0 A_NoBlocking;
			BDPL A 0 A_NoBlocking;
			BDPL A 0;
			BDPL A -1;
            Stop;
	}
}
