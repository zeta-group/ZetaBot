// 'Projectile' for bullet-based ZetaWeapons

class ZetaBullet : Actor
{
	String bulletColor, puff;
    int currDmg;
    Actor shooter;
	Property BulletColor: bulletColor;
    name damageType;

    const BulletSpeed = 100; // We need the most reasonable possible speed for a bullet while avoiding FastProjectile.

	Default
	{
		Damage (0);
		Speed 0;
		ZetaBullet.BulletColor "Gold";
		Species "ZetaBot";
		+THRUSPECIES
		Projectile;
		Radius 1;
		Height 1;
	}
	
	void SetColor(String col)
	{
		bulletColor = col;
	}

	static ZetaBullet FireABullet(Actor shooter, String bulletColor, Actor target, double damage, double spreadX, double spreadY, name damageType = "bullet", string puff = "BulletPuff", double damage_spread = 0)
	{
		ZetaBullet bullet;

		bullet = ZetaBullet(shooter.SpawnMissileAngle("ZetaBullet", shooter.angle, 0));
		
		if ( bullet != null )
		{
			if (target != null) {
				double vertdiff = target.pos.z + (target.height / 2) - shooter.pos.z;
				Vector2 horzdiff = target.pos.xy - shooter.pos.xy;
	            double vertdist = Abs(vertdiff);
       			double horzdist = sqrt(horzdiff.x * horzdiff.x + horzdiff.y * horzdiff.y);

				// pitch as in angle, not velocity. there, I said it!
				if (target != null && target.Distance2D(shooter) > 0) {
					bullet.pitch = atan2(vertdiff, horzdist);
				}
			}

			else {
				bullet.pitch = shooter.pitch;
			}

			bullet.pitch += FRandom(-spreadY, spreadY);

			bullet.shooter = shooter;
            bullet.damageType = damageType;
			ZetaBullet(bullet).SetColor(bulletColor ? bulletColor : "Gold");
            ZetaBullet(bullet).puff = puff;
		
			bullet.currDmg = Floor(damage + 0.5 + FRandom(-damage_spread, damage_spread));
			bullet.angle += FRandom(-spreadX, spreadX);

			// angle mapping to velocity
			double velspeed = 0;
			
			bullet.vel.x = cos(bullet.angle) * BulletSpeed * cos(bullet.pitch);
			bullet.vel.y = sin(bullet.angle) * BulletSpeed * cos(bullet.pitch);
			bullet.vel.z = sin(bullet.pitch) * BulletSpeed;
		}
			
		return ZetaBullet(bullet);
	}

	static void FireBullets(Actor shooter, String bulletColor, Actor target, double damage, int numBullets, double spreadX, double spreadY, name damageType = "bullet", string puff = "BulletPuff", double damage_spread = 0)
    {
		for ( int i = 0; i < numBullets; i++ )
			FireABullet(shooter, bulletColor, target, damage, spreadX, spreadY, damageType, puff);
	}
	
	States
	{
		Spawn:
			TNT1 A 1;
			/*
			{
                for ( double x = -Speed; x <= 0; x += 10 )
                {
                    Vector3 offs = Vec3Angle(x, angle, tan(pitch) * x);
                    A_SpawnParticle(bulletColor, SPF_FULLBRIGHT, 18, 1.5, 180, offs.x, offs.y, offs.z);
                }
            }
			*/
			Loop;
			
		Death:
			TNT1 A 0
			{
				if ( FRandom(0, 99.9) < 35 )
					A_PlaySound("ztmisc/ricochet", CHAN_BODY, FRandom(0.2, 0.7));
                
                A_SpawnItemEx(puff);
			}
			Stop;
			
		XDeath:
            TNT1 A 0 {
                blockingMobj.DamageMobj(shooter, shooter, currDmg, damageType, 0, angle);
            }
			TNT1 A 0 A_SpawnItemEx("Blood");
			Stop;
	}
}
