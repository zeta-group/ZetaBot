class ZetaStrife : ZetaBotPawn
{
	Default
	{
		Health 100;
		Radius 18;
		Height 56;
		Mass 100;
		PainChance 255;
		ZetaBotPawn.DefaultInv "PunchDagger";
	}

	bool A_SpeedCheck()
	{
		if ( moveType == MM_CROUCH )
            scale.y = 0.5;
		
		else
            scale.y = 1;
		
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
			PLAY ABCD 3;
			PLAY A 0 A_SpeedCheck;
			Stop;
			
		Missile:
			PLAY E 12 Bright;
			PLAY E 0 A_SpeedCheck;
			Stop;
			
		Pain:
			PLAY Q 4 A_JumpIf(moveType == MM_CROUCH, "CrouchPain");
			PLAY Q 4 A_BotPain;
			PLAY A 0 A_SpeedCheck;
			Stop;
			
		Death:
			PLAY H 3 A_OnDeath;
			PLAY I 3 A_PlaySound("ztmisc/die");
			PLAY J 0 A_NoBlocking;
			PLAY J 3;
			PLAY KLMNO 4;
			PLAY P -1;
			Stop;
			
		XDeath:
            RGIB A 5 {
				A_OnDeath();
				A_TossGib();
			}
            RGIB B 5 A_PlaySound("ztmisc/xdie");
            RGIB C 0;
            RGIB C 5 A_NoBlocking;
            RGIB DEFG 5 A_TossGib;
            RGIB H -1 A_TossGib;
        Disintegrate:
            DISR A 5 A_PlaySound("misc/disruptordeath", CHAN_VOICE);
            DISR BC 5;
            DISR D 5 A_NoBlocking;
            DISR EF 5;
            DISR GHIJ 4;
            MEAT D -1;
            Stop;
        Firehands:
            WAVE ABCD 3;
            Loop;
        Burn:
			BURN A 0 A_OnDeath;
            BURN A 3 Bright A_PlaySound("human/imonfire", CHAN_VOICE);
            BURN B 3 Bright A_DropFire;
            BURN C 3 Bright A_Wander;
            BURN D 0 Bright;
            BURN D 3 Bright A_NoBlocking;
            BURN E 5 Bright A_DropFire;
            BURN FGH 5 Bright A_Wander;
            BURN I 5 Bright A_DropFire;
            BURN JKL 5 Bright A_Wander;
            BURN M 5 Bright A_DropFire;
            BURN N 5 Bright;
            BURN OPQPQ 5 Bright;
            BURN RSTU 7 Bright;
            BURN V -1;
            Stop;
	}
}
