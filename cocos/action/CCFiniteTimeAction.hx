//
//  CCFiniteTimeAction
//
//  Created by Baluta Cristian on 2011-10-28.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//

/** Base class actions that do have a finite time duration.
 Possible actions:
   - An action with a duration of 0 seconds
   - An action with a duration of 35.5 seconds
 Infitite time actions are valid
 */
package cocos.action;

class CCFiniteTimeAction extends CCAction
{
//! duration in seconds of the action
public var duration :Float;

/** returns a reversed action */
public function reverse () :CCFiniteTimeAction
{
	trace("cocos2d: FiniteTimeAction#reverse: Implement me");
	return null;
}
}