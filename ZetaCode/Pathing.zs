class PlopResult : Thinker {
    uint totalNodes;
    Array<String> mapsFound;
    Array<String> nodeMaps;
    bool found;
}

class PathMarker : Actor {
    Default {
        Scale 0.1;
        RenderStyle "Stencil";
        StencilColor "10A8EC";
        Alpha 0.6;
        Radius 2;
        Height 2;
        Gravity 0;

        +FORCEXYBILLBOARD;
    }

    States {
        Spawn:
            MISL C 95 Bright;
            MISL C 15;

        End:
            MISL CCCDDDEEE 9 A_ScaleToRemove;
            Stop;
            
        EndFast:
            MISL CCCDDDEEE 3 A_ScaleToRemove;
            Stop;
    }

    override void BeginPlay() {
        Super.BeginPlay();

        ChangeStatNum(92);
    }

    void A_ScaleToRemove() {
        scale *= 1.2;
        alpha /= 1.4;
    }

    void RemoveEarly() {
        SetStateLabel("EndFast");
    }
}

class ZTPositionMarker : Actor {
    Default
    {
        Scale 0.4;
        Height 16;
        Radius 18;
        Alpha 0.75;
        RenderStyle "Shaded";
        StencilColor "ECA810";
        Gravity 100;
    }

    virtual void NodeCountAge(float duration) {}

    void A_NodeCountAge(int duration = 2) {
        NodeCountAge(double(duration) / 35.0);
    }

    override void Tick() {
        if ( CVar.FindCVar("zb_debug").GetInt() < 1 )
            SetStateLabel("DLoop");
        
        else {
            angle += 18;
            SetStateLabel("DVisible");
        }

        Super.Tick();
    }

    States {
        Spawn:
            NODE A 0;
            Goto DLoop;
        
        DLoop:
            TNT1 A 2 A_NodeCountAge;
            Loop;
        
        DVisible:
            NODE A 2 Bright A_NodeCountAge;
            Loop;
    }
}

class NumNodes : Thinker {
    uint value;

    NumNodes Init() {
        ChangeStatNum(STAT_INFO);
        value = 0;
        return self;
    }

    static NumNodes Get() {
        ThinkerIterator it = ThinkerIterator.Create("NumNodes", STAT_INFO);
        let p = NumNodes(it.Next());

        if (p == null) {
            p = new("NumNodes").Init();
        }

        return p;
    }

    static uint Increment() {
        NumNodes res = Get();
        return ++res.value;
    }

    static uint Decrement() {
        NumNodes res = Get();
        return --res.value;
    }

    static void Reset() {
        NumNodes res = Get();
        res.value = 0;
    }
}

class QueueItem
{
    double cost;
    ZTPathNode item;
    
    static QueueItem of(ZTPathNode item, double cost)
    {
        QueueItem r = new("QueueItem");
        r.item = item;
        r.cost = cost;
        
        return r;
    }

    static QueueItem empty() {
        QueueItem r = new("QueueItem");
        r.item = null;
        r.cost = 0;
        
        return r;
    }

    void Set(ZTPathNode item, double cost) {
        self.item = item;
        self.cost = cost;
    }
    
    void Unset() {
        self.item = null;
        self.cost = 0.0;
    }

    bool Has() {
        return self.item != null;
    }
}

class PriorityQueue {
    Array<QueueItem> heap;
    Array<int> index;
    int firstFree, lastUsed;
    int numFree;
    int numItems, size, height;

    static PriorityQueue Make() {
        PriorityQueue res = PriorityQueue(New("PriorityQueue"));

        res.size = 0;
        res.height = 0;
        res.numFree = 0;
        res.firstFree = 0;
        res.lastUsed = 0;

        res.GrowHeight();
        res.GrowHeight();

        return res;
    }

    bool Has(ZTPathNode other)
    {
        return Find(other) != -1;
    }

    int Find(ZTPathNode other) {
        while (index.Size() <= other.id) {
            index.Push(-1);
        }

        return index[other.id];
    }

    int Length() {
        // for backwards compat's sake
        return numItems;
    }

    void Swap(int a, int b) {
        let temp = heap[a];
        heap[a] = heap[b];
        heap[b] = temp;
    }

    int Depth(int which) {
        return floor(log(which + 1) / log(2));
    }

    bool ShouldSwap(int a, int b) {
        // NOTE: Depth(a) must be strictly smaller than Depth(b).
        if (Depth(a) >= Depth(b)) {
            return false;
        }

        bool has_a = heap[a].Has(), has_b = heap[b].Has();

        if (!has_b) {
            return false;
        }

        if (!has_a) {
            return true;
        }

        double cost_a = heap[a].cost;
        double cost_b = heap[b].cost;

        return cost_a > cost_b;
    }

    bool CheckSwap(int a, int b) {
        if (a > b /* otherwise no need to try Depth */ && Depth(a) > Depth(b)) {
            return CheckSwap(b, a);
        }

        if (!ShouldSwap(a, b)) {
            return false;
        }

        Swap(a, b);
        return true;
    }

    int Parent(int which) {
        which = which - 1; // because we start counting at 0
        return (which - which % 2 /* for floored division */) / 2;
    }

    void Children(int which, out int left, out int right) {
        left = which * 2 + 1;
        right = left + 1;
    }

    void GrowOne() {
        heap.Push(QueueItem.empty());
    }

    void GrowHeight() {
        int layerSize = 1 << (height++); // 2 ** height

        size += layerSize;
        numFree += layerSize;

        while (layerSize--) {
            GrowOne();
        }
    }

    void UpdateFree(int which) {
        numFree--;

        if (which > lastUsed) {
            lastUsed = which;
        }

        if (numFree <= 0) {
            GrowHeight();
            return;
        }

        if (firstFree <= which) {
            do {
                firstFree++;
            } while (firstFree < size && heap[firstFree].Has());
        }

        numItems++;
    }

    void SetAt(int which, ZTPathNode item, double cost) {
        heap[which].Set(item, cost);
    }

    void UnsetAt(int which) {
        if (!heap[which].Has()) {
            return;
        }

        let item = heap[which].item;

        heap[which].unSet();

        /*SiftDown(which);
        SiftDown(which);

        numItems--;*/
    }

    int SetFree(ZTPathNode item, double cost) {
        int which = firstFree;

        SetAt(which, item, cost);
        UpdateFree(which);

        return which;
    }

    void SiftUp(int which) {
        while (which > 0 && CheckSwap(Parent(which), which)) {
            which = Parent(which);
        }
    }

    void SiftDown(int which) {
        int child1, child2, childSwap = -1;

        do {
            if (childSwap != -1) {
                which = childSwap;
            }

            if (which * 2 + 1 >= size /* already bottom layer */) {
                return;
            }

            Children(which, child1, child2);

            if (heap[child1].cost < heap[child2].cost) {
                childSwap = child1;
            }

            else {
                childSwap = child2;
            }
        } while (CheckSwap(which, childSwap));
    }

    double GetCost(ZTPathNode item) {
        int index = Find(item);
        return heap[index].cost;
    }

    void UpdateCost(int which, double newCost) {
        double oldCost = heap[which].cost;

        if (newCost == oldCost) {
            return;
        }

        heap[which].cost = newCost;

        if (newCost < oldCost) {
            SiftDown(which);
        }

        else {
            SiftUp(which);
        }
    }

    void Add(ZTPathNode item, double cost) {
        int existing = Find(item);

        if (existing != -1) {
            UpdateCost(existing, cost);

            return;
        }
        
        SetFree(item, cost);
    }

    void ReplaceRoot() {
        Swap(0, lastUsed);
        UnsetAt(lastUsed);

        if (firstFree > lastUsed) {
            firstFree = lastUsed;
        }

        if (lastUsed > 0) {
            do {
                lastUsed--;
            } while (lastUsed >= 0 && !heap[lastUsed].has());
        }

        SiftDown(0);

        numItems--;
    }

    ZTPathNode, double Poll() {
        if (!heap[0].Has()) {
            numItems = 0;
            return null, 0;
        }

        ZTPathNode item = heap[0].item;
        double cost = heap[0].cost;

        ReplaceRoot();

        return item, cost;
    }

    ZTPathNode, double Peek() {
        if (!heap[0].Has()) {
            return null, 0;
        }

        return heap[0].item, heap[0].cost;
    }
}

class ZTPathNode : ZTPositionMarker
{
    enum NavigationType
    {
        NT_NORMAL = 0,
        NT_USE,
        NT_SLOW,
        NT_CROUCH,
        NT_JUMP,
        NT_AVOID,
        NT_CANDY,
        NT_CANDY_ONCE,
        NT_SHOOT,
        NT_RESPAWN,
        NT_TARGET,
        NT_TELEPORT_SOURCE,
        NT_BLOCK,
    };

    double age;

    override void NodeCountAge(float duration) {
        if (nodeType != NT_TARGET) {
            return;
        }

        age += duration;

        if (age > 25) {
            Destroy();
        }
    }

    static string StencilColorForType(NavigationType navType) {
        if (navType == NT_NORMAL)
            return "20E020";

        if (navType == NT_RESPAWN)
            return "502018";

        if (navType == NT_SLOW)
            return "108810";

        if (navType == NT_CROUCH)
            return "008038";

        if (navType == NT_JUMP)
            return "801000";

        if (navType == NT_USE)
            return "F0F0CC";

        if (navType == NT_AVOID)
            return "208000";

        if (navType == NT_SHOOT)
            return "9000C0";

        if (navType == NT_CANDY)
            return "F01090";
        
        if (navType == NT_CANDY_ONCE)
            return "F04090";

        if (navType == NT_TARGET)
            return "101028";

        if (navType == NT_BLOCK)
            return "301000";

        if (navType == NT_TELEPORT_SOURCE)
            return "1030D0";

        return "000000"; // heck
    }

    override void Tick() {
        Super.Tick();

        if (colorSetup == -1 || colorSetup != nodeType) {
            SetShade(StencilColorForType(nodeType));
            colorSetup = nodeType;
        }
    }

    static const string ZTNavTypeNames[] = {
        "Normal",
        "Use",
        "Slow",
        "Crouch",
        "Jump",
        "Avoid",
        "Candy",
        "Candy Once",
        "Shoot",
        "Respawn",
        "Target",
        "Teleport Source",
        "Block"
    };

    enum LogType
    {
        LT_ERROR = 0,
        LT_WARNING,
        LT_INFO,
        LT_VERBOSE
    };

    void DebugLog(LogType kind, string msg)
    {
        if ( CVar.FindCVar("zb_debug").GetInt() > 0 )
        {
            string logHeader = "";
    
            if ( kind == LT_ERROR )
                logHeader = "\cr[ERROR]";
            
            else if ( kind == LT_WARNING )
                logHeader = "\cf[WARNING]";
                
            else if ( kind == LT_INFO )
                logHeader = "\ch[INFO]";
            
            else if ( kind == LT_VERBOSE )
            {
                if ( CVar.FindCVar("zb_debug").GetInt() > 1 )
                    logHeader = "\cd[VERBOSE]";
            
                else
                    return;
            }
    
            A_Log("\cq[ZetaBot] "..logHeader.." "..msg);
        }
    }

    NavigationType nodeType;
    NavigationType colorSetup;
    double useDirection;
    bool bPlopped;
    uint id;
    uint assoc_id;
    Array<uint> candied;


    override void BeginPlay()
    {
        Super.BeginPlay();

        age = 0.0;
        colorSetup = -1;
    
        id = NumNodes.Increment();
        ChangeStatNum(91);

        assoc_id = 0;
    }

    override void PostBeginPlay()
    {
        super.PostBeginPlay();
    
        DebugLog(LT_VERBOSE, String.format("Created node #%i at x=%f,y=%f", id, pos.x, pos.y));
    }

    static int sindex(String full, String sub)
    {
        uint i = 0;
        uint max_pos = full.Length() - sub.Length();

        while (i <= max_pos) {
            if (full.Mid(i, sub.Length()) == sub) {
                return i;
            }

            else {
                i++;
            }
        }
        
        return -1;
    }

    string serialize()
    {
        return int(pos.x)..","..int(pos.y)..","..int(pos.z)..","..nodeType..","..int(useDirection)..","..assoc_id;
    }

    static string serializeAll(ActorList allNodes)
    {
        String res = level.mapname.."::";
    
        allNodes.iReset();
        ZTPathNode node;
    
        while ( node = ZTPathNode(allNodes.iNext()) )
            res = res..node.serialize()..":";
        
        return res;
    }

    static string serializeLevel()
    {
        let iter = ThinkerIterator.create("ZTPathNode", 91);
        ActorList list = new("ActorList");
    
        ZTPathNode node = null;
    
        while ( node = ZTPathNode(iter.Next()) )
            if (node.nodeType != NT_TARGET)
                list.push(node);
        
        let res = serializeAll(list);
        list.Destroy(); // clean actorlists after use

        return res;
    }

    static String split(string other, string sep, uint index)
    {
        String res = "";
        uint si = 0;
        uint i = 0;

        while ( i < other.Length() )
        {
            if ( other.Mid(i, sep.Length()) == sep )
            {
                if ( si++ == index )
                    return res;
            
                i += sep.Length();
            }
            
            else
            {
                if ( si == index )
                    res = res..other.CharAt(i);
            
                i++;
            }
        }
    
        if ( si == index )
            return res;
    
        return "";
    }

    static int pow(int x, int n)
    {
        int cn = n;
        int y = 1;
        
        while (cn-- > 0) y *= x;
        return y;
    }

    static int SInt(String s)
    {
        int num = 0;
        uint i = 0;
        int sign = 1;
    
        while ( s.Left(1) == "-" )
        {
            sign *= -1;
            s = s.Mid(1);
        }
    
        while ( i < s.Length() )
        {
            int code = s.CharCodeAt(i);
    
            if ( code < 48 || code > 57 ) // Numeric ASCII codes.
                return 0;
        
            num += (code - 48) * pow(10, s.Length() - ++i);
        }
    
        return num * sign;
    }

    static PlopResult plopNodes(string code)
    {
        uint i = 0;
        string c, levelMap = "", ncode;
        let res = new("PlopResult");
    
        if (code == "::NONE" || code == "")
            return res;
        
        while (true)
        {
            string cmap = split((c = split(code, ";;", i++)), "::", 0);

            if (cmap == "") {
                if (levelMap == "")
                    return res;

                else
                    break;
            }

            res.mapsFound.Push(cmap);
            res.nodeMaps.Push(c);
    
            if (c == "")
                return res;

            if (cmap.MakeUpper() == level.mapName.MakeUpper())
                levelMap = split(c, "::", 1);
        }

        res.found = true;
        i = 0;
    
        for (i = 0; (ncode = split(levelMap, ":", i)) != ""; i++)
        {
            double nx = SInt(split(ncode, ",", 0));
            double ny = SInt(split(ncode, ",", 1));
            double nz = SInt(split(ncode, ",", 2));
            NavigationType nt = SInt(split(ncode, ",", 3));
            double ud = SInt(split(ncode, ",", 4));
            int as = SInt(split(ncode, ",", 5));
        
            let node = ZTPathNode(Spawn("ZTPathNode", (nx, ny, nz)));
            node.nodeType = nt;
            node.bPlopped = true;
        
            node.useDirection = ud;
            node.angle = ud;
            node.assoc_id = as;
        
            res.totalNodes++;
        }
    
        return res;
    }

    void BecomesCurrent(ZTBotController cont, Actor other) {
        if (nodeType == NT_CANDY_ONCE) {
            candied.Push(cont.BotID);
        }
    }

    double SpecialCost(ZTPathNode from, ZTPathNode goal, actor Other, ZTBotController cont) // mimicks UT99's NavigationPoint.SpecialCost(Pawn Other)
    {
        if ( nodeType == NT_AVOID )
            return 1024;

        else if ( nodeType == NT_CANDY || (nodeType == NT_CANDY_ONCE && candied.Find(cont.BotID) < candied.Size()) )
            return -1024;

        else if ( nodeType == NT_TELEPORT_SOURCE && from )
            return 64 - Distance3D(from);

        return (pos.z - from.pos.z) * (pos.z- from.pos.z) / 50;
    }

    ActorList NeighborsOutward()
    {
        ThinkerIterator iter = ThinkerIterator.create("ZTPathNode", 91);
        ZTPathNode node = null;
        let preRes = new("ActorList");
        let res = new("ActorList");

        while ( ( node = ZTPathNode(iter.Next()) ) != null )
            if ( canConnect(node) ) {
                preRes.Push(node);
            }
    
        for ( uint i = 0; i < preRes.Length(); i++ ) {
            ZTPathNode preNeigh = ZTPathNode(preRes.get(i));

            if ( postCanConnect(preNeigh, preRes) )
                res.Push(preNeigh);
        }
        
        preRes.Destroy(); // clean actorlists after use
    
        return res;
    }

    ActorList NeighborsInward()
    {
        ThinkerIterator iter = ThinkerIterator.create("ZTPathNode", 91);
        ZTPathNode node = null;
        let preRes = new("ActorList");
        let res = new("ActorList");

        while ( ( node = ZTPathNode(iter.Next()) ) != null )
            if ( node.canConnect(self) ) {
                preRes.Push(node);
            }
    
        for ( uint i = 0; i < preRes.Length(); i++ ) {
            ZTPathNode preNeigh = ZTPathNode(preRes.get(i));

            if ( postCanConnect(preNeigh, preRes) )
                res.Push(preNeigh);
        }

        preRes.Destroy(); // clean actorlists after use
    
        return res;
    }

    String NodeName() {
        return String.Format("#%i (x=%f,y=%f)", id, pos.x, pos.y);
    }

    ZTPathNode RandomNeighbor()
    {
        ActorList nb = NeighborsOutward();
    
        if ( nb.Length() < 1 )
            return self;
    
        let res = ZTPathNode(nb.get(Random(0, nb.Length() - 1)));
        nb.Destroy(); // clean actorlists after use
        
        return res;
    }
    
    ZTPathNode RandomNeighborRoughlyToward(Vector2 direction, double preference = 1.0)
    {
        ActorList nb = NeighborsOutward();
        ZTPathNode res;
        
        if (direction.Length() == 0) {
            return RandomNeighbor();
        }
        
        direction = direction.Unit();
        preference /= 2.0; // due to how dot products work
        
        A_Log(""..direction);
    
        if ( nb.Length() < 1 )
            return self;
            
        Array<double> weights;
        double total = 0.0;
        
        A_Log(""..direction);
        
        ZTPathnode neigh;
        for (nb.iReset(), neigh = ZTPathNode(nb.iNext()); neigh; neigh = ZTPathNode(nb.iNext())) {
            if (neigh == self) {
                continue;
            }
            A_Log("--");
            A_Log(""..direction);
            Vector2 offs = neigh.pos.xy - pos.xy;
            offs = offs.Unit();
            double directionality = 1 + (1 + offs dot direction) * preference;
            A_Log(offs.." "..direction);
            weights.push(directionality);
            total += directionality;
        }
        
        // weighted random
        double choice = FRandom(0, total);
        
        for (int i = 0; i < weights.Size(); i++) {
            if (choice < weights[i]) {
                res = ZTPathNode(nb.Get(i));
                break;
            }
            
            choice -= weights[i];
        }
    
        nb.Destroy(); // clean actorlists after use
        
        return res;
    }

    void ShowPath(ZTPathNode otherNode) {
        uint segRes = 24; // constant
        uint numSegs = ceil(Distance3D(otherNode) / segRes);
        uint fringeSegs = 4;
        double fringeSize = 9;
        double fringeAngle = 45;
        double fringeDotScale = 0.8;

        // regular offsets
        Vector3 offs = otherNode.pos - pos;

        // arrow fringe directions
        Vector3 fringeDir1,fringeDir2;
        fringeDir1.xy = AngleToVector(othernode.AngleTo(self) - fringeAngle);
        fringeDir2.xy = AngleToVector(othernode.AngleTo(self) + fringeAngle);

        // main arrow trunk
        for (uint seg = 0; seg < numSegs; seg++) {
            double alpha = 1.0 * seg / numSegs;
            Vector3 pmPos = pos + offs * alpha;

            PathMarker pm = PathMarker(Spawn("PathMarker", pmPos));
            //pm.pos.z = pm.floorz;
        }

        // arrow fringes
        for (uint seg = 0; seg < fringeSegs; seg++) {
            double distance = 1.0 * (seg + 1) / fringeSegs * fringeSize;

            Vector3 pmPos1 = otherNode.pos + fringeDir1 * distance;
            Vector3 pmPos2 = otherNode.pos + fringeDir2 * distance;

            PathMarker pm1 = PathMarker(Spawn("PathMarker", pmPos1));
            PathMarker pm2 = PathMarker(Spawn("PathMarker", pmPos2));

            pm1.scale *= fringeDotScale;
            pm2.scale *= fringeDotScale;
        }
    }

    void ShowAllPaths() {
        ActorList nb = NeighborsOutward();

        for (uint i = 0; i < nb.Length(); i++) {
            ZTPathNode neigh = ZTPathNode(nb.Get(i));
            ShowPath(neigh);
        }

        nb.Destroy(); // clean actorlists after use
    }

    ActorList findPathTo(ZTPathNode goal, ZTBotController controller)
    {
        Actor traveller = controller.possessed;

        let res = ActorList.Empty();
        int itersLeft = 5000; // safety limit

        res.push(self);

        if ( goal == null || goal == self )
        {
            return res;
        }

        Array<double> icosts, totcosts;
        Array<ZTPathNode> cameFrom;
        PriorityQueue openSet = PriorityQueue.Make();
        Array<bool> closedSet;

        while (closedSet.Size() < id) {
            closedSet.Push(false);
        }
    
        bool foundGoal = false;
    
        while (icosts.Size() <= self.id) {
            icosts.Push(0.0);
        }

        openSet.add(self, 0);
    
        DebugLog(LT_VERBOSE, String.Format("> Pathfinding from %s to %s", NodeName(), goal.NodeName()));

        while (openSet.numItems > 0 && itersLeft)
        {
            ZTPathNode current = ZTPathNode(openSet.poll());
            itersLeft--;
             
            if (current == null) {
                DebugLog(LT_WARNING, String.Format(
                    "Open set has no root node but numItems is non-zero! (firstFree %i lastUsed %i numFree %i numItems %i size %i height %i)",
                    openSet.firstFree, openSet.lastUsed, openSet.numFree, openSet.numItems, openSet.size, openSet.height
                ));
                break;
            }

            if (current.id < closedSet.Size() && closedSet[current.id]) {
                continue;
            }

            double thisICost = icosts[current.id];

            //DebugLog(LT_VERBOSE, String.Format("+-- Iterating pathfinding for node: %s", current.NodeName()));
            ActorList nb = current.NeighborsOutward();
    
            for ( uint i = 0; i < nb.Length(); i++ ) {
                ZTPathNode neigh = ZTPathNode(nb.get(i));
                //DebugLog(LT_VERBOSE, String.Format("+-+-- Considering #%i's neighbor: %s", current.id, neigh.NodeName()));

                if (neigh == current) {
                    continue;
                }

                if (closedSet.Size() > neigh.id && closedSet[neigh.id]) {
                    continue;
                }

                double icost = thisICost + current.Distance3D(neigh) + current.SpecialCost(neigh, goal, traveller, controller);
                double cost = neigh.Distance3D(goal) * 2 + icost;

                //A_Log("icost for "..current.id.."->"..neigh.id.." went from "..thisICost.." to "..icost.." | tot cost = "..cost);

                if (neigh.id < totCosts.Size() && totCosts[neigh.id] != -1.0 && totCosts[neigh.id] <= cost) {
                    continue;
                }

                while (cameFrom.Size() <= neigh.id) {
                    cameFrom.push(null);
                }

                cameFrom[neigh.id] = current;
        
                while (icosts.Size() <= neigh.id) {
                    icosts.Push(-1.0);
                }

                while (totcosts.Size() <= neigh.id) {
                    totcosts.Push(-1.0);
                }

                icosts[neigh.id] = icost;
                totcosts[neigh.id] = cost;
                openSet.add(neigh, cost);

                if (neigh == goal)
                {
                    DebugLog(LT_VERBOSE, String.Format("  '-- # Goal node #%i found!", neigh.id));
                    foundGoal = true;
                    break;
                }
            }

            nb.Destroy(); // clean actor lists after use

            if (foundGoal) {
                break;
            }

            while (closedSet.Size() <= current.id) {
                closedSet.Push(false);
            }
            closedSet[current.id] = true;
        }
    
        if ( !foundGoal ) {
            if (itersLeft == 0)
                DebugLog(LT_WARNING, String.Format("Infinite recursion attempting to find a path betwen %s and %s", NodeName(), goal.NodeName()));

            else
                DebugLog(LT_INFO, String.Format("Failed to find a valid path between %s and %s.", NodeName(), goal.NodeName()));

            return null;
        }
        
        ZTPathNode cur = goal;
        ZTPathNode pcur;
    
        res.clear();

        do {
            if (cur == null) {
                break;
            }

            res.insert(0, cur);
            pcur = cur;
            cur = cameFrom[cur.id];

            // DebugLog(LT_VERBOSE, String.Format("%i -> %i", (cur == null ? -1 : cur.id), (pcur == null ? -1 : pcur.id)));

            if (pcur == cur) {
                break;
            }
        } while (cur != self);

        res.insert(0, self);
    
        if (CVar.FindCVar("zb_debug").GetInt() > 0) {
            string nodepath = "";
            ZTPathNode node;

            res.iReset();
            while (node = ZTPathNode(res.iNext())) {
                nodepath = nodepath..(nodepath == "" ? "" : " -> ")..node.NodeName();
            }
            res.iReset();

            DebugLog(LT_INFO, String.format("Found a %i-node path: %s", (res.Length()), nodepath));
        }

        if (CVar.FindCVar("zb_debug").GetInt() > 2) {
            ZTPathNode node, prev = null;

            res.iReset();
            while (node = ZTPathNode(res.iNext())) {
                if (prev != null) {
                    prev.ShowPath(node);
                }
                prev = node;
            }
            res.iReset();
        }

        openSet.Destroy();

        res.Remove(0);
    
        return res;
    }

    static ZTPathNode plopNode(Vector3 position, NavigationType nt, float angle = 0)
    {
        let node = ZTPathNode(Spawn("ZTPathNode", position));
        node.nodeType = nt;
        node.angle = angle;
    
        return node;
    }

    bool PostCanConnect(ZTPathNode next, ActorList preNeighbors)
    {
        ZTPathNode pn = null;

        if (nodeType == NT_TELEPORT_SOURCE)
            return true;

        let dist = Distance2D(next);
        let off1 = Vec2To(next) / Distance2D(next);

        double minCullLimit     = 0.5;
        double maxCullLimit     = 0.9;
        double cullPostScale    = maxCullLimit - minCullLimit;
        double cullPreScale     = 512;
    
        for ( uint i = 0; i < preNeighbors.Length(); i++ )
        {
            ZTPathNode pn = ZTPathNode(preNeighbors.get(i));
            let dist2 = Distance2D(pn); 
        
            if (CheckSight(pn) && pn != self && pn != next && dist2 < dist - 64) {
                let off2 = Vec2To(pn) / dist2;

                //A_Log((dist2 / cullPreScale).." -> "..(off1 dot off2).." > "..minCullLimit + ((1.0 / (1.0 + exp(-(dist2 / cullPreScale)))) * 2 - 1.0) * cullPostScale);

                if (off1 dot off2 > minCullLimit + ((1.0 / (1.0 + exp(-(dist2 / cullPreScale)))) * 2 - 1.0) * cullPostScale) {
                    return false; // there is already a shorter path in the same
                                  // practical direction
                }
            }
        }

        return true;
    }

    bool CanConnect(ZTPathNode next)
    {
        if (nodeType == NT_BLOCK || next.nodeType == NT_BLOCK)
            return false;
    
        if (nodeType == NT_TELEPORT_SOURCE)
            return next.id == assoc_id;
    
        if ( next == null )
            return false;

        if ((nodeType == NT_USE || next.nodeType == NT_USE) && Distance2D(next) < 80)
            return true; // for doors that block LOS but are traverseable, etc.

        double maxZDiff = 24;
        double minDist = 64;
        double maxHDist = 2048;
        double dist2 = Distance2D(next);

        if (dist2 < 1.0) 
            dist2 = 1.0;
        
        double diffZ = (next.pos.z - pos.z) * 16 / dist2;

        if ( dist2 > maxHDist )
            return false;

        if ( next.nodeType == NT_JUMP || nodeType == NT_JUMP ) {
            maxZDiff = 60;
            maxHDist = 256;
        }
        
        if ( next.nodeType == NT_SLOW || nodeType == NT_SLOW || next.nodeType == NT_CROUCH || nodeType == NT_CROUCH ) {
            minDist = 20;
            maxHDist = 1024;
        }
        
        else if ( next.nodeType == NT_USE || nodeType == NT_USE ) {
            minDist = 2;
            maxZDiff = 16;
        }
        
        minDist -= abs(next.pos.z - pos.z) * 0.5;
    
        if ( minDist <= 0 )
            return false;
        
        if ( Distance3D(next) < minDist )
            return false;

        if ( diffZ > 0 && dist2 > 32 && diffZ > maxZDiff ) // nearby nodes can link despite height differences, for steep ladders and the like
            return false;
    
        // experimental
        /*
        if (CheckBlock(
            xofs: next.pos.x - pos.x,
            yofs: next.pos.y - pos.y,
            zofs: next.pos.z - pos.z,
            angle: AngleTo(next)
        )) return false;
        */

        if (!CheckSight(next)) {
        /*
            FLineTraceData sight;
            LineTrace(AngleTo(next), Distance2D(next), PitchTo(next, 40), TRF_THRUACTORS | TRF_THRUHITSCAN, 40, data: sight);

            if (sight.HitType == TRACE_HITWALL)
        */
            return false;
        }

        return true;
    }

    double PitchTo(Actor other, double offsZ = 0) {
        if (other == null)
            return 0;

        if (other.pos.z + other.height / 2 == pos.z + height / 2 + offsZ) return 0;

        //return offsZ + other.pos.z + other.height / 2 - pos.z - height / 2;
        return tan(offsZ + other.pos.z + other.height / 2 - pos.z - height / 2);
    }
}

class ZTNodeSpawner : Actor abstract {
    const summonDist = 56;

    abstract void ConfigNode(ZTPathNode node);

    override void PostBeginPlay() {
        let node = ZTPathNode(Spawn("ZTPathNode", Vec3Angle(-summonDist, angle)));
        node.angle = angle;

        ConfigNode(node);
        Destroy();
    }
}   

class ZTNormalNode : ZTNodeSpawner
{
    override void ConfigNode(ZTPathNode node)
    {
        node.nodeType = ZTPathNode.NT_NORMAL;
    }
}

class ZTUseNode : ZTNodeSpawner
{
    override void ConfigNode(ZTPathNode node)
    {
        node.nodeType = ZTPathNode.NT_USE;
        node.useDirection = angle;
    }
}

class ZTJumpNode  : ZTNodeSpawner
{
    override void ConfigNode(ZTPathNode node)
    {
        node.nodeType = ZTPathNode.NT_JUMP;
    }
}

class ZTSlowNode  : ZTNodeSpawner
{
    override void ConfigNode(ZTPathNode node)
    {
        node.nodeType = ZTPathNode.NT_SLOW;
    }
}

class ZTCrouchNode  : ZTNodeSpawner
{
    override void ConfigNode(ZTPathNode node)
    {
        node.nodeType = ZTPathNode.NT_CROUCH;
    }
}

class ZTShootNode  : ZTNodeSpawner
{
    override void ConfigNode(ZTPathNode node)
    {
        node.nodeType = ZTPathNode.NT_SHOOT;
    }
}


class ZTAvoidNode  : ZTNodeSpawner
{
    override void ConfigNode(ZTPathNode node)
    {
        node.nodeType = ZTPathNode.NT_AVOID;
    }
}

class ZTBlockNode  : ZTNodeSpawner
{
    override void ConfigNode(ZTPathNode node)
    {
        node.nodeType = ZTPathNode.NT_BLOCK;
    }
}

class ZTTeleportToNextNode  : ZTNodeSpawner
{
    override void ConfigNode(ZTPathNode node)
    {
        node.nodeType = ZTPathNode.NT_TELEPORT_SOURCE;
        node.assoc_id = node.id + 1; // next node
    }
}

class ZTTeleportToPrevNode  : ZTNodeSpawner
{
    override void ConfigNode(ZTPathNode node)
    {
        node.nodeType = ZTPathNode.NT_TELEPORT_SOURCE;
        node.assoc_id = node.id - 1; // previous node
    }
}

class ZTCandyNode  : ZTNodeSpawner
{
    override void ConfigNode(ZTPathNode node)
    {
        node.nodeType = ZTPathNode.NT_CANDY;
    }
}

class ZTCandyOnceNode  : ZTNodeSpawner
{
    override void ConfigNode(ZTPathNode node)
    {
        node.nodeType = ZTPathNode.NT_CANDY_ONCE;
    }
}

class ZTRespawnNode : ZTNodeSpawner
{
    override void ConfigNode(ZTPathNode node)
    {
        node.nodeType = ZTPathNode.NT_RESPAWN;
    }
}

class ZTUploadNodes : Actor
{
    enum LogType
    {
        LT_ERROR = 0,
        LT_WARNING,
        LT_INFO,
        LT_VERBOSE
    };

    void DebugLog(LogType kind, string msg)
    {
        if ( CVar.FindCVar("zb_debug").GetInt() > 0 )
        {
            string logHeader = "";
    
            if ( kind == LT_ERROR )
                logHeader = "\cr[ERROR]";
            
            else if ( kind == LT_WARNING )
                logHeader = "\cf[WARNING]";
            
            else if ( kind == LT_INFO )
                logHeader = "\ch[INFO]";
            
            else if ( kind == LT_VERBOSE )
            {
                if ( CVar.FindCVar("zb_debug").GetInt() > 1 )
                    logHeader = "\cd[VERBOSE]";
            
                else
                    return;
            }
    
            A_Log("\cq[ZetaBot] "..logHeader.." "..msg);
        }
    }

    override void BeginPlay()
    {
        //String code = ZTPathNode.uploadLevel();
        uploadLevel(CVar.FindCVar("zb_nodevar").GetString());
        // A_PrintBold("'"..code.."'");
    
        Destroy();
    }
    
    void uploadLevel(String cvName)
    {
        if (CVar.FindCVar(cvName) == null)
            return;

        String code = CVar.FindCVar(cvName).GetString();
        String new_serialized = ZTPathNode.serializeLevel();
        
        if ( code == "::NONE" || code == "" ) {
            DebugLog(LT_VERBOSE, "Empty node list detected; replacing with single entry for "..level.mapName.MakeUpper());
            code = ZTPathNode.serializeLevel();
        }
    
        else {
            String c = "";
            uint i = 0;
    
            while ( true ) {
                c = ZTPathNode.split(code, ";;", i++);
        
                if ( ZTPathNode.split(c, "::", 0).MakeUpper() == level.mapName.MakeUpper()) {
                    break;
                }
                
                if ( c == "" ) {
                    DebugLog(LT_VERBOSE, "Node list exists but entry not found for "..level.mapName.MakeUpper().."; appended to nodes list at index "..code.Length());
                    
                    code = code..";;"..new_serialized;

                    break;
                }
            }

            if (c != "") {
                int old_length = c.Length();
                int new_length = new_serialized.Length();

                int ind = ZTPathNode.sindex(code, c);
                int ind2 = ind + old_length;
                int ind3 = ind + new_length;

                if (ind == -1) {
                    DebugLog(LT_ERROR, "Could not save level node list: existing entry for "..level.mapName.MakeUpper().." found, but its index could not be determined!");
                    return;
                }

                String left = code.Left(ind);
                String right = code.Mid(ind2);
            
                code = left..new_serialized..right;

                DebugLog(LT_VERBOSE, "Overrode existing entry for "..level.mapName.MakeUpper().." in nodes list between indices "..ind.." and "..ind2.."; now it spans from the original start till index "..ind3);
            }
        }

        CVar.FindCVar(cvName).SetString(code);
    }
}

class ZTBackspaceNode : Actor {
    override void BeginPlay() {
        ZTPathNode last, n;
        let iter = ThinkerIterator.Create("ZTPathNode", 91);
    
        while ( n = ZTPathNode(iter.Next()) ) {
            if (!last || n.id > last.id) {
                last = n;
            }
        }

        if (last != null) {
            A_Log("Deleted node #"..last.id);
            last.Destroy();
        }

        NumNodes.Decrement();

        Destroy();
    }
}

class ZTPromptNodes : Actor
{
    bool CheckLumpName(int lump, string name) {
        //A_Log(String.Format("%i -> %s = %i", lump, name, Wads.FindLump(name, lump, 1)));
        return Wads.FindLump(name, lump, 1) == lump;
    }

    enum LogType
    {
        LT_ERROR = 0,
        LT_WARNING,
        LT_INFO,
        LT_VERBOSE
    };

    void DebugLog(LogType kind, string msg)
    {
        if ( CVar.FindCVar("zb_debug").GetInt() > 0 )
        {
            string logHeader = "";
    
            if ( kind == LT_ERROR )
                logHeader = "\cr[ERROR]";
            
            else if ( kind == LT_WARNING )
                logHeader = "\cf[WARNING]";
            
            else if ( kind == LT_INFO )
                logHeader = "\ch[INFO]";
            
            else if ( kind == LT_VERBOSE )
            {
                if ( CVar.FindCVar("zb_debug").GetInt() > 1 )
                    logHeader = "\cd[VERBOSE]";
            
                else
                    return;
            }
    
            A_Log("\cq[ZetaBot] "..logHeader.." "..msg);
        }
    }

    PlopResult ReadZBNodes() {
        for (int startLump = Wads.FindLump(level.mapname, 0, 1); startLump != -1; startLump = Wads.FindLump(level.mapname, startLump + 1, 1)) {
            int mapLump = startLump + 1;

            CheckLumpName(mapLump, level.mapname);
            while (
                CheckLumpName(mapLump, "THINGS") ||
                CheckLumpName(mapLump, "LINEDEFS") ||
                CheckLumpName(mapLump, "SIDEDEFS") ||
                CheckLumpName(mapLump, "VERTEXES") ||
                CheckLumpName(mapLump, "SEGS") ||
                CheckLumpName(mapLump, "SSECTORS") ||
                CheckLumpName(mapLump, "NODES") ||
                CheckLumpName(mapLump, "SECTORS") ||
                CheckLumpName(mapLump, "REJECT") ||
                CheckLumpName(mapLump, "BLOCKMAP") ||
                CheckLumpName(mapLump, "BEHAVIOR") ||
                CheckLumpName(mapLump, "SCRIPTS") ||
                CheckLumpName(mapLump, "ENDMAP") ||
                CheckLumpName(mapLump, "ZNODES") ||
                CheckLumpName(mapLump, "TEXTMAP")
            ) {
                if (CheckLumpName(++mapLump, "ZBMNODES"))
                    break;
            }

            if (!CheckLumpName(mapLump, "ZBMNODES"))
                continue;

            A_Log(String.Format("Found ZBMNODES for %s @ %i", level.mapname, mapLump));

            return ZTPathNode.plopNodes(Wads.ReadLump(mapLump));
        }

        A_Log(String.Format("No map-local ZBMNODES lump found for %s, looking for fallback ZBNODES lumps...", level.mapname));

        for (int nodesLump = Wads.FindLump("ZBNODES", 0, 1); nodesLump != -1; nodesLump = Wads.FindLump("ZBNODES", nodesLump + 1, 1)) {
            A_Log(String.Format("Trying ZBNODES lump @ %i..", nodesLump));
            
            let res = ZTPathNode.plopNodes(Wads.ReadLump(nodesLump));

            if (res.found) {
                A_Log(String.Format("Found nodes definitions for %s successfully!", level.mapname));
                return res;
            };
        }

        A_Log(String.Format("Could not find any nodes for %s at either its ZBMNODES or any ZBNODES lumps. Giving up.", level.mapname));

        return null;
    }

    override void BeginPlay()
    {
        ZTPathNode n;
        let iter = ThinkerIterator.Create("ZTPathNode", 91);
    
        while ( n = ZTPathNode(iter.Next()) )
            n.Destroy();

        NumNodes.Reset();
    
        cvar cv = CVar.FindCVar(CVar.FindCVar("zb_nodevar").GetString());
    
        PlopResult r;

        if ( cv == null )
        {
            if (!(r = ReadZBNodes())) return;
        }
    
        else {
            r = ZTPathNode.plopNodes(cv.GetString());

            if (r.totalNodes == 0) {
                r = ReadZBNodes();

                if (!r || !r.found) {
                    string lst = String.format(
                        "No nodes found (\"%s\")! %s maps found", level.mapName.MakeUpper(),
                        (r != null) ?
                            ( ""..r.mapsFound.Size(0)) :
                            "No"
                    );

                    if (r != null) {
                        for ( uint i = 0; i < r.mapsFound.Size(); i++ ) {
                            lst = lst.."  \""..r.mapsFound[i].."\"";
                        }
                    }

                    A_Log(lst);
                    Destroy();
                    
                    return;
                }
            }
        }

        string lst = r.totalNodes.." nodes plopped! "..r.mapsFound.Size().." maps found in nodelist:";
    
        for ( uint i = 0; i < r.mapsFound.Size(); i++ )
            lst = lst.."  \""..r.mapsFound[i].."\"";

        A_Log(lst);
        Destroy();
    }
}

class ZTDeleteNodes : Actor
{
    override void BeginPlay()
    {
        ZTPathNode n;
        let iter = ThinkerIterator.Create("ZTPathNode", 91);
        String logged = "Deleted %u nodes.";
        uint count = 0;
    
        while ( n = ZTPathNode(iter.Next()) ) {
            n.Destroy();
            count++;
        }

        NumNodes.Reset();

        A_Log(String.Format(logged, count));
        Destroy();
    }
}

class ZTShowAllPaths : Actor {
    override void BeginPlay() {
        // remove previous path markers if any
        ThinkerIterator it = ThinkerIterator.Create("PathMarker", 92);
        PathMarker p;
        
        while ((p = PathMarker(it.Next())) != null) {
            p.RemoveEarly();
        }

        // show all outgoing paths from every single pathnode
        ZTPathNode n;
        let iter = ThinkerIterator.Create("ZTPathNode", 91);
    
        while (n = ZTPathNode(iter.Next()))
            n.ShowAllPaths();

        Destroy();
    }
}
