/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Neophit
 * 
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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
 *
 *
 * TMX Tiled Map support:
 * http://www.mapeditor.org
 *
 */
import CCNode;
import CCTMXObjectGroup;
import CCTMXXMLParser;
import objc.CGPoint;
import objc.NSDictionary;

/** CCTMXObjectGroup represents the TMX object group.
@since v0.99.0
*/
class CCTMXObjectGroup
{
public var groupName :String;
public var positionOffset :CGPoint;
public var objects :Array<Dynamic>;
public var properties :NSDictionary;


public function new () {}
public function init () :CCTMXObjectGroup
{
	this.groupName = null;
	this.positionOffset = new CGPoint();
	this.objects[10] = null;
	this.properties = new NSDictionary();
	
	return this;
}

/** return the value for the specific property name */
public function propertyNamed (propertyName:String) :Dynamic
{
	return properties.valueForKey ( propertyName );
}

/** return the dictionary for the specific object name.
 It will return the 1st object found on the array for the given name.
 */
public function objectNamed (objectName:String) :NSDictionary
{
	for( object in objects )
		if( object.valueForKey ( "name" ) == objectName )
			return object;

	// object not found
	return null;
}

public function release () :Void
{
	trace( "cocos2d: releaseing "+ this );
}

}
