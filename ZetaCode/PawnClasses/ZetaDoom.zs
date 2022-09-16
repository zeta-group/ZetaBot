class ZetaDoom : ZetaBotPawn
{
	Default
	{
		ZetaBotPawn.DefaultInv "Fist,Pistol,Clip";
		ZetaBotPawn.ColorRangeStart 112;
		ZetaBotPawn.ColorRangeEnd 127;
	}

	bool A_SpeedCheck()
	{
		if ( moveType == MM_CROUCH )
		{
			Height = Default.Height / 2;

			if ( bShooting )
				return SetStateLabel("CrouchMissile");
		
			if ( vel.x * vel.x + vel.y * vel.y > 2 )
				return SetStateLabel("CrouchMove");
				
			return SetStateLabel("CrouchStand");
		}
		
		else
		{
			Height = Default.Height;

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
			TNT1 A 1;
			TNT1 A 0 A_SpeedCheck;
			Stop;
			
		Stand:
			PLAY A 4;
			PLAY A 0 A_SpeedCheck;
			Stop;
			
		Run:
			PLAY ABCD 3;
			PLAY A 0 A_SpeedCheck;
			Stop;
		
		CrouchStand:
			PLYC A 4;
			PLYC A 0 A_SpeedCheck;
			Stop;
			
		CrouchMove:
			PLYC ABCD 7;
			PLYC A 0 A_SpeedCheck;
			Stop;
			
		Missile:
			PLAY F 4 Bright;
			PLAY F 0 A_SpeedCheck;
			Stop;
			
		CrouchMissile:
			PLYC F 4 Bright;
			PLYC F 0 A_SpeedCheck;
			Stop;
			
		Pain:
			PLAY G 4 A_JumpIf(moveType == MM_CROUCH, "CrouchPain");
			PLAY G 4 A_BotPain;
			PLAY A 0 A_SpeedCheck;
			Stop;
			
		CrouchPain:
			PLYC G 4;
			PLYC G 4 A_BotPain;
			PLYC A 0 A_SpeedCheck;
			Stop;
			
		Death:
			PLAY H 10 A_OnDeath;
			PLAY I 10 A_PlaySound("ztmisc/die");
			PLAY J 0 A_NoBlocking;
			PLAY J 10;
			PLAY KLM 10;
			PLAY N -1;
			Stop;
			
		XDeath:
			PLAY O 5 A_OnDeath;
			PLAY P 5 A_PlaySound("ztmisc/xdie");
			PLAY Q 0 A_NoBlocking;
			PLAY Q 5;
			PLAY RSTUV 5;
			PLAY W -1;
	}
}
