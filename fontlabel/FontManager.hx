//
//  FontManager.m
//  FontLabel
//
//  Created by Kevin Ballard on 5/5/09.
//  Copyright © 2009 Zynga Game Networks
//
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import ZFont;
import objc.NSDictionary;

class FontManager
{

var fonts :NSDictionary;
var urls :NSDictionary;

static var sharedFontManager :FontManager = null;


public static function sharedManager () :FontManager {
	if (sharedFontManager == null) {
		sharedFontManager = new FontManager().init();
	}
	return sharedFontManager;
}

public function new () {}
public function init () :FontManager {
	fonts = new NSDictionary();
	urls = new NSDictionary();
	
	return this;
}

public function loadFont (filename:String) :Bool {
/*	var fontPath :String = NSBundle.mainBundle().pathForResource(filename, "ttf");
	if (fontPath == null) {
		fontPath = NSBundle.mainBundle().pathForResource(filename, nil);
	}
	if (fontPath == null) return NO;
	
	var url = NSURL.fileURLWithPath(fontPath);
	if (loadFontURL(url)) {
		urls.setObject (url, filename);
		return true;
	}*/
	return false;
}

public function loadFontURL (url:String) :Bool {
/*	var fontDataProvider :CGDataProviderRef = CGDataProviderCreateWithURL(url);
	if (fontDataProvider == null) return NO;
	CGFontRef newFont = CGFontCreateWithDataProvider(fontDataProvider); 
	CGDataProviderRelease(fontDataProvider); 
	if (newFont == null) return NO;
	
	CFDictionarySetValue(fonts, url, newFont);
	CGFontRelease(newFont);*/
	return true;
}

public function fontWithName (filename:String) :Dynamic {
/*	CGFontRef font = null;
	NSURL *url = [urls objectForKey:filename];
	if (url == null && [self loadFont:filename]) {
		url = [urls objectForKey:filename];
	}
	if (url != null) {
		font = (CGFontRef)CFDictionaryGetValue(fonts, url);
	}
	return font;*/
	return null;
}

public function zFontWithName (filename:String, pointSize:Float) :ZFont {
/*	NSURL *url = [urls objectForKey:filename];
	if (url == null && [self loadFont:filename]) {
		url = [urls objectForKey:filename];
	}
	if (url != null) {
		CGFontRef cgFont = (CGFontRef)CFDictionaryGetValue(fonts, url);
		if (cgFont != null) {
			return [ZFont fontWithCGFont:cgFont size:pointSize];
		}
	}*/
	return null;
}

public function zFontWithURL (url:String, pointSize:Float) :ZFont {
/*	CGFontRef cgFont = (CGFontRef)CFDictionaryGetValue(fonts, url);
	if (cgFont == null && [self loadFontURL:url]) {
		cgFont = (CGFontRef)CFDictionaryGetValue(fonts, url);
	}
	if (cgFont != null) {
		return [ZFont fontWithCGFont:cgFont size:pointSize];
	}*/
	return null;
}

public function copyAllFonts () :Dynamic {
/*	CFIndex count = CFDictionaryGetCount(fonts);
	CGFontRef *values = (CGFontRef *)malloc(sizeof(CGFontRef) * count);
	CFDictionaryGetKeysAndValues(fonts, null, (const void **)values);
	CFArrayRef array = CFArrayCreate(null, (const void **)values, count, &kCFTypeArrayCallBacks);
	values = null;
	return array;*/
	return null;
}

public function release () {
	fonts = null;
	urls.release();
}

}
