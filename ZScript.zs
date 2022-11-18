version "2.5"

#include "ZetaCode/Standard.zs"
#include "ZetaCode/Pathing.zs"
#include "ZetaCode/Appearance.zs"

// Weapon Modules
#include "ZetaCode/WeaponSupport/ZetaWeapon.zs"
#include "ZetaCode/WeaponSupport/ZetaBullet.zs"
#include "ZetaCode/WeaponSupport/ZetaWeaponModule.zs"
#include "ZetaCode/WeaponSupport/ZetaDoomWeapons.zs"
#include "ZetaCode/WeaponSupport/ZetaStrifeWeapons.zs"
#include "ZetaCode/WeaponSupport/ZetaHereticWeapons.zs"
#include "ZetaCode/WeaponSupport/ZetaSMWeapons.zs"

// Pawn Modules
#include "ZetaCode/PawnClasses/ZetaBotPawn.zs"
#include "ZetaCode/PawnClasses/ZetaDoom.zs"
#include "ZetaCode/PawnClasses/ZetaHeretic.zs"
#include "ZetaCode/PawnClasses/ZetaStrife.zs"
#include "ZetaCode/PawnClasses/ZetaSMushes.zs"


class LineCrossTracer : LineTracer {
	Array<Line> crossLines;

	override ETraceStatus TraceCallback() {
		if (results.HitType == TRACE_HitWall && results.HitLine.sidedef[1] && results.HitLine.activation & (SPAC_Cross | SPAC_AnyCross)) {
			crossLines.push(results.HitLine);
		}

		return TRACE_Skip;
	}
}

mixin class ActorName {
	string ActorName(Actor Other) {
		if (!Other) {
			return "";
		}

		if (ZetaBotPawn(Other)) {
			ZTBotController cont = ZetaBotPawn(Other).cont;

			if (cont) return cont.myName;
		}

		if (PlayerPawn(Other) && playeringame[Other.PlayerNumber()]) {
			return players[Other.PlayerNumber()].GetUserName();
		}

		return "a "..Other.GetClassName();
	}
}

mixin class DebugLog {
	enum LogType {
		LT_ERROR = 0,
		LT_WARNING,
		LT_INFO,
		LT_VERBOSE
	};

	Actor myself;

	void DebugLog(LogType kind, String msg) {
		myself = Actor(self);

		if (!myself) { return; }

		if (CVar.FindCVar("zb_debug").GetInt() > 0) {
			String logHeader = "";

			if (kind == LT_ERROR)
				logHeader = "\cr[ERROR]";

			else if (kind == LT_WARNING)
				logHeader = "\cf[WARNING]";

			else if (kind == LT_INFO)
				logHeader = "\ch[INFO]";

			else if (kind == LT_VERBOSE) {
				if (CVar.FindCVar("zb_debug").GetInt() > 1)
					logHeader =	"\cd[VERBOSE]";

				else
					return;
			}

			myself.A_Log("\cq[ZetaBot] "..logHeader.." "..msg);
		}
	}

}

class ZTBotOrder play {
	Actor orderer;
	Actor lookedAt;
	String v_imperative, v_past, v_continuous;
	uint orderType;

	static const String BStateImperative[] = {
		"wander",
		"hunt",
		"attack",
		"follow",
		"flee"
	};

	static const String BStatePast[] = {
		"wandered",
		"hunted",
		"attacked",
		"followed",
		"fled"
	};

	static const String BStateContinuous[] = {
		"wandering",
		"hunting",
		"attacking",
		"following",
		"chickening"
	};

	void Apply(ZTBotController bot) {
		if (lookedAt == null && orderType != ZTBotController.BS_WANDERING) {
			bot.DebugLog(ZTBotController.LT_WARNING, "Can't apply non-wander order without a target!");
			return;
		}

		if (lookedAt == bot.possessed) {
			bot.DebugLog(ZTBotController.LT_WARNING, String.format("Can't order one to %s oneself!", BStateImperative[orderType]));
			return;
		}

		bot.commander = orderer;
		bot.goingAfter = lookedAt;

		if (orderType == ZTBotController.BS_ATTACKING || orderType == ZTBotController.BS_HUNTING) {
			bot.enemy = lookedAt;
			bot.lastEnemy = lookedAt;
		}

		if (bot.lastEnemyPos != null) {
			bot.lastEnemyPos.Destroy();
			bot.lastEnemyPos = null;
		}

		bot.SetOrder(self);
	}

	void UpdateOrder(Actor i_orderer, Actor i_lookedAt, uint i_orderType) {
		orderer = i_orderer;
		lookedAt = i_lookedAt;
		orderType = i_orderType;

		v_imperative = ZTBotOrder.BStateImperative[i_orderType];
		v_past = ZTBotOrder.BStatePast[i_orderType];
		v_continuous = ZTBotOrder.BStateContinuous[i_orderType];
	}

	static ZTBotOrder Make(Actor i_orderer, Actor i_lookedAt, uint i_orderType) {
		ZTBotOrder res = ZTBotOrder(new("ZTBotOrder"));

		if (i_orderer) {
			res.UpdateOrder(i_orderer, i_lookedAt, i_orderType);
		}

		return res;
	}
}

class ZTBotOrderCode: Actor {
	// Sets all bots in a 300 units radius
	// to be of an order of a specific type.

	enum SubjectType {
		ST_LOOKED,
		ST_SELF,
		ST_NOORDER
	};

	SubjectType mySubject;
	uint orderType;
	PlayerPawn Owner;

	property OrderType: orderType;
	property SubjectType: mySubject;

	default {
		ZTBotOrderCode.SubjectType ST_LOOKED;
		ZTBotOrderCode.OrderType ZTBotController.BS_FOLLOWING;

		Gravity 0;
		Scale 0.5;
		Height 2;
		Radius 2;
		Alpha 0.75;
		RenderStyle "Shaded";
		StencilColor "A810EC";
	}

	Actor FindLookedAt() {
		FLineTraceData td;

		Owner.LineTrace(
			Owner.angle,
			Owner.radius + 512,
			0,
			flags: TRF_THRUBLOCK | TRF_THRUHITSCAN,
			offsetz: Owner.height - 24,
			data: td
		);

		return td.hitActor;
	}

	Actor FindSubject() {
		switch (mySubject) {
			case ST_LOOKED:
				return FindLookedAt();

			case ST_SELF:
			case ST_NOORDER:
				return Owner;
		}

		return null;
	}

	void FindOwner() {
		ThinkerIterator ownIter = ThinkerIterator.Create("PlayerPawn", STAT_PLAYER);
		PlayerPawn pp;

		while (pp = PlayerPawn(ownIter.Next())) {
			if (Owner == null || pp.Distance3D(self) < Owner.Distance3D(self)) {
				if (pp.player) {
					Owner = pp;
				}
			}
		}
	}

	ZTBotOrder ConcoctOrder(Actor subject) {
		if (mySubject != ST_NOORDER) {
			return ZTBotOrder.Make(Owner, subject, orderType);
		}

		return null;
	}

	int GiveOrder(Actor subject) {
		let order = ConcoctOrder(subject);

		ThinkerIterator botIter = ThinkerIterator.Create("ZetaBotPawn", STAT_DEFAULT);
		ZetaBotPawn zbp;
		int howMany = 0;

		while ((zbp = ZetaBotPawn(botIter.Next()))) {
			ZTBotController cont = zbp.cont;

			if (cont == null) {
				continue;
			}

			if ((
				(cont.commander == null && mySubject != ST_NOORDER)
				|| cont.commander == Owner
				|| Owner is "PlayerPawn"
			) && zbp.Distance2D(owner) < owner.radius + zbp.radius + 300 && !zbp.cont.IsEnemy(zbp, owner) && zbp.CheckSight(owner)) {
				if (order != null) {
					order.Apply(cont);
				}

				else {
					cont.SetOrder(order);
				}

				howMany++;
			}
		}

		return howMany;
	}

	override void PostBeginPlay() {
		Super.PostBeginPlay();

		SetXYZ(pos + Vec3Angle(-56, angle));

		FindOwner();

		if (Owner) {
			Vector3 newPos = Owner.pos + Vec3Angle(10, Owner.angle);
			newPos.z += Owner.Height * 0.75;

			SetOrigin(newPos, false);
		}
	}

	void A_GiveBotOrder() {
		if (Owner == null) {
			A_Log(String.Format("\cwCould not find owner to give \cb%s\cw order", ZTBotOrder.BStateImperative[orderType]));
			return;
		}

		// Find subject of the order
		let subject = FindSubject();

		if (subject == null && orderType != ZTBotController.BS_WANDERING) {
			A_Log(String.Format("\cwCould not find looked-at subject to give \cb%s\cw order", ZTBotOrder.BStateImperative[orderType]));
			return;
		}

		// Make order and give it to all bots in radius
		int howMany = GiveOrder(subject);

		if (howMany > 0) {
			string status = "\cwGiven \cb%s\cw order to \cb%i\cw people";
			A_Log(String.Format(status, ZTBotOrder.BStateImperative[orderType], howMany));
		}

		else {
			string status = "\cb%s\cw order could not reach anyone";
			A_Log(String.Format(status, ZTBotOrder.BStateImperative[orderType]));
		}
	}

	States {
		Spawn:
			PLSS C 1;
			PLSS C 3 A_GiveBotOrder;
			PLSS BC 3;
			Stop;
	}
}

class ZTBotAttackOrder : ZTBotOrderCode {
	Default {
		ZTBotOrderCode.OrderType 2; // ZetaBotPawn.BS_ATTACKING;
	}
}

class ZTBotWanderOrder : ZTBotOrderCode {
	Default {
		ZTBotOrderCode.OrderType 0; // ZetaBotPawn.BS_WANDERING;
	}
}

class ZTBotFleeOrder : ZTBotOrderCode {
	Default {
		ZTBotOrderCode.OrderType 4; // ZetaBotPawn.BS_FLEEING;
	}
}

class ZTBotFollowOrder : ZTBotOrderCode {
	Default {
		ZTBotOrderCode.OrderType 3; // ZetaBotPawn.BS_FOLLOWING;
	}
}

class ZTBotFollowMeOrder : ZTBotFollowOrder {
	Default {
		ZTBotOrderCode.SubjectType 1; // ZTBotOrderCode.ST_SELF
	}
}

class ZTBotVacateOrder : ZTBotOrderCode {
	// Vacate bots around of any orders.
	Default {
		ZTBotOrderCode.SubjectType 2; // ZTBotOrderCode.ST_NOORDER
	}
}

/*
class ZTLineUseHistoryEntry {
	Line Used;
	double When; // zetabot age in seconds
}
*/

class DestBall : PlasmaBall {
	Actor targetNode;

	void A_BallTick() {
		Vector2 offs = Vec2To(targetNode);
		offs.x /= Distance2D(targetNode);
		offs.y /= Distance2D(targetNode);

		Vector2 vel = AngleToVector(angle);

		if (Distance3D(targetNode) < 72 || (offs.x * vel.x) + (offs.y * vel.y) < 0)
			SetStateLabel("Death");
	}

	Default {
		Damage 0;
	}

	States {
		Spawn:
			PLSS AB 6 A_BallTick;
			Loop;
	}
}

class WeaponRating : Actor {
	double rating;
	bool bAlt;

	override void BeginPlay() {
		rating = 0;
		bAlt = false;
	}
}

class NumBots : Thinker {
	uint value;
	uint counter;

	NumBots Init() {
		ChangeStatNum(STAT_INFO);
		value = 0;
		return self;
	}

	static uint Count() {
		return Get().counter++;
	}

	static NumBots Get() {
		ThinkerIterator it = ThinkerIterator.Create("NumBots", STAT_INFO);
		let p = NumBots(it.Next());

		if (p == null)
			p = new("NumBots").Init();

		return p;
	}
}

class ZTBotController : Actor {
	bool frozen;

	enum BotState {
		BS_WANDERING = 0,
		BS_HUNTING,
		BS_ATTACKING,
		BS_FOLLOWING,
		BS_FLEEING
	};

	mixin DebugLog;
	mixin ActorName;

	int frags;
	int kills;
	float imprecision;
	float maxAngleRate;
	ZetaBotPawn possessed;
	ZetaWeapon lastWeap;
	BotState bstate;
	ZTPathNode navDest;
	Actor goingAfter;
	Actor enemy;
	Actor commander;
	ZTPathNode currNode;
	double strafeMomentum;
	double angleMomentum;
	ZTPathNode lastEnemyPos;
	Vector3 currSeeNodePos;
	Vector3 currEnemyPos;
	double age;
	uint GruntInterval;
	uint logRate;
	uint BotID;
	uint TelefragTimer;
	bool initialized;
	ZetaTeamMarker teamMarker;
	double blocked;
	double averageSpeed;
	uint speedRemaining;
	Vector3 lastPos;
	ZTPathNode pastNode;
	int myVoice;
	uint index;
	double lastShot;
	ZetaWeaponModule loader;
	String myName;
	uint numShoots;
	uint pathCountdown;
	uint retargetCount;
	//Array<ZTLineUseHistoryEntry> UseHistory;

	bool AutoUseAtAngle(double angle) {
		FLineTraceData td;

		possessed.LineTrace(
			possessed.angle + angle,
			possessed.radius + 64,
			0,
			flags: TRF_THRUBLOCK | TRF_THRUHITSCAN | TRF_THRUACTORS | TRF_BLOCKUSE,
			offsetz: possessed.height - 24,
			data: td
		);

		if (td.HitType != TRACE_HitWall)
			return false;

		if (td.HitLine.Special == 0) {
			if (GruntInterval == 0 || GruntInterval-- == 0) {
				possessed.A_PlaySound("ztmisc/grunt", CHAN_VOICE, attenuation: 1.1);
				GruntInterval = 20;
				Log(GruntInterval);

				/*
				if (currNode) {
					MoveAwayFrom(currNode);
					MoveAwayFrom(currNode);
				}
				*/
			}

			return false;
		}

		/*
		for (let i = 0; i < UseHistory.Size(); i++) {
			if (UseHistory[i].Used == td.HitLine && age - UseHistory[i].When < CVar.FindCVar('zb_autouseinterval').GetFloat())
				return false;

			else if (age - UseHistory[i].When >= CVar.FindCVar('zb_autouseinterval').GetFloat())
				UseHistory.Delete(i--);
		}
		*/

		Line l = td.HitLine;
		DebugLog(LT_VERBOSE, "["..myName.." USE NODE LOGS] Auto-activating wall! Line special: "..l.Special);
		l.Activate(possessed, 0, SPAC_Use);

		Level.ExecuteSpecial(
			l.Special,
			possessed,
			l, 0,

			l.Args[0],
			l.Args[1],
			l.Args[2],
			l.Args[3],
			l.Args[4]
		);

		if (CVar.FindCVar('zb_autonodes').GetBool() && CVar.FindCVar('zb_autonodeuse').GetBool() && currnode.NodeType != ZTPathNode.NT_USE) {
			SetCurrentNode(ZTPathNode.plopNode(pos, ZTPathNode.NT_USE, possessed.angle));
			currNode.Angle = Angle;
		}

		/*
		ZTLineUseHistoryEntry entry = new("ZTLineUseHistoryEntry");

		entry.Used = td.HitLine;
		entry.When = age;

		UseHistory.Push(entry);
		*/

		return true;
	}

	override void BeginPlay() {
		super.BeginPlay();

		GruntInterval = 0;
		TelefragTimer = 17;

		imprecision = CVar.GetCVar("zb_aimstutter").GetFloat();
		maxAngleRate = CVar.GetCVar('zb_turnspeed').GetFloat();

		debugCount = 0;
		retargetCount = 8;
		NumBots.Get().value++;
		BotID = NumBots.Count();

		loader = ZetaWeaponModule(Spawn("ZetaWeaponModule"));

		Array<String> wmodules;
		let tp = CVar.FindCVar("zb_wtypes").GetString();
		tp.Split(wmodules, ";");

		for (int i = 0; i < wmodules.Size(); i++) {
			ZetaWeaponModule zwm = ZetaWeaponModule(Spawn(wmodules[i]));
			uint oldLoaded = loader.weaponsLoaded.Size();
			loader.LoadModule(zwm);
			DebugLog(LT_VERBOSE, String.Format("Loaded weapons module: %s (%i weapons)", zwm.GetClassName(), loader.weaponsLoaded.Size() - oldLoaded));
		}

		let ptype = ZetaBotPawn.GetSomeType();

		if (ptype == "") {
			DebugLog(LT_ERROR, "No plausible pawn type found!");
			Destroy();
			return;
		}

		else {
			DebugLog(LT_INFO, String.Format("Type chosen: %s", ptype));
			SetPossessed(ZetaBotPawn(Spawn(ptype, pos)));

			// Telefrag overlaps
			let telefragIter = ThinkerIterator.Create("Actor", STAT_DEFAULT);
			Actor mon = null;

			while (mon = Actor(telefragIter.Next())) {
				if (mon.Distance2D(possessed) <= mon.Radius + possessed.Radius && mon != possessed) {
					if (ZetaBotPawn(mon) == null || ZetaBotPawn(mon).cont == null || ZetaBotPawn(mon).cont.TelefragTimer == 0) {
						uint tries = 20; // for things that absorb less damage
						uint damage = mon.Health;

						for (; tries > 0 && mon.Health > 0; tries--)
							mon.DamageMobj(possessed, possessed, damage, 'Telefrag', DMG_NO_ARMOR | DMG_NO_PROTECT);
					}
				}
			}
		}

		myVoice = Random(1, 4);
		logRate = 150;

		Array<String> botNames;
		CVar.FindCVar('zb_names').GetString().Split(botNames, ',');

		myName = botNames[Random(0, botNames.Size() - 1)];

		SetTeam(PickTeam(CVar.FindCVar("teamplay").GetInt() >= 1));
	}

	void PlayPain() {
		if (Health > 0)
			BotChat("HURT", 0.7);
	}

	void aimToward(Actor other, double speed, double threshold = 5) {
		aimAtAngle(possessed.AngleTo(other), speed, threshold);
	}

	void aimAtAngle(double angle, double speed, double randRange = 3, double threshold = 5) {
		randRange *= imprecision;
		possessed.angle += DeltaAngle(possessed.angle, angle) * speed / 35.0 + FRandom(-randRange, randRange) / (35.0 + AbsAngle(possessed.angle, angle) / 15);
		angleMomentum += (angle - possessed.angle) / 3.0;
	}

	void AimAwayFrom(Actor other, double speed, double threshold = 5) {
		AimAtAngle(-possessed.AngleTo(other), speed, threshold);
	}

	Class<ZetaBotPawn> possessedType;

	void A_ZetaRespawn() {
		if (possessedType == null) return;

		ZTPathNode pn, chosen = null;
		double chanceDenom = 1;
		uint found = 0;

		// Find a pathnode where to respawn at

		let iter = ThinkerIterator.Create("ZTPathNode", 91);

		while ((pn = ZTPathNode(iter.Next()))) {
			if (pn.nodeType == ZTPathNode.NT_RESPAWN || (CVar.FindCVar("zb_anynoderespawn").GetBool() && pn.nodeType != ZTPathNode.NT_USE && pn.nodeType != ZTPathNode.NT_AVOID)) {
				if (possessed) {
					pn.A_SetSize(possessed.Radius, possessed.Height);

					if (pn.CheckBlock()) {
						pn.A_SetSize(pn.default.Radius, pn.default.Height);
						continue;
					}
				}

				double prob = FRandom(0, chanceDenom);

				if (prob <= 1.0) {
					chosen = pn;
				}

				// DebugLog(LT_VERBOSE, String.format("Node %i at x=%f,y=%f has luck value %f/%f.", ++found, pn.pos.x, pn.pos.y, 0 - prob, chanceDenom));

				chanceDenom++;
			}
		}

		if (chosen == null) return;

		// Perform the respawn
		Vector3 spawnPos = chosen.pos;
		spawnPos.x += FRandom(-16, 16);
		spawnPos.y += FRandom(-16, 16);

		SetPossessed(ZetaBotPawn(Spawn(possessedType, spawnPos)));
		possessed.angle = chosen.angle;
		SpawnTeleportFog(spawnPos, false, false);

		// Telefrag things
		let telefragIter = ThinkerIterator.Create("Actor", STAT_DEFAULT);
		Actor mon = null;

		while (mon = Actor(telefragIter.Next())) {
			if (mon.Distance2D(chosen) <= mon.Radius + possessed.Radius && mon != possessed) {
				uint tries = 20; // for things that absorb less damage
				uint damage = mon.Health;

				for (; tries > 0 && mon.Health > 0; tries--)
					mon.DamageMobj(possessed, possessed, damage, 'Telefrag', DMG_NO_ARMOR | DMG_NO_PROTECT);
			}
		}

		TelefragTimer = 17;

		DebugLog(LT_VERBOSE, String.format("%s respawned!", myName));

		RespawnReset();
	}

	void RespawnReset() {
		commander = null;
		navDest = null;
		age = 0;
		frozen = false;
		lastShot = -9999;
		numShoots = 0;
		navDest = null;
		bstate = BS_WANDERING;
		goingAfter = null;
		currNode = null;
		enemy = null;
		commander = null;
		strafeMomentum = 0;
		angleMomentum = 0;
		blocked = 0;
		averageSpeed = 0;
		speedRemaining = 87;
		pastNode = null;
		initialized = true;
	}

	const numTeams = 8;

	static const String teamNames[/* 8 */] = {
		// for deathmatch or teamplay
		"Blue",
		"Red",
		"Green",
		"Gold", // yellow
		"Black",
		"White",
		"Orange",
		"Purple"
	};

	bool IsSameTeam(Actor Other) {
		if (PlayerPawn(Other)) {
			PlayerInfo player = players[Other.PlayerNumber()];
			return teamNames[myTeam] == Teams[player.GetTeam()].mname;
		}

		if (ZetaBotPawn(Other)) {
			ZTBotController cont = ZetaBotPawn(Other).cont;

			return cont && cont.myTeam == myTeam;
		}

		return false;
	}

	// 3 per team
	static const float teamColors[/* 24 */] = {
		0.1, 0.1, 1.0,
		1.0, 0.1, 0.1,
		0.1, 1.0, 0.1,
		0.9, 0.8, 0.1,
		0.2, 0.2, 0.25,
		0.95, 0.95, 0.9,
		0.9, 0.4, 0.1,
		0.7, 0.1, 0.8
	};

	static const String teamColorsHex[/* 8 */] = {
		"0804F0",
		"F00804",
		"08F004",
		"F0E004",
		"101016",
		"F4F4EC",
		"E87018",
		"C820E8"
	};

	int myTeam;

	void SetTeam(int team) {
		myTeam = team % numTeams % CVar.FindCVar("zb_maxteams").GetInt();

		int tcolind = myTeam * 3;

		possessed.SetColor(teamColors[tcolind], teamColors[tcolind + 1], teamColors[tcolind + 2]);

		if (teamMarker) {
			teamMarker.SetColor(teamColorsHex[myTeam]);
		}
	}

	int PickBalancedTeams(bool bCVarCap) {
		int upperCap = bCVarCap ? (CVar.FindCVar("zb_maxteams").GetInt()) : numTeams;

		Array<int> teamCounts;

		for (uint i = 0; i < numteams; i++) {
			teamCounts.Push(0);
		}

		ThinkerIterator iter   = ThinkerIterator.Create("ZetaBotPawn", STAT_DEFAULT);
		ThinkerIterator iter2  = ThinkerIterator.Create("PlayerPawn", STAT_PLAYER);

		ZetaBotPawn zbp;
		PlayerPawn pp;

		while (zbp = ZetaBotPawn(iter.Next())) {
			if (zbp.cont && zbp.cont != self) {
				teamCounts[zbp.cont.myTeam]++;
			}
		}

		while (pp = PlayerPawn(iter2.Next())) {
			if (pp.player && pp.player.GetTeam() != 255) {
				teamCounts[pp.player.GetTeam()]++;
			}
		}

		int lowest = -1;

		Array<int> needyTeams;

		for (int i = 0; i < upperCap; i++) {
			if (lowest == -1 || teamCounts[i] < lowest) {
				needyTeams.Clear();
				lowest = teamCounts[i];
			}

			if (teamCounts[i] == lowest) {
				needyTeams.Push(i);
			}
		}

		String needyTeamsLog = "Needy teams: ";

		for (int i = 0; i < needyTeams.Size(); i++) {
			needyTeamsLog.AppendFormat("%s%s", teamNames[needyTeams[i]], i < (needyTeams.size() - 1) ? ", " : "");
		}

		DebugLog(LT_VERBOSE, needyTeamsLog);

		return needyTeams[Random(0, needyTeams.Size() - 1)];
	}

	int PickTeam(bool bCVarCap) {
		if (CVar.FindCVar("zb_balanceteams").GetBool()) {
			return PickBalancedTeams(bCVarCap);
		}

		return Random(0, bCVarCap ? (CVar.FindCVar("zb_maxteams").GetInt() - 1) : numTeams - 1);
	}

	void SetPossessed(ZetaBotPawn other) {
		if (!other) {
			return;
		}

		DebugLog(LT_INFO, myName.." has possessed a "..other.GetClassName().."!");

		possessed = other;
		possessedType = possessed.GetClass();
		possessed.cont = self;

		currSeeNodePos = possessed.pos;

		if (CVar.FindCVar("zb_cape").GetBool()) {
			ZetaCape.MakeFor(other);
		}

		if (CVar.FindCVar("deathmatch").GetInt() > 0) {
			other.bFRIENDLY = false;
		}

		RespawnReset();
	}

	void MoveToward(Actor other, double aimSpeed) {
		AimToward(other, aimSpeed);
		MoveForward();

		if (possessed.AngleTo(other) > possessed.Angle - 20)
			MoveRight();

		else if (possessed.Angle + 20 < possessed.AngleTo(other))
			MoveLeft();

		else
			MoveForward();
	}

	void MoveTowardPos(Vector3 other, double aimSpeed) {
		double ang = atan2(possessed.pos.y - other.y, possessed.pos.x - other.x);

		AimAtAngle(ang, aimSpeed);
		MoveForward();

		if (ang > possessed.Angle - 20)
			MoveRight();

		else if (possessed.Angle + 20 < ang)
			MoveLeft();

		else
			MoveForward();
	}

	void MoveRight() {
		possessed.MoveRight();
	}

	void MoveLeft() {
		possessed.MoveLeft();
	}

	void MoveAwayFrom(Actor other) {
		possessed.MoveForward();
		AimAwayFrom(other, 35);
	}

	void StepBackFrom(Actor other) {
		possessed.MoveBackward();
		AimToward(other, 20);
	}

	void StepBack() {
		possessed.StepBackward();
	}

	bool CheckObstructions() {
		FLineTraceData leftfront;
		FLineTraceData rightfront;
		FLineTraceData front;

		possessed.LineTrace(possessed.angle, 32, possessed.pitch, flags: TRF_THRUSPECIES | TRF_THRUHITSCAN, offsetz: 24, data: front);
		possessed.LineTrace(possessed.angle - 60, 120, possessed.pitch, flags: TRF_THRUSPECIES | TRF_THRUHITSCAN, offsetz: 24, data: leftfront);
		possessed.LineTrace(possessed.angle + 60, 120, possessed.pitch, flags: TRF_THRUSPECIES | TRF_THRUHITSCAN, offsetz: 24, data: rightfront);

		int flags = 0;

		if (leftfront.HitType != TRACE_HitNone)
			flags |= 0x1;

		if (rightfront.HitType != TRACE_HitNone)
			flags |= 0x2;

		if (front.HitType != TRACE_HitNone)
			flags |= 0x4;

		if (flags & 0x4) {
			if (flags & 0x3 == 0x3 || leftfront.Distance + rightfront.Distance < 80)
				possessed.MoveBackward();

			else if (flags & 0x1)
				possessed.angle += 5;

			else if (flags & 0x2)
				possessed.angle -= 5;
		}

		return flags & 0x4 != 0;
	}

	ActorList VisibleEnemies(Actor from) {
		ActorList res		   = new("ActorList");
		ThinkerIterator iter   = ThinkerIterator.Create("Actor", STAT_DEFAULT);
		ThinkerIterator iter2  = ThinkerIterator.Create("Actor", STAT_PLAYER);
		Actor cur			   = null;

		while (true) {
			if (!(cur = Actor(iter.Next())))
				if (!(cur = Actor(iter2.Next())))
					break;

			if (cur == null || cur == from) {
				continue;
			}

			if (!(cur.bISMONSTER || cur.CheckClass("PlayerPawn", match_superclass: true))) {
				continue;
			}

			if (cur.Health <= 0) {
				continue;
			}

			if (cur.bInvisible) {
				continue;
			}

			if (!(from.CheckSight(cur) && LineOfSight(cur, from))) {
				continue;
			}

			if (!IsEnemy(from, cur)){
				continue;
			}

			res.Push(cur);
		}

		return res;
	}

	ActorList VisibleFriends(Actor from, bool allAround = false) {
		ActorList res		  = new("ActorList");
		ThinkerIterator iter  = ThinkerIterator.Create("Actor", STAT_DEFAULT);
		Actor cur			  = null;

		while (cur = Actor(iter.Next())) {
			if (!cur) {
				continue;
			}

			if (cur == from) {
				continue;
			}

			if (cur.Health <= 0) {
				continue;
			}

			if (!(from.CheckSight(cur) && (allAround || LineOfSight(cur)))) {
				continue;
			}

			if (IsEnemy(from, cur)) {
				continue;
			}

			res.Push(cur);
		}

		return res;
	}

	uint debugCount;

	bool MoveTowardDest() {
		Actor dest = navDest;

		if (!dest) {
			dest = goingAfter;
		}

		if (!dest) {
			dest = enemy;
		}

		if (!dest) {
			return false;
		}

		// MakeDestBall(dest);
		MoveToward(dest, 10);
		return true;
	}

	void MakeDestBall(Actor Other) {
		if (CVar.FindCVar("zb_debug").GetInt() > 0 && debugCount < 1) {
			debugCount = 20;
			DestBall db = DestBall(possessed.SpawnMissile(Other, "DestBall"));

			if (db)
				db.targetNode = Other;
		}
	}

	void SmartMove(ZTPathNode toward = null) {
		if (toward == null) toward = navDest;
		if (toward == null || !possessed.CheckSight(toward)) toward = currNode;

		if (currNode && currNode.nodeType == ZTPathNode.NT_USE)
			DodgeAndUse();

		if (toward) {
			if (currNode) {
				if (toward.nodeType == ZTPathNode.NT_JUMP) {
					aimToward(toward, 0.1, 0.1);

					if (possessed.pos.z - possessed.floorz < 1)
						possessed.Jump();
				}

				else if (toward.nodeType == toward.NT_CROUCH)
					possessed.moveType = ZetaBotPawn.MM_Crouch;

				else if (toward.nodeType == toward.NT_SLOW) {
					possessed.moveType = ZetaBotPawn.MM_None;
				}

				else {
					possessed.moveType = ZetaBotPawn.MM_Run;
				}

				if (toward.pos.z - possessed.pos.z > 28 && possessed.pos.z - possessed.floorz < 1) {
					possessed.Jump();
				}

				if (currNode.nodeType == ZTPathNode.NT_USE) {
					DodgeAndUse();
				}

				else if (currNode.nodeType == ZTPathNode.NT_SHOOT && enemy == null) {
					AimAtAngle(currNode.angle, 20);

					if (FRandom(0, 1) < 0.7 && FireBestWeapon()) {
						possessed.BeginShoot();
					}

					else {
						possessed.EndShoot();
					}
				}

				MoveToward(toward, 20);
			}

			else
				MoveToward(toward, 20);
		}

		else {
			angleMomentum += FRandom(-0.01, 0.01);
		}

			if (FRandom(0, 99.9) < 10)
				RandomStrafe();

			else
				MoveForward();

		if (bstate == BS_WANDERING && FRandom(0, 99.9) < 10) {
			RandomMove();
			RandomStrafe();
		}
	}

	void MoveForward() {
		possessed.MoveForward();
	}

	static const String BStateNames[] = {
		"wandering",
		"hunting",
		"attacking",
		"following",
		"fleeing"
	};

	void SetBotState(uint s) {
		//if (currentOrder)
		//	  SetOrder(null);

		if (s != bstate) {
			if (lastEnemyPos != nulL) {
				lastEnemyPos.Destroy();
			}
	
			DebugLog(LT_INFO, myName.." is now \ck"..BStateNames[s].."!");
		}

		bstate = s;
	}

	bool StateAboveOrder(uint s) {
		if (!currentOrder) {
			return true;
		}

		if (s == BS_ATTACKING) {
			return currentOrder.orderType != BS_ATTACKING;
		}

		if (s == BS_HUNTING) {
			return true;
		}

		if (s == BS_WANDERING || s == BS_FLEEING) {
			return currentOrder.orderType == BS_FOLLOWING;
		}

		if (s == BS_HUNTING) {
			return currentOrder.orderType == BS_ATTACKING;
		}

		return true;
	}

	void ConsiderSetBotState(uint s) {
		if (!StateAboveOrder(s) && currentOrder) {
			currentOrder.Apply(self);
			return;
		}

		SetBotState(s);
	}

	ZTBotOrder currentOrder;
	ZTBotOrder orderGiven;

	void SetOrder(ZTBotOrder newOrder) {
		if (newOrder && newOrder.orderer != commander) {
			SetCommander(newOrder.orderer);
		}

		if (newOrder != currentOrder) {
			if (newOrder) {
				DebugLog(LT_INFO, myName.." was ordered to \ck"..newOrder.v_imperative.."!");
			}

			else {
				DebugLog(LT_INFO, myName.." has no orders now ("..(currentOrder.v_past)..").");
			}
		}

		currentOrder = newOrder;

		if (currentOrder) {
			SetBotState(currentOrder.orderType);
			ProcessOrderedState();
		}
	}

	void ProcessOrderedState() {
		if (bstate == BS_ATTACKING || bstate == BS_HUNTING) {
			SetBotState(LineOfSight(enemy) ? BS_ATTACKING : BS_HUNTING);
		}

		if (bstate == BS_FOLLOWING && !ShouldFollow(goingAfter)) {
			SetBotState(BS_WANDERING);
		}
	}

	void SetCurrentNode(ZTPathNode pn) {
		pastNode = currNode;

		if (pn == null) {
			currNode = null;
			return;
		}

		if (pn != currNode) {
			DebugLog(LT_VERBOSE, String.Format("%s is now at the %s node: \ck%s", myName, ZTPathNode.ZTNavTypeNames[pn.nodeType], pn.NodeName()));
		}

		pastNode = currNode;
		currNode = pn;

		if (currNode) {
			currNode.BecomesCurrent(self, possessed);
		}
	}

	bool isEnemy(Actor from, Actor other) {
		ZetaBotPawn zbp;
		PlayerPawn pp;

		if (CVar.FindCVar('teamplay').GetInt() >= 1) {
			Actor comparee;

			if (((zbp = ZetaBotPawn(from)) && (comparee = other)) || ((zbp = ZetaBotPawn(other)) && (comparee = from))) {
				ZTBotController cont = zbp.cont;

				if (cont && cont.IsSameTeam(comparee)) return false;
			}
		}

		return from.bFRIENDLY != other.bFRIENDLY || (!from.bFRIENDLY && other.CheckClass("PlayerPawn", AAPTR_DEFAULT, true)) || CVar.FindCVar('deathmatch').GetInt() > 0;
	}

	ZTPathNode ClosestNode(Actor other) {
		ThinkerIterator iter = ThinkerIterator.Create("ZTPathNode", 91);
		ZTPathNode best = null;
		ZTPathNode cur = null;

		while (cur = ZTPathNode(iter.Next())) {
			if (best == null || (other.Distance3D(cur) < other.Distance3D(best) && cur.nodeType != ZTPathNode.NT_TARGET)) {
				best = cur;
			}
		}

		//DebugLog(LT_VERBOSE, "Closest node to "..other.GetClassName().." is "..(best == null ? "none" : ""..best.NodeName()));

		return best;
	}

	bool LineOfSight(Actor other, Actor from = null) {
		if (other == null)
			return false;

		if (from == null) from = possessed;
		if (from == null) return false;

		if (other.Distance2D(from) > 80) {
			let off = from.Vec2To(other) / from.Distance2D(other);
			let dir = AngleToVector(from.angle);
			double ddot = (off.x * dir.x) + (off.y * dir.y);

			if (ddot <= 0) return false;
		}

		if (!from.CheckSight(other) && LineTrace(from.AngleTo(other), from.Distance3D(other), PitchTo(other), flags: TRF_THRUACTORS | TRF_THRUHITSCAN, offsetz: from.height / 2)) return false;

		return true;
	}

	double PitchTo(Actor other, Actor from = null) {
		if (other == null)
			return 0;

		if (from == null) from = possessed;
		if (from == null) return 0;

		if (other.pos.z + other.height / 2 == from.pos.z + from.height / 2) return 0;

		//return other.pos.z + other.height / 2 - from.pos.z - from.height / 2;
		return tan(other.pos.z + other.height / 2 - from.pos.z - from.height / 2);
	}

	ZTPathNode ClosestVisibleNode(Actor other) {
		ThinkerIterator iter = ThinkerIterator.Create("ZTPathNode", 91);
		ZTPathNode best = null;
		ZTPathNode cur = null;

		while (cur = ZTPathNode(iter.Next())) {
			if (!other.CheckSight(cur)) {
				continue;
			}

			if (best == null || (other.Distance3D(cur) < other.Distance3D(best) && cur.nodeType != ZTPathNode.NT_TARGET)) {
				best = cur;
			}
		}

		//DebugLog(LT_VERBOSE, "Closest visible node to "..other.GetClassName().." is "..(best == null ? "none" : ""..best.NodeName()));

		return best;
	}

	ZTPathNode ClosestVisibleNodeAt(Vector3 location) {
		Actor dummy = Spawn("Candle", pos);
		let res = ClosestVisibleNode(dummy);
		dummy.Destroy();
		return res;
	}

	void RandomStrafe() {
		strafeMomentum += FRandom(-0.1, 0.1);

		if (strafeMomentum < -1)
			strafeMomentum = -1;

		if (strafeMomentum > 1)
			strafeMomentum = 1;

		if (strafeMomentum > 0)
			possessed.MoveRight();

		else
			possessed.MoveLeft();
	}

	BotState assessBotAttitude(Actor other) { // mimicks UT99's TournamentGameInfo(?).AssessBotAttitude(Pawn Other)
		if (isEnemy(possessed, other))
			return BS_ATTACKING;

		else
			return BS_WANDERING;
	}

	ZetaWeapon, bool, double BestWeaponAllTic() {
		double bestRate = 0;
		bool bAltFire = false;
		ZetaWeapon zweap = null;
		ZetaWeapon bestWeap = null;
		Weapon weap = null;
		let iter = ThinkerIterator.create("Weapon", STAT_INVENTORY);

		while (weap = Weapon(iter.Next()))
			if (weap.Owner == possessed) {
				ZetaWeapon zweap = loader.CheckType(weap);
				// A_Log(myName.." > "..weap.GetClassName());

				if (zweap) {
					let assessed1 = zweap.GetRating(self, enemy);
					let assessed2 = zweap.GetAltRating(self, enemy);
					let alt = zweap.CanAltFire(possessed) && (assessed2 > assessed1 || !zweap.CanFire(possessed) );

					if (!(alt || zweap.CanFire(possessed)))
						continue;

					/*if (CVar.FindCVar("zb_debug").GetInt() > 2)
						DebugLog(LT_VERBOSE, myName.." considering a "..zweap.GetClassName()..": alt="..alt.." rating="..(alt ? assessed2 : assessed1).."dm");*/

					let maxAssessed = alt ? assessed2 : assessed1;

					// A_Log("("..zweap.GetClassName().." -> "..maxAssessed..")");

					if (bestWeap == null || maxAssessed > bestRate) {
						bestRate = maxAssessed;
						bestWeap = zweap;
						bAltFire = alt;
					}
				}
			}

		return bestWeap, bAltFire, bestRate;
	}

	bool FireBestWeapon() {
		// if (absangle(possessed.angle, possessed.AngleTo(enemy)) > 80)
		//	   return false;

		// if (lastWeap && BestWeaponAllTic() == lastWeap)
		/* {
			if (lastWeap.CanAltFire(possessed) && lastWeap.GetAltRating(self, enemy) > lastWeap.GetRating(self, enemy)) {
				if (age - lastShot > 0) {
					DebugLog(LT_VERBOSE, myName.." alt-fired a "..lastWeap.GetClassName().."!");
					lastWeap.AltFire(possessed, enemy);

					if (lastWeap.altammouse > 0)
						possessed.A_TakeInventory(lastWeap.altammotype, lastWeap.altammouse);

					lastShot = age + lastWeap.IntervalSeconds();
					DebugLog(LT_VERBOSE, myName.." can shoot again after "..lastWeap.IntervalSeconds().." seconds, or alt-fire after "..lastWeap.AltIntervalSeconds().." seconds!");

					return true;
				}

				return false;
			}

			else if (lastWeap.CanFire(possessed)) {
				if (age - lastShot > 0) {
					DebugLog(LT_VERBOSE, myName.." fired a "..lastWeap.GetClassName().."!");
					lastWeap.Fire(possessed, enemy);

					if (lastWeap.ammouse > 0)
						possessed.A_TakeInventory(lastWeap.ammotype, lastWeap.ammouse);

					lastShot = age + lastWeap.IntervalSeconds();
					DebugLog(LT_VERBOSE, myName.." can shoot again after "..lastWeap.IntervalSeconds().." seconds, or alt-fire after "..lastWeap.AltIntervalSeconds().." seconds!");

					return true;
				}

				return false;
			}
		}
		*/

		if (age < lastShot)
			return false;

		ZetaWeapon bestWeap;
		bool bAltFire;

		[ bestWeap, bAltFire ] = BestWeaponAllTic();

		if (bestWeap == null)
			return false;

		if (bAltFire && bestWeap.CanAltFire(possessed, true)) {
			lastShot = age + bestWeap.AltIntervalSeconds();
			bestWeap.AltFire(possessed, enemy);
		}

		else if (bestWeap.CanFire(possessed, true)) {
			lastShot = age + bestWeap.IntervalSeconds();
			bestWeap.Fire(possessed, enemy);
		}

		else
			return false;

		DebugLog(LT_VERBOSE, myName.." "..(bAltFire ? "alt-" : "").."fired a "..bestWeap.GetClassName().."!");
		DebugLog(LT_VERBOSE, myName.." can only shoot again in "..lastShot - age.." seconds!");

		numShoots++;
		lastWeap = bestWeap;

		return true;
	}

	void RandomMove() { // nodeless wandering
		if (FRandom(0, 1) < 0.5) {
			angleMomentum += (angleMomentum < 0) ? FRandom(-5, 1) : FRandom(-1, 5);

			if (FRandom(0, 1) < 0.03)
				angleMomentum *= -0.2;
		}

		if (FRandom(0, 1) < 0.7)
			MoveForward();

		if (FRandom(0, 1) < 0.5)
			RandomStrafe();

		if (FRandom(0, 1) < 0.3)
			StepBack();
	}

	/* -- unused
	virtual WeaponRating rateWeapon(Weapon weap) {
		WeaponRating res = new("WeaponRating");

		if (enemy == null) {
			res.rating = 0;
			res.bAlt = false;
			return res;
		}

		double rprimary = 0;
		double raltern	= 0;
		double rboth	= 0;

		if (possessed.Distance3D(enemy) < target.radius + radius + 256)
			rboth += weap.Kickback * 4;

		if (weap.ProjectileType) {
			let proj = Spawn(weap.ProjectileType);
			rprimary += proj.speed * possessed.Distance3D(enemy) + proj.damage;
			proj.Destroy();
		}

		else {
			double rangeRate = 1024;
			rangeRate -= possessed.Distance3D(enemy) / 2;

			if (rangeRate > 0)
				rprimary += rangeRate;
		}

		if (weap.AltProjectileType) {
			let proj = Spawn(weap.AltProjectileType);
			raltern += proj.speed * possessed.Distance3D(enemy) + proj.damage;
			proj.Destroy();
		}

		else {
			double rangeRate = 1024;
			rangeRate -= possessed.Distance3D(enemy) / 2;

			if (rangeRate > 0)
				raltern += rangeRate;
		}

		Inventory ammo1 = FindInventory(weap.AmmoType1);
		Inventory ammo2 = FindInventory(weap.AmmoType2);

		if (ammo1)
			rboth += ammo1.Amount * 2;

		if (ammo2)
			rboth += ammo2.Amount * 2;

		if (raltern > rprimary) {
			res.rating = raltern + rboth;
			res.bAlt = true;
		}

		else {
			res.rating = rprimary + rboth;
			res.bAlt = false;
		}

		return res;
	}
	*/

	bool BotChat(String kind, double importance) {
		if (kind == "IDLE" && CVar.FindCVar("zb_noidletalk").GetBool())
			return false;

		if (FRandom(0, 1.0) >= importance * CVar.FindCVar("zb_talkfrequency").GetFloat() / 3)
			return false;

		possessed.A_PlaySound("zetabot/"..myVoice.."/"..kind, CHAN_VOICE, attenuation: 0.7);
		possessed.A_PlaySound("misc/chat", CHAN_UI, 0.2, false, ATTN_NONE);

		DebugLog(LT_VERBOSE, myName.." called a "..kind.." voice");

		return true;
	}

	double targetPriority(Actor other) {
		// The smalest the number, the highest the priority :)
		double res = possessed.Distance3D(other) / other.Health;

		if (other.CheckClass('PlayerPawn'))
			res /= 1.5;

		return res;
	}

	void LogStats() {
		if (possessed == null)
			return;

		String enemyType = "none";
		String goingAfterType = "none";
		String currNodeS = "none";
		String navDestS = "none";

		if (enemy)
			enemyType = enemy.GetClassName();

		if (goingAfter)
			goingAfterType = goingAfter.GetClassName();

		if (currNode)
			currNodeS = currNode.NodeName();

		if (navDest)
			navDestS = navDest.NodeName();

		String lastWeapS = "none.";
		bool useNode = (currNode && currNode.nodeType == ZTPathNode.NT_USE);

		if (lastWeap)
			lastWeapS = lastWeap.GetClassName();

		if (enemy == null)
			DebugLog(LT_VERBOSE, "["..myName.."'s STATS] Health: "..possessed.health.." | Current State: "..BStateNames[bstate].." | Enemy Type: None | Going After Type: "..goingAfterType.." | Current Pathnode: "..currNodeS..(useNode ? " (use)" : "").." | Destination Pathnode: "..navDestS.." | Age: "..age.."s | Best Weapon: none. | Last Weapon: "..lastWeapS);

		else {
			ZetaWeapon wp;
			double rt;
			bool _;
			String enemyH = " | Enemy Health: "..enemy.Health;

			[ wp, _, rt ] = BestWeaponAllTic();
			DebugLog(LT_VERBOSE,
				"["..myName.."'s STATS] Health: "..possessed.health.." | Current State: "..BStateNames[bstate].." | Enemy Type: "..enemyType..enemyH.." | Going After Type: "..goingAfterType.." | Current Pathnode: "..currNodeS..(useNode ? " (use)" : "").." | Destination Pathnode: "..navDestS.." | Age: "..age.."s "..
					(wp == null ? "" : ("| Best Weapon: "..wp.GetClassName().." ("..rt.." dopamine molecules"..(_ ? ", alt" : "")..") ")
			  ) .."| Last Weapon: "..lastWeapS
			);
		}
	}

	int GetTeamFrags(int teamNum) {
		int numFrags = 0;

		let it_players = ThinkerIterator.create("PlayerPawn", STAT_PLAYER);
		let it_bots = ThinkerIterator.create("ZetaBotPawn", STAT_DEFAULT);

		PlayerPawn player;
		ZetaBotPawn bot;

		while (player = PlayerPawn(it_players.Next())) {
			if (player.player && player.player.GetTeam() == teamNum) {
				numFrags += player.player.FragCount;
			}
		}

		while (bot = ZetaBotPawn(it_bots.Next())) {
			if (bot.cont && bot.cont.myTeam == teamNum) {
				numFrags += bot.cont.frags;
			}
		}

		return numFrags;
	}

	bool CheckFragLimit() {
		int fragLimit = CVar.FindCVar("fraglimit").GetInt();

		if (fragLimit <= 0) {
			return false;
		}

		int checkFrags = frags;

		if (CVar.FindCVar("teamplay").GetInt() >= 1) {
			checkFrags = GetTeamFrags(myTeam);
		}

		if (checkFrags >= fragLimit) {
			EndGame('scorelimit');
		}

		return checkFrags >= fragLimit;
	}

	void DisplayTeamFrags() {
		if (CVar.FindCVar('teamplay').GetInt() <= 0) {
			return;
		}

		for (int ti = 0; ti < CVar.FindCVar('zb_maxteams').GetInt(); ti++) {
			int numFrags = GetTeamFrags(ti);

			if (numFrags > 0) {
				A_Log(String.Format("\cr* Team \cw%s\cr has \cw%i frags!", teamNames[ti], numFrags));
			}
		}
	}

	void ScoreFrag() {
		kills++;
		BotChat("ELIM", 0.75);

		if (CVar.FindCVar('deathmatch').GetInt() <= 0) {
			return;
		}

		frags++;

		if (!CheckFragLimit()) {
			DisplayTeamFrags();
		}
	}

	void EndGame(Name reason) {
		let it_players = ThinkerIterator.create("PlayerPawn", STAT_PLAYER);
		let it_bots = ThinkerIterator.create("ZetaBotPawn", STAT_DEFAULT);
		let it_botname = ThinkerIterator.create("_BotName", STAT_DEFAULT);

		PlayerPawn player;
		ZetaBotPawn bot;
		_BotName bn;

		while (bn = _BotName(it_botname.Next())) {
			bn.stopped = true;
		}

		while (player = PlayerPawn(it_players.Next())) {
			if (player.player) {
				player.player.cheats |= CF_TOTALLYFROZEN | CF_GODMODE2;
			}
		}

		while (bot = ZetaBotPawn(it_bots.Next())) {
			if (bot.cont && bot.health >= 0) {
				bot.cont.frozen = true;
				bot.SetStateLabel("Spawn");
			}
		}

		ShowOffEndGame(reason);

		EndGameTimer();
	}

	void DisplayScoreLimit() {
		if (CVar.FindCVar("teamplay").GetInt() >= 1) {
			possessed.A_Print(String.Format("\caTeam \cw%s\ca Won!", teamNames[myTeam]));
		}

		else {
			possessed.A_Print(String.Format("\cw%s\ca Won!", myName));
		}
	}

	void ShowOffEndGame(Name reason) {
		if (reason == 'scorelimit') {
			DisplayScoreLimit();
			return;
		}
	}

	void EndGameTimer() {
		SetStateLabel("EndGameTimer");
	}

	// bot death listener
	void OnDeath(Actor source, Actor inflictor, int dmgflags = 0, Name MeansOfDeath = 'none') {
		//A_PrintBold("\cg"..myName.." has just died!");

		String obituary = "";

		if (lastEnemyPos != null) {
			lastEnemyPos.Destroy();
		}

		if (source && source != possessed) {
			obituary = Stringtable.Localize(source.GetObituary(possessed, inflictor, MeansOfDeath, false));
		}

		else {
			if (MeansOFDeath == 'teamchange') {
				obituary = "%o changed teams to "..teamNames[myTeam]..".";
			}

			else {
				obituary = "%o was looking nice and smart till they killed their dumb self.";

				frags--;
			}
		}

		if (ZetaBotPawn(source) && ZetaBotPawn(source).cont && ZetaBotPawn(source).cont.IsEnemy(source, possessed)) {
			ZetaBotPawn(source).cont.ScoreFrag();
		}

		if (PlayerPawn(source) && PlayerPawn(source).player && IsEnemy(PlayerPawn(source), possessed)) {
			PlayerPawn(source).player.FragCount++;
			DisplayTeamFrags();
		}

		obituary.replace("%o", myName);
		obituary.replace("%k", ActorName(source));
		A_Log("\cf"..obituary);

		let friends = VisibleFriends(possessed);
		Object a = null;
		ZetaBotPawn zb = null;

		/*
		while (a = friends.iNext())
			if ((zb = ZetaBotPawn(a)) && possessed.Distance3D(zb) < 2048 / friends.Length() && zb.cont.bState == BS_ATTACKING && zb.cont)
				zb.cont.ConsiderSetBotState(BS_FLEEING);
		*/

		NumBots.Get().value--;

		if (teamMarker) {
			teamMarker.Destroy();
			teamMarker = null;
		}
	}

	void Subroutine_Follow() {
		if (!goingAfter || goingAfter.Health <= 0) {
			if (lastEnemyPos && lastEnemyPos.nodeType == ZTPathNode.NT_TARGET) lastEnemyPos.Destroy();
			lastEnemyPos = null;

			RefreshCommander(); // make sure invalid orders do not stay, to avoid infinite loops
			ConsiderSetBotState(BS_WANDERING);
			return;
		}

		if (HasFollowed(goingAfter)) {
			if (lastEnemyPos && lastEnemyPos.nodeType == ZTPathNode.NT_TARGET) lastEnemyPos.Destroy();
			lastEnemyPos = null;

			ConsiderSetBotState(AssessBotAttitude(goingAfter));
			return;
		}

		if (lastEnemyPos == null && !possessed.CheckSight(goingAfter)) {
			lastEnemyPos = ZTPathNode.plopNode(goingAfter.pos, ZTPathNode.NT_TARGET, 0);
		}

		if (lastEnemyPos != null) {
			lastEnemyPos.SetOrigin(goingAfter.pos, true);
		}

		BotChat("IDLE", 2.25 / 90);

		DodgeAndUse();

		if (!PathMoveTo(goingAfter, true)) {
			DebugLog(LT_INFO, String.Format("Unable to follow %s! Going back to wandering.", ActorName(goingAfter)));

			goingAfter = null;
			ConsiderSetBotState(BS_WANDERING);

			Subroutine_Wander();

			return;
		}
	}

	bool ComplexPathTo(Actor Where) {
		let closestNode = Where is "ZTPathNode" ? ZTPathNode(Where) : ClosestNode(Where);
		ActorList path = currNode.findPathTo(closestNode, self);

		if (!path || path.Length() <= 0) {
			return false;
		}

		navDest = ZTPathNode(path.get(0));

		if (navDest) {
			SmartMove(navDest);

			//DebugLog(LT_INFO, "Next navigation point found: "..navDest.NodeName());
		}

		if (path) {
			path.Destroy(); // clean actorlists after use
		}

		return navDest != null;
	}

	bool PathMoveTo(Actor Where, bool bUseLastEnemyPos = false) {
		if (possessed.CheckSight(Where)) {
			if (Where is "ZTPathNode") {
				SmartMove(ZTPathNode(Where));
			}

			else {
				MoveToward(Where, 20);
			}

			return true;
		}

		if (currNode && (navDest == null || possessed.Distance2D(navDest) < 64)) {
			return ComplexPathTo(bUseLastEnemyPos ? Where : Actor(lastEnemyPos));
		}

		if (navDest && CheckSight(navDest)) {
			SmartMove(navDest);
			return true;
		}

		navDest = null;
		return false;
	}

	void Subroutine_Hunt() {
		if (enemy == null || enemy.Health <= 0) {
			enemy = null;
			ConsiderSetBotState(BS_WANDERING);
			SetOrder(null);

			if (lastEnemyPos && lastEnemyPos.nodeType == ZTPathNode.NT_TARGET) lastEnemyPos.Destroy();
			lastEnemyPos = null;
		}

		else if (LineOfSight(enemy) || possessed.Distance3D(enemy) < 96) {
			AimToward(enemy, 50);
			ConsiderSetBotState(BS_ATTACKING);
			possessed.Jump();

			if (lastEnemyPos && lastEnemyPos.nodeType == ZTPathNode.NT_TARGET) lastEnemyPos.Destroy();
			lastEnemyPos = null;
		}

		else {
			if (enemy == null && bstate != BS_HUNTING) {
				PickEnemy();
			}

			if (bstate == BS_HUNTING) {
				if (lastEnemyPos == null || lastEnemy == null) {
					ConsiderSetBotState(BS_WANDERING);
					return;
				}

				Vector2 posDiff = possessed.pos.xy - lastEnemy.pos.xy;
				double lastPosSqDist = posDiff dot posDiff;

				if (lastPosSqDist < 48 * 48) {
					DebugLog(LT_VERBOSE, String.Format("Close to last seen enemy pos but no enemy spotted! Going back to wandering. (expected x > %i, got = %i)", 40 * 40, lastPosSqDist));

					enemy = null;
					ConsiderSetBotState(BS_WANDERING);

					if (lastEnemyPos && lastEnemyPos.nodeType == ZTPathNode.NT_TARGET) lastEnemyPos.Destroy();
					lastEnemyPos = null;
				}

				else if (lastEnemyPos) {
					if (!PathMoveTo(lastEnemyPos)) {
						DebugLog(LT_INFO, String.Format("No path found to last enemy pos while hunting %s! Going back to wandering.", ActorName(lastEnemyPos)));

						if (lastEnemyPos.nodeType == ZTPathNode.NT_TARGET) {
							lastEnemyPos.Destroy();
						}

						lastEnemyPos = null;
						ConsiderSetBotState(BS_WANDERING);

						return;
					}

					if (bstate == BS_HUNTING) {
						if (FRandom(0, 1) < 0.12)
							possessed.Jump();

						AutoUseAtAngle(0);
					}
				}

				else {
					enemy = null;
					ConsiderSetBotState(BS_WANDERING);
				}

				if (bstate == BS_HUNTING) {
					BotChat("ACTV", 0.025);
				}
			}
		}
	}

	bool DodgeAndUse() {
		if (currNode == null)
			return false;

		if (currNode.nodeType == ZTPathNode.NT_USE) {
			FLineTraceData useData;
			MoveTowardPos(currNode.pos + currNode.Vec3Angle(64 + possessed.radius, currNode.useDirection, 0, false), 15);
			AimAtAngle(currNode.useDirection, 35);

			possessed.LineTrace(
				possessed.angle,
				possessed.radius + 64,
				0, // possessed.pitch,
				flags: TRF_THRUBLOCK | TRF_THRUHITSCAN | TRF_THRUACTORS | TRF_BLOCKUSE,
				offsetz: possessed.height - 24, // offsetz: possessed.height - 12,
				data: useData
			);

			if (useData.HitType == TRACE_HitWall) {
				if (useData.HitLine.Special > 0) {
					Line l = useData.HitLine;
					DebugLog(LT_VERBOSE, "["..myName.." USE NODE LOGS] Activating wall! Line special: "..l.Special);
					l.Activate(possessed, 0, SPAC_Use);

					Level.ExecuteSpecial(
						l.Special,
						possessed,
						l, 0,

						l.Args[0],
						l.Args[1],
						l.Args[2],
						l.Args[3],
						l.Args[4]
					);
				}

				else {
					if (GruntInterval == 0 || GruntInterval-- == 0) {
						possessed.A_PlaySound("ztmisc/grunt", CHAN_VOICE, attenuation: 1.1);
						GruntInterval = 20;
						Log(GruntInterval);
					}

					//MoveAwayFrom(currNode);
					//MoveAwayFrom(currNode);

					return false;
				}
			}
		}

		else if (currNode.nodeType == ZTPathNode.NT_JUMP && FRandom(0, 1) < 0.8) {
			possessed.Jump();
			AimAtAngle(currNode.Angle, 70, 20);
		}

		if (FRandom(0, 1) < 0.0175)
			possessed.Jump();

		CheckObstructions();

		return currNode.nodeType == ZTPathNode.NT_USE;
	}

	void PickEnemy() {
		if (currentOrder && currentOrder.lookedAt && LineOfSight(currentOrder.lookedAt) && (
			currentOrder.orderType == BS_ATTACKING ||
			currentOrder.orderType == BS_FLEEING   ||
			currentOrder.orderType == BS_FOLLOWING
		)) {
			currentOrder.Apply(self);
			return;
		}

		ActorList mon = VisibleEnemies(possessed);

		if (mon.length() <= 0) {
			mon.Destroy(); // clean actorlists after use
			return;
		}

		PriorityQueue targets = PriorityQueue.Make("ActorHasher", 64);

		for (uint i = 0; i < mon.length(); i++)
			targets.add(mon.get(i), TargetPriority(mon.get(i)));

		Actor newEnemy = Actor(targets.poll());

		if (enemy == null || TargetPriority(enemy) < TargetPriority(newEnemy)) {
			if (lastEnemyPos != null) {
				lastEnemyPos.Destroy();
				lastEnemyPos = null;
			}

			enemy = Actor(newEnemy);
		}

		/*
		else {
			if (retargetCount < 1) {
				if (lastEnemyPos != null) {
					lastEnemyPos.Destroy();
					lastEnemyPos = null;
				}

				enemy = Actor(targets.poll());
				retargetCount = 15;
			}

			else {
				retargetCount--;
			}
		}
		*/

		DebugLog(LT_INFO, "Attacking a "..enemy.GetClassName());

		BotChat("TARG", 0.8);

		navDest = null;
		ConsiderSetBotState(BS_ATTACKING);

		if (mon) {
			mon.Destroy(); // clean actorlists after use
		}
	}

	void Subroutine_Flee() {
		if (DodgeAndUse()) {
			if (currNode)
				navDest = currNode.RandomNeighbor();

			else
				navDest = null;

			ConsiderSetBotState(BS_WANDERING);
		}

		if (enemy && possessed.Distance3D(enemy) < 1024 && possessed.CheckSight(enemy) && possessed.Health < possessed.default.Health / 7)
			MoveAwayFrom(enemy);

		else
			ConsiderSetBotState(BS_WANDERING);
	}

	void Subroutine_Attack() {
		if (lastEnemyPos != null) {
			lastEnemyPos.Destroy();
			lastEnemyPos = null;
		}

		if (bstate != BS_ATTACKING && enemy == null) {
			currEnemyPos = pos;
		}

		if (enemy == null || enemy.Health < 1) {
			SetOrder(null);

			possessed.EndShoot();
			ConsiderSetBotState(BS_WANDERING);
		}

		if (!LineOfSight(enemy)) {
			possessed.endshoot();

			if (lastenemypos && lastenemypos.nodetype == ztpathnode.nt_target) lastenemypos.destroy();

			let node = closestvisiblenodeat(currenemypos);

			if (node == null || node.Distance3D(enemy) > 100) {
				lastenemypos = ztpathnode.plopnode(currenemypos, ztpathnode.nt_target);
			}

			else {
				lastenemypos = node;
			}

			navdest = null;
			lastEnemyPos = ZTPathNode.plopNode(currEnemyPos, ZTPathNode.NT_TARGET, 0);
			ConsiderSetBotState(BS_HUNTING);

			return;
		}

		else {
			currEnemyPos = enemy.pos;
		}

		if (FRandom(0, 1) < 0.06)
			possessed.Jump();

		BotChat("ACTV", 0.05);

		ZetaWeapon w = BestWeaponAllTic();

		if (w == null) {
			if (lastEnemyPos != null) {
				lastEnemyPos.Destroy();
				lastEnemyPos = null;
			}

			enemy = null;
			goingAfter = null;

			possessed.EndShoot();
			ConsiderSetBotState(BS_WANDERING);

			return;
		}

		if (possessed.Distance3D(enemy) > 256 + enemy.radius || w.IsMelee()) {
			MoveToward(enemy, 35);

			if (enemy.bShadow || enemy.CheckInventory("PowerInvisibility", 1)) {
				angleMomentum += FRandom(-5, 5);
			}
		}

		else if (possessed.Distance3D(enemy) < 128 + enemy.radius) {
			StepBackFrom(enemy);
		}

		RandomStrafe();
		AimToward(enemy, 20, 30);

		if (!LineOfSight(enemy)) {
			possessed.EndShoot();
			return;
		}

		let off = possessed.Vec2To(enemy) / possessed.Distance2D(enemy);
		let dir = AngleToVector(possessed.angle);
		double ddot = (off.x * dir.x) + (off.y * dir.y);

		if (dDot <= 0) {
			possessed.EndShoot();
		}

		else if (FireBestWeapon()) {
			possessed.BeginShoot();
		}

		else {
			possessed.EndShoot();
		}
	}

	Actor GetOrderSubject() {
		if (enemy) {
			return enemy;
		}

		if (bstate == BS_FOLLOWING && goingAfter) {
			return goingAfter;
		}

		return possessed;
	}

	uint GetOrderState() {
		if (enemy) {
			return BS_ATTACKING;
		}

		return BS_FOLLOWING;
	}

	void UpdateOrderGiven() {
		OrderGiven.UpdateOrder(
			possessed,
			GetOrderSubject(),
			enemy ? BS_ATTACKING : BS_FOLLOWING);
	}

	void ConcoctOrderToGive() {
		if (orderGiven == null) {
			orderGiven = ZTBotOrder.Make(null, null, 0);
		}

		UpdateOrderGiven();
	}

	bool BetterCommander(Actor otherCommander) {
		if (otherCommander is "PlayerPawn") {
			return false;
		}

		ZetaBotPawn zbp = ZetaBotPawn(otherCommander);

		if (!zbp || !zbp.cont) {
			return true;
		}

		return zbp.cont.kills < kills;
	}

	void GiveCommands() {
		ConcoctOrderToGive();

		ActorList friends = VisibleFriends(possessed, true);
		ZetaBotPawn friend;

		bool didChat = false;
		uint i = 0;

		while (i < friends.Length()) {
			friend = ZetaBotPawn(friends.Get(i++));

			if (
				friend
				&& friend != possessed
				&& friend.cont
				&& (!friend.cont.commander || friend.cont.commander == self || BetterCommander(friend.cont.commander))
				&& (!friend.cont.currentOrder || friend.cont.currentOrder != orderGiven)
				&& possessed.Distance2D(friend) < 600
			) {
				orderGiven.Apply(friend.cont);

				if (friend.cont.bstate == BS_HUNTING && friend.cont.enemy == enemy) {
					friend.cont.lastEnemyPos = lastEnemyPos;
				}

				friend.cont.SetCommander(self);

				if (!didChat) {
					BotChat("ORDR", 0.2);
					didChat = true;
				}
			}
		}

		if (friends) {
			friends.Destroy(); // clean actorlists after use
		}
	}

	bool SetCommander(Actor newCommander) {
		if (newCommander == commander) {
			return true;
		}

		if (!newCommander) {
			DebugLog(LT_INFO, myName.." is no longer led "..(!commander ? "" : "(was previously led by"..ActorName(commander)..")"));
			commander = null;

			return true;
		}

		let ztcom = ZetaBotPawn(newCommander);

		if (ztcom && ztcom.cont && ztcom.cont.commander && ztcom.cont.commander == self) {
			return false;
		}

		commander = newCommander;
		DebugLog(LT_INFO, myName.." is now led by "..ActorName(commander));
		return true;
	}

	void PickCommander() {
		if (!commander) { // get a commander
			ActorList friends = VisibleFriends(possessed);

			if (friends.length() > 0) {
				let newCommander = friends.get(Random(0, friends.length() - 1));
				SetCommander(newCommander);

				if (commander) {
					BotChat("COMM", 0.8);
				}
			}

			if (friends) {
				friends.Destroy(); // clean actorlists after use
			}
		}
	}

	bool HasFollowed(Actor who) {
		if (!who) {
			return false;
		}

		if (possessed.Distance3D(who) > 100) {
			return false;
		}

		return possessed.CheckSight(who) || possessed.Distance2D(who) < 100;
	}

	bool ShouldFollow(Actor who) {
		if (!who) {
			return false;
		}

		if (possessed.Distance3D(who) > 300) {
			return true;
		}

		if (possessed.Distance3D(who) < 60) {
			return false;
		}

		return !possessed.CheckSight(who);
	}

	void CheckPlopGround() {
		SetCurrentNode(ClosestVisibleNode(possessed));

		if (
			(currNode == null || possessed.Distance2D(currNode) > 300 || (
				(!possessed.CheckSight(currNode) && possessed.Distance2D(currNode) > 32))
			)
			&& CVar.FindCVar('zb_autonodes').GetBool() && CVar.FindCVar("zb_autonodenormal").GetBool()
		) {
			SetCurrentNode(ZTPathNode.plopNode(
				currNode == null ? possessed.pos : currSeeNodePos,
				ZTPathNode.NT_NORMAL,
				possessed.angle));

			currSeeNodePos = possessed.pos;
		}
	}

	void RefreshNode() {
		CheckPlopGround();

		if (currNode && possessed.CheckSight(currNode)) {
			currSeeNodePos = possessed.pos;
		}
	}

	void Subroutine_Wander() {
		if (lastEnemyPos != null) {
			lastEnemyPos.Destroy();
			lastEnemyPos = null;
		}

		enemy = null;
		BotChat("IDLE", 2.25 / 100);

		MoveForward();

		if (ShouldFollow(commander)) {
			ConsiderSetBotState(BS_FOLLOWING);

			if (bstate == BS_FOLLOWING) {
				goingAfter = commander;
				return;
			}
		}

		PickCommander();

		if (currNode == null) {
			SetCurrentNode(ClosestVisibleNode(possessed));
		}

		DodgeAndUse();

		if (currNode && possessed.Distance2D(currNode) < 100 && navDest && navDest != currNode) {
			MoveToward(navDest, 10); // wander to this random neighbouring node
		}

		else {
			navDest = null;
			RandomMove();
		}

		if (!navDest) {
			if (currNode) {
				navDest = currNode.RandomNeighbor();

				if (navDest == currNode) {
					navDest = null;
				}
			}
		}
	}

	void FireAtBarrels() {
		let it_barrels = ThinkerIterator.create("ExplosiveBarrel", STAT_DEFAULT);
		ExplosiveBarrel bclosest = null, bar = null;
		double bdist = 100;

		while (bar = ExplosiveBarrel(it_barrels.Next())) {
			if (!LineOfSight(bar)) continue;
			if (possessed.Distance2D(bar) < bdist) {
				bclosest = bar;
				bdist = possessed.Distance2D(bar);

				DebugLog(LT_VERBOSE, String.Format("Considering shootable barrel %fpx away.", bdist));
			}
		}

		if (bclosest) {
			AimToward(bclosest, 50);

			if ((currNode.nodeType != ZTPathnode.NT_SHOOT || possessed.Distance2D(currNode) > 40) && CVar.FindCVar('zb_autonodes').GetBool()) {
				SetCurrentNode(ZTPathNode.plopNode(possessed.pos, ZTPathNode.NT_SHOOT, possessed.AngleTo(bclosest)));

				if (currNode)
					DebugLog(LT_INFO, String.Format("Defining shootable barrel %fpx away: %s", bdist, currNode.NodeName()));
			}

			else {
				if (AbsAngle(possessed.AngleTo(bclosest), possessed.angle) <= 100) {
					if (FireBestWeapon()) possessed.BeginShoot();
				}

				else
					possessed.EndShoot();
			}
		}
	}

	void StatusDoubleCheck() {
		if (CVar.FindCVar("teamplay").GetInt() >= 1) {
			if (myTeam >= CVar.FindCVar("zb_maxteams").GetInt()) {
				// cap team back to maxteams
				SetTeam(myTeam % CVar.FindCVar("zb_maxteams").GetInt());
			}

			if (teamMarker == null) {
				teamMarker = ZetaTeamMarker(Spawn("ZetaTeamMarker"));
				teamMarker.attached = possessed;

				teamMarker.SetColor(teamColorsHex[myTeam]);
			}
		}

		else {
			if (teamMarker) {
				teamMarker.Destroy();
			}
		}
	}

	int thinkTimer;

	bool PlopTeleportNodes(Vector3 lastPos, double lastAngle = 0.0) {
		if (!CVar.FindCVar("zb_autonodes").GetBool() || !CVar.FindCVar("zb_autonodetele").GetBool()) {
			return false;
		}

		if (currnode && currnode.nodeType == ZTPathNode.NT_TELEPORT_SOURCE && (currNode.pos.xy - lastPos.xy).Length() < 200) {
			return false;
		}

		let nodefrom = ZTPathNode.plopNode(lastPos, ZTPathNode.NT_TELEPORT_SOURCE, lastAngle);
		let nodeinto = ZTPathNode.plopNode(possessed.pos, ZTPathNode.NT_NORMAL, possessed.angle);

		nodefrom.assoc_id = nodeinto.id;

		SetCurrentNode(nodeinto);

		return true;
	}

	void CrossActivate() {
		// activate p-cross line actions

		FLineTraceData useData;

		let tracer = new("LineCrossTracer");

		tracer.Trace(
			possessed.pos,
			possessed.CurSector,
			(possessed.vel.xy, 0),
			possessed.vel.xy.Length(),
			0
		);

		if (tracer.crossLines.Size() > 0) {
			DebugLog(LT_VERBOSE, "["..myName.." CROSS LOGS] Can cross "..tracer.crossLines.Size().." lines!");

			for (int i = 0; i < tracer.crossLines.Size(); i++) {
				let l = tracer.crossLines[i];

				Vector3 lastPos = possessed.pos;
				double lastAngle = possessed.angle;

				DebugLog(LT_VERBOSE, "["..myName.." CROSS LOGS] Activating cross line! Line special: "..l.Special);
				l.Activate(possessed, 0, SPAC_Cross);

				Level.ExecuteSpecial(
					l.Special,
					possessed,
					l, 0,

					l.Args[0],
					l.Args[1],
					l.Args[2],
					l.Args[3],
					l.Args[4]
				);

				if ((possessed.pos.xy - lastPos.xy).Length() > 256) {
					PlopTeleportNodes(lastPos, lastAngle);
					return;
				}
			}
		}
	}

	void RefreshCommander() {
		if (commander && commander.health <= 0) {
			commander = null;
		}

		if (currentOrder && (currentOrder.orderer == null || currentOrder.orderer.health <= 0)) {
			currentOrder = null;
		}

		if (currentOrder && (currentOrder.lookedAt == null || currentOrder.lookedAt.health <= 0)) {
			currentOrder = null;
		}
	}

	void RefreshTeam() {
		if (!CVar.FindCVar('teamplay').GetBool()) {
				return;
		}

		int upperCap = CVar.FindCVar("zb_maxteams").GetInt();

		if (myTeam < upperCap) {
				return;
		}

		possessed.Die(possessed, possessed, 0, 'teamchange');
		frags = 0;
		PickBalancedTeams(true);
	}

	void DispatchAiState() {
		switch (bstate) {
			case BS_HUNTING:
				Subroutine_Hunt();
				break;

			case BS_FLEEING:
				Subroutine_Flee();
				break;

			case BS_ATTACKING:
				Subroutine_Attack();
				break;

			case BS_WANDERING:
				Subroutine_Wander();
				break;

			case BS_FOLLOWING:
				Subroutine_Follow();
				break;
		}
	}

	void TickAge() {
		age += 1. / 35;
		debugCount -= 1;
	}

	void ApplyMovement() {
		if (angleMomentum > maxAngleRate) {
			angleMomentum = maxAngleRate;
		}

		if (angleMomentum < -maxAngleRate) {
			angleMomentum = -maxAngleRate;
		}

		possessed.angle += angleMomentum * 5;
		possessed.ApplyMovement();

		angleMomentum *= 0.95;
	}

	bool TickToThink() {
		if (thinkTimer > 0) {
			thinkTimer--;
			return true;
		}

		else {
			thinkTimer = 3;
		}

		return false;
	}

	void RefreshEnemy() {
		if (enemy && enemy.Health <= 0) {
			if (lastEnemyPos && lastEnemyPos.nodeType == ZTPathNode.NT_TARGET) lastEnemyPos.Destroy();
			enemy = null;

			if (bstate == BS_ATTACKING) {
				bstate = BS_WANDERING;

				enemy = null;
				goingAfter = null;

				possessed.EndShoot();
				ConsiderSetBotState(BS_WANDERING);
			}
		}

	}

	void CheckBlocked() {
		if (possessed.blockingMobj || possessed.blockingLine) {
			blocked += 1 + sqrt(possessed.vel.x * possessed.vel.x + possessed.vel.y * possessed.vel.y) / 2;
		}

		if (blocked > 0) {
			blocked--;
			RandomStrafe();
			possessed.MoveBackward();
			angleMomentum += FRandom(-1, 1);
			angleMomentum *= 1.6 * (blocked / 3 + 1);
		}
	}

	void TryUse() {
		if (currNode && currNode.nodeType == ZTPathNode.NT_USE) {
			DodgeAndUse();
		}

		else if (CVar.FindCVar('zb_autouse').GetBool()) {
			AutoUseAtAngle(0);
		}
	}

	void A_ZetaTick() {
		StatusDoubleCheck();
		CrossActivate();
		RefreshCommander();

		if (TelefragTimer > 0) {
			TelefragTimer--;
		}

		if (possessed == null || possessed.Health <= 0) {
			if (lastEnemyPos && lastEnemyPos.nodeType == ZTPathNode.NT_TARGET) lastEnemyPos.Destroy();

			if (CVar.FindCVar('zb_respawn').GetBool() && (CVar.FindCVar('deathmatch').GetInt() > 0 || CVar.FindCVar('zb_alsocooprespawn').GetBool())) {
				DebugLog(LT_VERBOSE, String.format("Setting Respawn mode for %s.", myName));
				SetStateLabel("Respawn");
			}

			else
				Destroy();

			return;
		}

		if (possessed.health <= 0) {
			enemy = null;
			return;
		}

		TickAge();
		ApplyMovement();

		if (frozen) {
			possessed.EndShoot();
			return;
		}

		RefreshNode();

		if (age - lastShot > 0.7 && possessed.bShooting)
			possessed.EndShoot();

		if (!TickToThink()) {
			return;
		}

		RefreshEnemy();

		if (--logRate <= 0) {
			logRate = 50;
			LogStats();
		}

		CheckBlocked();

		/*
		let pickupIter = ThinkerIterator.Create("Weapon", STAT_INVENTORY);
		Weapon inv;

		while ((inv = Weapon(pickupIter.Next()))) {
			if (inv.owner) continue;

			if (possessed.Distance2D(inv) < possessed.Radius + inv.Radius) if (abs(possessed.pos.z - inv.pos.z) < possessed.Height + inv.Height) {
				ZetaWeapon zw = loader.CheckType(inv);

				if (zw) {
					inv.CallTryPickup(possessed); // weapon items are checked by fireBestWeap
				}
			}
		}
		*/

		TryUse();

		GiveCommands();

		if (currNode && currNode.nodeType == ZTPathNode.NT_TELEPORT_SOURCE) {
			// always go to a teleport if going to it
			MoveToward(currNode, 45);
		}

		DispatchAiState();

		if (bstate != BS_ATTACKING) {
			if (bstate != BS_FLEEING)
				PickEnemy();
		}

		if (currNode) {
			FireAtBarrels();
		}
	}

	States {
		Spawn:
			TNT1 A 1;
			Goto TickLoop;

		Respawn:
			TNT1 A 12;
			TNT1 A 0 A_Jump(180, "Respawn");
			TNT1 A 1 A_ZetaRespawn;
			TNT1 A 0 A_JumpIf(possessed.Health <= 0, "Respawn");
			Goto TickLoop;

		TickLoop:
			TNT1 A 1 A_ZetaTick;
			Loop;

		EndGameTimer:
			TNT1 A 0;
			TNT1 A 175;
			TNT1 A -1 Exit_Normal(0);
			Stop;
	}
}

class ZetaBot : Actor {
	mixin DebugLog;

	override void PostBeginPlay() {
		Super.PostBeginPlay();

		bool bHasNode;
		let ni = ThinkerIterator.create("ZTPathNode", 91);

		if (ni.Next())
			bHasNode = true;

		if (!bHasNode && CVar.FindCVar("nodelist").GetString() != "::NONE")
			ZTPathNode.plopNodes(CVar.FindCVar("nodelist").GetString());

		DebugLog(LT_VERBOSE, "Serialized Nodes: "..ZTPathNode.serializeLevel());

		ZTBotController cont = ZTBotController(Spawn("ZTBotController", pos));

		if (cont == null) {
			return;
		}

		cont.angle = angle;
		cont.possessed.angle = angle;

		if (zb_autonoderespawn) {
			let iter = ThinkerIterator.Create("ZTPathNode", 91);
			bool can = true;
			ZTPathNode pn;

			while (pn = ZTPathNode(iter.Next()))
				if (pn.nodeType == ZTPathNode.NT_RESPAWN && pn.Distance2D(cont.possessed) < 64) {
					can = false;
					break;
				}

			if (can) {
				DebugLog(LT_INFO, String.format("Added respawn node at location x=%f,y=%f,z=%f", pos.x, pos.y, pos.z));
				ZTPathNode.plopNode(cont.possessed.pos, ZTPathNode.NT_RESPAWN, angle);
			}
		}

		DebugLog(LT_INFO, "ZetaBot spawned with success! Class: "..cont.possessed.GetClassName());
		Destroy();
	}
}

class ZetaSpirit : Actor {
	mixin DebugLog;

	override void PostBeginPlay() {
		Super.PostBeginPlay();

		bool bHasNode;
		let ni = ThinkerIterator.create("ZTPathNode", 91);

		if (ni.Next())
			bHasNode = true;

		if (!bHasNode && CVar.FindCVar("nodelist").GetString() != "::NONE")
			ZTPathNode.plopNodes(CVar.FindCVar("nodelist").GetString());

		DebugLog(LT_VERBOSE, "Serialized Nodes: "..ZTPathNode.serializeLevel());

		ZTBotController cont = ZTBotController(Spawn("ZTBotController", pos));

		if (cont == null)
			return;

		cont.possessed.angle = angle;

		DebugLog(LT_INFO, "ZetaBot spawned with success! Class: "..cont.possessed.GetClassName());
		Destroy();

		let piter = ThinkerIterator.create("PlayerPawn");
		PlayerPawn pn;

		while (pn = PlayerPawn(piter.Next())) {
			DebugLog(LT_INFO, "Possessing a "..pn.GetClassName());
			ZetaSpiritEyes zse = ZetaSpiritEyes(Spawn("ZetaSpiritEyes"));
			zse.SetPlayer(pn);
			zse.possessed = cont.possessed;
			zse.cont = cont;
		}
	}
}

class ZetaSpiritEyes : Actor {
	ZetaBotPawn possessed;
	ZTBotController cont;
	PlayerPawn playa;

	void SetPlayer(PlayerPawn pn) {
		FreePlayer();

		playa = pn;
		playa.bInvisible = true;
		playa.bSolid = false;
		playa.bShootable = false;
	}

	void FreePlayer() {
		if (playa == null) return;

		playa.bInvisible = false;
		playa.bSolid = true;
		playa.bShootable = true;

		playa = null;
	}

	override void Tick() {
		if (cont == null || cont.possessed == null || possessed == null || possessed.Health <= 0) {
			FreePlayer();
			Destroy();
		}

		if (playa) {
			playa.SetXYZ(possessed.pos);
			playa.angle = possessed.angle;
			playa.health = possessed.health;
			if (cont.enemy == null) playa.pitch = 0;
			else playa.pitch = cont.PitchTo(cont.enemy);
		}
	}

	states {
		Spawn:
			TNT1 A 1;
			Goto TickLoop;

		TickLoop:
			TNT1 A 1;
			Loop;
	}
}

class BotName : Inventory {
	override void Tick() {
		if (Owner == null) {
			Super.Tick();
			return;
		}

		_BotName.MakeFor(Owner);
		Destroy();
		return;
	}
}

class _BotName : Thinker {
	int countDown;
	bool printing;
	bool stopped;
	Actor lastShown;
	Actor Owner;

	mixin DebugLog;
	mixin ActorName;

	static _BotName MakeFor(Actor NewOwner) {
		let bn = _BotName(New("_BotName"));

		bn.Owner = NewOwner;
		bn.countdown = 0;
		bn.stopped = false;

		return bn;
	}

	String DescribeCommander(ZTBotController cont) {
		if (cont.commander == null) {
			return "\crNo commander";
		}

		return "\cyCommander: \cw"..ActorName(cont.commander);
	}

	String DescribeTeam(ZTBotController cont) {
		if (CVar.FindCVar("teamplay").GetInt() < 1) {
			return "";
		}

		return "\crTeam: "..ZTBotController.teamNames[cont.myTeam];
	}

	String DescribeDebug(ZTBotController cont) {
		if (CVar.FindCVar("zb_debug").GetInt() < 2) {
			return "";
		}

		return String.Format("\coCurrently at node \cw#%i\co%s",
			cont.currNode ? cont.currNode.id : 0,
			cont.navDest == null ? "" : " and moving towards #"..cont.navDest.id
		);
	}

	String DescribeTask(ZTBotController cont) {
		if (cont.bstate == ZTBotController.BS_ATTACKING && cont.enemy) {
			ZetaWeapon bestWeap;
			bool _bAltFire;

			[ bestWeap, _bAltFire ] = cont.BestWeaponAllTic();

			return String.Format("\crAttacking \cw%s\cr!",
				ActorName(cont.enemy));
		}

		if (cont.bstate == ZTBotController.BS_FOLLOWING && cont.goingAfter) {
			return String.Format("\crFollowing \cw%s",
				ActorName(cont.goingAfter));
		}

		return "\cc"..ZTBotController.BStateNames[cont.bstate];
	}

	String DescribeOrders(ZTBotController cont) {
		// Skips the order target stuff - usually redundant with the task (aka bot state), anyways.

		if (cont.currentOrder == null) {
			return "\ccNo orders\cr";
		}

		else {
			return String.format("\cr Ordered by \cw%s\cr to \cw%s \co%s",
				ActorName(cont.currentOrder.orderer),
				cont.currentOrder.v_imperative,
				cont.currentOrder.lookedAt ? ActorName(cont.currentOrder.lookedAt) : "");
		}
	}

	String DescribeFrags(ZTBotController cont) {
		if (CVar.FindCVar('deathmatch').GetInt() <= 0) {
			return "";
		}

		else {
			return String.Format("\cr and \cg%i frags", cont.frags);
		}
	}

	override void Tick() {
		if (stopped) {
			return;
		}

		bool showing = false;

		if (countDown < 1) {
			let iter = ThinkerIterator.Create("ZetaBotPawn", STAT_DEFAULT);
			ZetaBotPawn zb = null;
			ZetaBotPawn closest = null;
			double cdist = 512;

			while (zb = ZetaBotPawn(iter.Next())) {
				Vector2 v1 = Owner.AngleToVector(Owner.angle);
				Vector2 v2 = Owner.Vec2To(zb) / Owner.Distance2D(zb);

				double vdot = v1 dot v2;

				if (vdot > 1.0 - 1.0 / (Owner.Distance2D(zb) / (zb.Radius + 2)) && Owner.CheckSight(zb) && zb.cont && zb.Health > 0 && (closest == null || Owner.Distance2D(zb) < cdist)) {
					if (cdist > Owner.Distance2D(zb)) {
						cdist = Owner.Distance2D(zb);
					}

					closest = zb;
				}
			}

			if (closest && closest.cont) {
				//DebugLog(LT_VERBOSE, "Printing status for bot "..closest.cont.myName.." in state "..ZTBotController.BStateNames[closest.cont.bstate]);

				countDown = 3;

				Owner.A_Print(String.Format("\ci%s\n\cg\%i HP%s\n\cr%s\n%s\n\n%s\n\n%s\n\n%s",
					closest.cont.myName,
					closest.Health,
					DescribeFrags(closest.cont),
					DescribeTeam(closest.cont),
					DescribeTask(closest.cont),
					DescribeOrders(closest.cont),
					DescribeCommander(closest.cont),
					DescribeDebug(closest.cont)
				));

				lastShown = closest;
				printing = true;
			}

			ZTPathNode pnClosest;

			if (closest == null && CVar.FindCVar("zb_debug").GetInt() >= 2) {
				let nodeIter = ThinkerIterator.Create("ZTPathnode", 91);
				ZTPathNode pn;
				double pcdist = 256;

				while (pn = ZTPathNode(nodeIter.Next())) {
					Vector2 v1 = Owner.AngleToVector(Owner.angle);
					Vector2 v2 = Owner.Vec2To(pn) / Owner.Distance2D(pn);

					double vdot = v1 dot v2;

					if (vdot > 1 - 1 / (Owner.Distance2D(pn) / (pn.Radius + 2)) && Owner.CheckSight(pn) && (pnClosest == null || Owner.Distance2D(pn) < pcdist)) {
						if (Owner.Distance2D(pn) < pcdist) {
							pcdist = Owner.Distance2D(pn);
						}

						pnClosest = pn;
					}
				}

				if (pnClosest && pnClosest != lastShown) {
					countDown = 2;
					if (!printing) Owner.A_Print(String.Format("\ci%s Node: \cr#%i \cg(x=%d, y=%d)", ZTPathNode.ZTNavTypeNames[pnClosest.nodeType], pnClosest.id, pnClosest.pos.x, pnClosest.pos.y));
					printing = true;
					lastShown = pnClosest;
				}
			}

			if (pnClosest || closest) showing = true;

			if (!showing) {
				if (printing) Owner.A_Print("");

				printing = false;
				lastShown = null;
				countDown = 2;
			}
		}

		else
			countDown--;
	}
}
