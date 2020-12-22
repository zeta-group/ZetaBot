class ZetaCape : Actor
{
	double lastAngle;
	Actor attached;
	
	override void BeginPlay()
	{
		lastAngle = 0;
		attached = null;
	}
	
	double angularVelocity()
	{
		double res = deltaAngle(lastAngle, attached.angle);
		lastAngle = attached.angle;
		
		return res;
	}
	
	static void makeFor(Actor other)
	{
		ZetaCape cape = ZetaCape(Spawn("ZetaCape", other.pos));
		
		if ( cape == null )
            return;
		
		cape.attached = other;
		cape.lastAngle = other.angle;
	}
	
	override void Tick()
	{
		if (attached == null || attached.health <= 0) {
			Destroy();
		}

		else {
			angle = attached.angle;
			scale = (attached.Radius / 25, attached.Height / 70);
			SetOrigin(attached.Vec3Angle(-5, attached.angle, attached.Height), true);
		
			double adiff = angularVelocity();
			
			if ( adiff > 0.16 )
				frame = 1;
				
			else if ( adiff < 0.16 )
				frame = 2;
				
			else
				frame = 0;
		}
	}
	
	Default
	{
		Alpha 0.82;
		Scale 0.7;
	}
	
	States
	{
		Spawn:
			CAPE A -1;
			Stop;
	}
}

class ZTGiveCape : Actor
{
	Default
	{
		Speed 50;
		Damage 0;
		Projectile;
		+BLOODLESSIMPACT;
	}
	
	States
	{
		Spawn:
			TNT1 A 1;
			Loop;
			
		Crash:
		XDeath:
			TNT1 A 0
			{
				ZetaCape.makeFor(blockingMobj);
			}
			Stop;
			
		Death:
			Stop;
	}
}

class ZetaTeamMarker : Actor {
	Default {
		Height 5;
		Radius 5;
		Gravity 0;
		Alpha 0.8;
		Scale 0.5;
		RenderStyle "Shaded";
	}

	Actor attached;

	void SetColor(string Col) {
		SetShade(Col);
	}

	override void Tick() {
		if (attached == null || attached.health <= 0) {
			Destroy();
		}

		else {
			Vector3 newPos = attached.pos;
			newPos.z += attached.Height;
		
			SetOrigin(newPos, true);
		}
	}

	States {
		Spawn:
			ZBTM A -1;
			Stop;
	}
}
