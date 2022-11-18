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
		
		if ( all.Size() <= i ) {
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
