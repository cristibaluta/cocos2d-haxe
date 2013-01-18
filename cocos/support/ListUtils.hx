//
//  ListUtils
//
//  Created by Baluta Cristian on 2011-10-29.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//
package cocos.support;
import cocos.CCTimer;// defines TICK_IMP 

// A list double-linked list used for "updates with priority"
class ListEntry
{
	public var prev :ListEntry;
	public var next :ListEntry;
	public var impMethod :Dynamic;//TICK_IMP;
	public var target :Dynamic; // not retained (retained by hashUpdateEntry)
	public var priority :Int;
	public var paused :Bool;
    public var markedForDeletion :Bool; // selector will no longer be called and entry will be removed at end of the next tick
	public function new(){}
	public function toString () :String {
		return "[ListEntry "+["impMethod:"+Std.string(impMethod), "target:"+target, "paused:"+paused].join(", ")+"]";
	}
}


class ListUtils {
	
	/******************************************************************************
	 * doubly linked list macros (non-circular)                                   *
	 *****************************************************************************/
	
	public static function DL_APPEND(head:ListEntry, add:ListEntry) :ListEntry
	{
		if (head != null) {
			add.prev = head.prev;
			head.prev.next = add;
			head.prev = add;
			add.next = null;
		}
		else {
			head = add;
			head.prev = head;
			head.next = null;
		}
		return head;
	}
	
	public static function DL_DELETE(head:ListEntry, del:ListEntry)
	{
		if (del.prev == del) {
			head = null;
		}
		else if (del == head) {
			del.next.prev = del.prev;
			head = del.next;
		}
		else {
			del.prev.next = del.next;
			if (del.next != null) {
				del.next.prev = del.prev;
			} else {
				head.prev = del.prev;
			}
		}
	}
	
	public static function DL_PREPEND(head:ListEntry, add:ListEntry)
	{
		add.next = head;
		if (head != null) {
			add.prev = head.prev;
			head.prev = add;
		}
		else {
			add.prev = add;
		}
		head = add;
	}
	
}
