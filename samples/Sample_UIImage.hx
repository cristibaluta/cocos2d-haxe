//
//  UIImage
//
//  Created by Baluta Cristian on 2011-12-12.
//  Copyright (c) 2011-2012 ralcr.com. All rights reserved.
//

//@:bitmap("Resources/Girl.jpg") class Girl extends flash.display.BitmapData {}
import cocos.support.UIImage;

class Sample_UIImage {
	
	public function new(){
		var uiimage = new UIImage().initWithContentsOfFile("grossini.png");
		uiimage.onComplete = onComplete.bind(uiimage);
		//flash.Lib.current.addChild ( new flash.display.Bitmap ( new Girl(0,0)));
	}
	function onComplete(uiimage:UIImage) {
		flash.Lib.current.addChild ( uiimage.bitmap );
	}
	
	public static function main(){
		cocos.support.CCLog.redirectTraces();
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		new Sample_UIImage();
	}
}
