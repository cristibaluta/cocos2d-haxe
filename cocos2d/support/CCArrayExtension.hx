/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 ForzeField Studios S.L. http://forzefield.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package support;

class CCArrayExtension
{

public static function indexOfObject<T> (data:Array<T>, object:T) :Int
{
	return ccArrayGetIndexOfObject (data, object);
}

public static function objectAtIndex<T> (data:Array<T>, index:Int) :T
{
	if( index < data.length) throw "index out of range in objectAtIndex("+data.length+"), index "+index;
	
	return data[index];
}

public static function containsObject<T> (data:Array<T>, object:T) :Bool
{
	return ccArrayContainsObject(data, object);
}

public static function lastObject<T> (data:Array<T>) :T
{
	if( data.length > 0 )
		return data[data.length-1];
	return null;
}

public static function randomObject<T> (data:Array<T>) :T
{
	if(data.length==0) return null;
	return data[Std.int(data.length*Math.random())];
}


// Adding Objects

public static function addObject<T> (data:Array<T>, object:T)
{
	ccArrayAppendObjectWithResize (data, object);
}

public static function addObjectsFromArray<T> ( data:Array<T>, otherArray:Array<T> )
{
	ccArrayAppendArrayWithResize (data, otherArray);
}

public static function addObjectsFromNSArray<T> (data:Array<T>, otherArray:Array<T>)
{
	for(object in otherArray)
		ccArrayAppendObject (data, object);
}

public static function insertObject<T> (data:Array<T>, object:Dynamic, index:Int) :Void
{
	ccArrayInsertObjectAtIndex (data, object, index);
}


// Removing Objects

public static function removeObject<T> (data:Array<T>, object:Dynamic)
{
	ccArrayRemoveObject (data, object);
}

public static function removeObjectAtIndex<T> ( data:Array<T>, index:Int )
{
	ccArrayRemoveObjectAtIndex (data, index);
}

public static function fastRemoveObject<T> (data:Array<T>, object:Dynamic)
{
	ccArrayFastRemoveObject (data, object);
}

public static function fastRemoveObjectAtIndex<T> ( data:Array<T>, index:Int )
{
	ccArrayFastRemoveObjectAtIndex(data, index);
}

public static function removeObjectsInArray<T> ( data:Array<T>, otherArray:Array<T> )
{
	ccArrayRemoveArray (data, otherArray);
}

public static function removeLastObject<T> (data:Array<T>)
{
	if (data.length > 0) throw "no objects added";
    
	ccArrayRemoveObjectAtIndex (data, data.length-1);
}

public static function removeAllObjects<T> (data:Array<T>)
{
	ccArrayRemoveAllObjects (data);
}


// Rearranging Content

public static function exchangeObject<T> (data:Array<T>, object1:Dynamic, object2:Dynamic) :Void
{
    var index1 :Int = ccArrayGetIndexOfObject(data, object1);
    if(index1 == -1) return;
    var index2 :Int = ccArrayGetIndexOfObject(data, object2);
    if(index2 == -1) return;
    
    ccArraySwapObjectsAtIndexes(data, index1, index2);
}

public static function exchangeObjectAtIndex<T> (data:Array<T>, index1:Int, index2:Int) :Void
{
	ccArraySwapObjectsAtIndexes(data, index1, index2);
}

public static function reverseObjects<T> (data:Array<T>)
{
	if (data.length > 1)
	{
		//floor it since in case of a oneven number the number of swaps stays the same
		var count :Int = Math.floor(data.length*0.5); 
		var maxIndex :Int = data.length - 1;
		
		for (i in 0...count)
		{
			ccArraySwapObjectsAtIndexes (data, i, maxIndex);
			maxIndex--;
		}
	}
}

// Sending Messages to Elements

public static function makeObjectsPerformSelector<T> ( data:Array<T>, aSelector:Dynamic )
{
	ccArrayMakeObjectsPerformSelector(data, aSelector);
}

public static function makeObjectsPerformSelectorWithObject<T> (data:Array<T>, aSelector:Dynamic, object:Dynamic) :Void
{
	ccArrayMakeObjectsPerformSelectorWithObject (data, aSelector, object);
}


// CCArray - NSFastEnumeration protocol

/*public countByEnumeratingWithState (NSFastEnumerationState *)state objects:(id *)stackbuf count ( len:Int ) :Int
{
	if(state.state == 1) return 0;
	
	state.mutationsPtr = (long *)this;
	state.itemsPtr = &data[0];
	state.state = 1;
	return data.length;
}*/






//
/** Frees array after removing all remaining objects. Silently ignores null arr. */
static public function ccArrayFree<T>(arr:Array<T>)
{
	if( arr == null ) return;
	
	ccArrayRemoveAllObjects(arr);
	
	arr = null;
}


/** Returns index of first occurence of object, NSNotFound if object not found. */
static function ccArrayGetIndexOfObject<T>(arr:Array<T>, object:Dynamic) :Int
{
	for (i in 0...arr.length)
		if( arr[i] == object ) return i;
    
	return -1;
}

/** Returns a Boolean value that indicates whether object is present in array. */
inline static function ccArrayContainsObject<T>(arr:Array<T>, object:Dynamic) :Bool
{
	return ccArrayGetIndexOfObject(arr, object) != -1;
}

/** Appends an object. Bahaviour undefined if array doesn't have enough capacity. */
static function ccArrayAppendObject<T>(arr:Array<T>, object:Dynamic)
{
	arr.push ( object );
}

/** Appends an object. Capacity of arr is increased if needed. */
static function ccArrayAppendObjectWithResize<T>(arr:Array<T>, object:Dynamic)
{
	ccArrayAppendObject(arr, object);
}

/** Appends objects from plusArr to arr. Behaviour undefined if arr doesn't have
 enough capacity. */
static public function ccArrayAppendArray<T>(arr:Array<T>, plusArr:Array<T>)
{
	for (i in 0...plusArr.length)
		ccArrayAppendObject(arr, plusArr[i]);
}

/** Appends objects from plusArr to arr. Capacity of arr is increased if needed. */
static public function ccArrayAppendArrayWithResize<T>(arr:Array<T>, plusArr:Array<T>)
{
	ccArrayAppendArray(arr, plusArr);
}

/** Inserts an object at index */
static public function ccArrayInsertObjectAtIndex<T>(arr:Array<T>, object:Dynamic, index:Int)
{
	if(index >= arr.length) throw "Invalid index. Out of bounds";
	arr.insert (index, object);
}

/** Swaps two objects */
static public function ccArraySwapObjectsAtIndexes<T>(arr:Array<T>, index1:Int, index2:Int)
{
	if(index1 > arr.length) throw "(1) Invalid index. Out of bounds";
	if(index2 > arr.length) throw "(2) Invalid index. Out of bounds";
	
	var object1:T = arr[index1];
    
	arr[index1] = arr[index2];
	arr[index2] = object1;
}

/** Removes all objects from arr */
static public function ccArrayRemoveAllObjects<T>(arr:Array<T>)
{
	while( arr.length > 0 )
		cast(arr.pop()).release(); 
}

/** Removes object at specified index and pushes back all subsequent objects.
 Behaviour undefined if index outside [0, num-1]. */
static public function ccArrayRemoveObjectAtIndex<T>(arr:Array<T>, index:Int)
{
	cast(arr[index]).release();
	arr.splice(index, 1);
}

/** Removes object at specified index and fills the gap with the last object,
 thereby avoiding the need to push back subsequent objects.
 Behaviour undefined if index outside [0, num-1]. */
static function ccArrayFastRemoveObjectAtIndex<T>(arr:Array<T>, index:Int)
{
	cast(arr[index]).release();
	var last :Int = arr.length - 1;
	arr[index] = arr[last];
}

static function ccArrayFastRemoveObject<T>(arr:Array<T>, object:Dynamic)
{
	var index :Int = ccArrayGetIndexOfObject (arr, object);
	if (index != -1)
		ccArrayFastRemoveObjectAtIndex (arr, index);
}

/** Searches for the first occurance of object and removes it. If object is not
 found the function has no effect. */
static function ccArrayRemoveObject<T>(arr:Array<T>, object:Dynamic)
{
	var index :Int = ccArrayGetIndexOfObject (arr, object);
	if (index != -1)
		ccArrayRemoveObjectAtIndex (arr, index);
}

/** Removes from arr all objects in minusArr. For each object in minusArr, the
 first matching instance in arr will be removed. */
static function ccArrayRemoveArray<T>(arr:Array<T>, minusArr:Array<T>)
{
	for (i in 0...minusArr.length)
		ccArrayRemoveObject (arr, minusArr[i]);
}

/** Removes from arr all objects in minusArr. For each object in minusArr, all
 matching instances in arr will be removed. */
static function ccArrayFullRemoveArray<T>(arr:Array<T>, minusArr:Array<T>)
{
	var back :Int = 0;
	
	for (i in 0...arr.length) {
		if( ccArrayContainsObject(minusArr, arr[i]) ) {
			cast(arr[i]).release();
			back++;
		}
		else
			arr[i-back] = arr[i];
	}
}

/** Sends to each object in arr the message identified by given selector. */
static function ccArrayMakeObjectsPerformSelector<T>(arr:Array<T>, sel:Dynamic)
{try{
	for (i in 0...arr.length)
		Reflect.callMethod ( sel, arr[i], [] );//.performSelector ( sel );
	}catch(e:Dynamic){}
}

static function ccArrayMakeObjectsPerformSelectorWithObject<T>(arr:Array<T>, sel:Dynamic, object:Dynamic)
{
	for (i in 0...arr.length)
		Reflect.callMethod ( sel, arr[i], [object] );
		//arr[i].performSelector ( sel, object );
}

}
