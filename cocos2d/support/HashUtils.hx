//
//  HashUtils
//
//  Created by Baluta Cristian on 2011-10-29.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//
package support;
import support.ListUtils;
import CCTimer;

class HashUpdateEntry
{
	public var list :ListEntry;		// Which list does it belong to ?
	public var entry :ListEntry;	// entry in the list
	public var target :Dynamic;		// hash key (retained)
	public var hh :Dynamic;			//UT_hash_handle;
	public function new(){}
}

// Hash Element used for "selectors with interval"
class HashSelectorEntry
{
	public var timers :Array<CCTimer>;
	public var target :Dynamic;		// hash key (retained)
	public var timerIndex :Int;
	public var currentTimer :CCTimer;
	public var currentTimerSalvaged :Bool;
	public var paused :Bool;
	public var hh :Dynamic;			//UT_hash_handle;
	public function new(){}
}


class HashUtils {
	
	public static function HASH_ADD_INT(head,intfield,add)
	{
		//return HASH_ADD (hh,head,intfield,sizeof(int),add);
	}
	
	public static function HASH_ADD(hh,head,fieldname,keylen_in,add)
	{
		return HASH_ADD_KEYPTR (hh,head,Reflect.field(add,fieldname),keylen_in,add);
	}
	
	public static function HASH_ADD_KEYPTR(hh,head,keyptr,keylen_in,add)
	{
/*		unsigned _ha_bkt;
		add)->hh.next = NULL;
		add)->hh.key = (char*)keyptr;
		add)->hh.keylen = keylen_in;
		if (!(head)) {
			head = (add);
			head)->hh.prev = NULL;
			HASH_MAKE_TABLE(hh,head);
		} else {
			head)->hh.tbl->tail->next = (add);
			add)->hh.prev = ELMT_FROM_HH((head)->hh.tbl, (head)->hh.tbl->tail);
			head)->hh.tbl->tail = &((add)->hh);
		}
		head)->hh.tbl->num_items++;
		add.hh.tbl = (head)->hh.tbl;
		HASH_FCN(keyptr,keylen_in, (head)->hh.tbl->num_buckets, add)->hh.hashv, _ha_bkt);
		HASH_ADD_TO_BKT((head)->hh.tbl->buckets[_ha_bkt],&(add)->hh);
		HASH_BLOOM_ADD((head)->hh.tbl,(add)->hh.hashv);
		HASH_EMIT_KEY(hh,head,keyptr,keylen_in);
		HASH_FSCK(hh,head);*/
	}
}