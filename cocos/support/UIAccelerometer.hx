//
//  UIAccelerometer
//
//  Created by Baluta Cristian on 2011-12-17.
//  Copyright (c) 2011 ralcr.com. All rights reserved.
//
#if flash
typedef UIAccelerometer = flash.sensors.Accelerometer;
#elseif nme
typedef UIAccelerometer = nme.sensors.Accelerometer;
#end


class UIAccelerometer {

static var sharedAccelerometer_ :UIAccelerometer;
public static function sharedAccelerometer () :UIAccelerometer {
	if (sharedAccelerometer_ == null)
		sharedAccelerometer_ = new new UIAccelerometer();
	return sharedAccelerometer_
}

public function new () {}


}
