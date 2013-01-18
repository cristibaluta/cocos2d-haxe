//
//  Assets
//
//  Created by Baluta Cristian on 2011-11-09.
//  Copyright (c) 2011-2012 ralcr.com. All rights reserved.
//
package cocos.platform.flash;

import cocos.support.UIImage;


class CCAssets {
	
	static var sharedAssets_ :CCAssets;
	public static function sharedAssets () :CCAssets {
		if (sharedAssets_ == null)
			sharedAssets_ = new CCAssets();
		return sharedAssets_;
	}
	
	dynamic public static function onComplete () :Void {}
	
	public static function loadFile (filepath:String) :Void {
		sharedAssets().loadRemoteFile ( filepath );
	}
	public static function getCachedFile (filepath:String) :Dynamic {
		return sharedAssets().getFileFromCache ( filepath );
	}
	
	
	
	
	var loadedFiles :Int;
	var expectedFiles :Int;
	var cache :Hash<Dynamic>;
	
	public function new(){
		loadedFiles = 0;
		expectedFiles = 0;
		cache = new Hash<Dynamic>();
	}
	
	public function loadRemoteFile (filepath:String) {
		trace("loadFile at path "+filepath);
		expectedFiles ++;
		switch (filepath.toLowerCase().split(".").pop()) {
			case "png", "jpg" :
				var img = new UIImage().initWithContentsOfFile ( filepath );
				img.onComplete = completeHandler;
				img.onError = completeHandler;
				cache.set (filepath, img);
			case "plist" :
				null;
				// TO DO
		}
	}
	public function getFileFromCache (filepath:String) :Dynamic {
		return cache.get ( filepath );
	}
	
	
	function completeHandler () {
		loadedFiles++;
		if (loadedFiles >= expectedFiles)
			onComplete();
	}
}
