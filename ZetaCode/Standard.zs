class QueueItem
{
	double cost;
	Object item;
	
	static QueueItem of(Object item, double cost)
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

	void Set(Object item, double cost) {
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
	int firstFree, lastUsed;
	int numFree;
	int numItems, size, height;

	static PriorityQueue Make(String hasherType, int numBuckets = 32) {
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

	bool Has(Object other)
	{
		return Find(other) != -1;
	}

	int Find(Object other) {
		QueueItem qi;
		uint i = 0;

		while (i < heap.Size()) {
			qi = heap[i++];
			if (qi.item == other) {
				return i;
			}
		}

		return -1;
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

		return cost_a < cost_b;
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

	void SetAt(int which, Object item, double cost) {
		heap[which].Set(item, cost);
	}

	void UnsetAt(int which) {
		if (!heap[which].Has()) {
			return;
		}

		let item = heap[which].item;

		heap[which].unSet();

		/*SiftDown(which);
		SiftUp(which);

		numItems--;*/
	}

	int SetFree(Object item, double cost) {
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

	double GetCost(Object item) {
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
			SiftUp(which);
		}

		else {
			SiftDown(which);
		}
	}

	void Add(Object item, double cost) {
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

	Object, double Poll() {
		if (!heap[0].Has()) {
			numItems = 0;
			return null, 0;
		}

		Object item = heap[0].item;
		double cost = heap[0].cost;

		ReplaceRoot();

		return item, cost;
	}

	Object, double Peek() {
		if (!heap[0].Has()) {
			return null, 0;
		}

		return heap[0].item, heap[0].cost;
	}
}

class OldPriorityQueue
{
	Array<QueueItem> queue;
	
	void add(Object item, double cost)
	{
		uint i = 0;
	
		for ( i = 0; i < queue.Size() && queue[i].cost < cost; i++ )
			continue;
			
		if ( i == queue.Size() )
			queue.push(QueueItem.of(item, cost));
			
		queue.Insert(i, QueueItem.of(item, cost));
	}
	
	bool Has(Object other)
	{
		uint i = 0;

		for ( i = 0; i < length(); i++ )
			if ( queue[i].item == other )
				return true;
				
		return false;
	}
	
	uint length()
	{
		return queue.Size();
	}
	
	Object poll()
	{
		if ( queue.Size() == 0 )
			return null;
			
		Object res = queue[0].item;
		queue.Delete(0);
		
		return res;
	}
	
	Object peek()
	{
		if ( queue.Size() == 0 )
			return null;
		
		return queue[0].item;
	}
}

class ActorList
{
	Array<Actor> all;
	bool bHas;
	int iterIndex;
	
	void BeginPlay()
	{
		iReSet();
	}
	
	void iReSet()
	{
		iterIndex = 0;
	}
	
	Object iNext()
	{
		if ( iterIndex >= all.Size() )
			return null;
	
		iterIndex += 1;
		return all[iterIndex - 1];
	}
	
	void iSeek(int i)
	{
		iterIndex = i;
	}
	
	Actor Get(int i)
	{
		if ( i < 0 )
			i += all.Size();
			
		if ( i < 0 ) // still
			i = 0;
	
		if ( all.Size() <= i )
			return null;
	
		return all[i];
	}
	
	bool Remove(int i)
	{
		if ( i < 0 )
			i += all.Size();
			
		if ( i < 0 ) // still
			i = 0;
		
		if ( all.Size() < i ) {
			bHas = false;
			return false;
		}
			
		all.Delete(i);
		return true;
	}
	
	bool isEmpty()
	{
		return !bHas;
	}
	
	static ActorList empty()
	{
		ActorList res = ActorList(new("ActorList"));
		res.bHas = false;
		return res;
	}
	
	void push(Actor node)
	{
		all.push(node);
		bHas = true;
	}
	
	void insert(int ind, Actor node)
	{
		all.Insert(ind, node);
		bHas = true;
	}

	void clear() {
		all.Clear();
		bHas = false;
	}
	
	bool Has(Object other)
	{
		uint i;

		for ( i = 0; i < length(); i++ )
			if ( Get(i) == other )
				return true;
				
		return false;
	}
	
	uint length()
	{
		return all.Size();
	}
}

///////

class DummyInvHolder : Actor
{
	States
	{
		Spawn:
			TNT1 A 1;
			Stop;
	}
}
