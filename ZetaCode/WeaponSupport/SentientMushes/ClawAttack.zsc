class ClawAttack : Actor
{
    Actor shooter;
    Actor target;
    
    int repeat, interval, curint, mindmg, maxdmg;

    void Attack(int rep, int intr, int mind, int maxd)
    {
        repeat = rep;
        interval = intr;
        mindmg = mind;
        maxdmg = maxd;
        SetState(ResolveState('Attack'));
    }
    
    States
    {
        Spawn:
            TNT1 A -1;
            Stop;
            
        Attack:
            TNT1 A 0 {
                shooter.LineAttack(shooter.angle, 32, 0, FRandom(mindmg, maxdmg), "Punch", "");
                curint = interval;
            }
            TNT1 A 1 {
                if ( curint-- == 0 )
                {
                    if ( repeat-- > 0 )
                        SetState(ResolveState('Attack'));
                        
                    else
                        Destroy();
                }
            }
            Goto Attack + 1;
    }
}