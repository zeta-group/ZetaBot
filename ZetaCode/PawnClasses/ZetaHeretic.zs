class ZetaHeretic : ZetaBotPawn
{
	Default
	{
		ZetaBotPawn.DefaultInv "GoldWand,Staff,GoldWandAmmo";
	}

	bool A_SpeedCheck()
	{
		if ( moveType == MM_CROUCH )
			scale.y = 0.8;

		else
			scale.y = 1.0;
		
		if ( bShooting )
			return SetStateLabel("Missile");
	
		if ( vel.x * vel.x + vel.y * vel.y > 2 )
			return SetStateLabel("Run");
			
		return SetStateLabel("Stand");
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
			PLAY ABCD 4;
			PLAY A 0 A_SpeedCheck;
			Stop;

		Missile:
			PLAY F 6 Bright;
			PLAY E 12;
			PLAY F 0 A_SpeedCheck;
			Stop;
			
		Pain:
			PLAY G 4 A_JumpIf(moveType == MM_CROUCH, "CrouchPain");
			PLAY G 4 A_BotPain;
			PLAY G 0 A_SpeedCheck;
			Stop;
			
		Death:
			PLAY I 0 A_OnDeath;
			PLAY I 6 A_PlaySound("ztmisc/heretic/die");
			PLAY JK 6;
			PLAY L 6 A_NoBlocking;
			PLAY MNO 6;
			PLAY P -1;
			Stop;

		Burn:
			FDTH A 0 A_OnDeath;
			FDTH A 5 Bright A_PlaySound("ztmisc/heretic/burndie");
			FDTH B 4 Bright;
			FDTH C 5 Bright;
			FDTH D 4 Bright A_PlaySound("ztmisc/heretic/die");
			FDTH E 5 Bright;
			FDTH F 4 Bright;
			FDTH G 5 Bright A_PlaySound("ztmisc/heretic/burndie");
			FDTH H 4 Bright;
			FDTH I 5 Bright;
			FDTH J 4 Bright;
			FDTH K 5 Bright;
			FDTH L 4 Bright;
			FDTH M 5 Bright;
			FDTH N 4 Bright;
			FDTH O 5 Bright A_NoBlocking;
			FDTH P 4 Bright;
			FDTH Q 5 Bright;
			FDTH R 4 Bright;
			ACLO E -1;
			Stop;
			
		XDeath:
			PLAY Q 0 A_OnDeath;
			PLAY Q 5 A_PlaySound("ztmisc/heretic/xdie");
			PLAY R 0 A_NoBlocking;
			PLAY R 5 A_SkullPop;
			PLAY STUVWX 5;
			PLAY Y -1;
			Stop;
	}
}
