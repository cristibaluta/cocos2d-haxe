/*
 Copyright (c) 2010 Steve Oldmeadow
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 $Id$
 */
/**
 A wrapper to the CDAudioManager object.
 This is recommended for basic audio requirements. If you just want to play some sound fx
 and some background music and have no interest in learning the lower level workings then
 this is the interface to use.

 Requirements:
 - Firmware: OS 2.2 or greater 
 - Files: SimpleAudioEngine., CocosDenshion.*
 - Frameworks: OpenAL, AudioToolbox, AVFoundation
 @since v0.8
 */

class SimpleAudioEngine
{

static var sharedEngine :SimpleAudioEngine = null;
static var soundEngine :CDSoundEngine = null;
static var am :CDAudioManager = null;
static var bufferManager :CDBufferManager = null;
var mute_ :Bool;
var enabled_ :Bool;

/** Background music volume. Range is 0.0 to 1.0. This will only have an effect if willPlayBackgroundMusic returns true */
public var backgroundMusicVolume (getBackgroundMusicVolume, setBackgroundMusicVolume) :Float;
/** Effects volume. Range is 0.0 to 1.0 */
public var effectsVolume (getEffectsVolume, setEffectsVolume) :Float;
/** If NO it indicates background music will not be played either because no background music is loaded or the audio session does not permit it.*/
public var willPlayBackgroundMusic (getWillPlayBackgroundMusic, null) :Bool;

/** returns the shared instance of the SimpleAudioEngine object */
public static function sharedEngine () :SimpleAudioEngine
{
	if (sharedEngine == null)
		sharedEngine = new SimpleAudioEngine().init();
	}
	return sharedEngine;
}

public function new () {}
public function init () :SimpleAudioEngine
{
	am = CDAudioManager.sharedManager();
	soundEngine = am.soundEngine;
	bufferManager = new CDBufferManager().initWithEngine ( soundEngine );
	mute_ = false;
	enabled_ = true;
	
	return this;
}

// Memory
public function release ()
{
	am = null;
	soundEngine = null;
	bufferManager = null;
}

/** Shuts down the shared audio engine instance so that it can be reinitialised */
public static function end ()
{
	am = null;
	CDAudioManager.end();
	bufferManager.release();
	sharedEngine.release();
	sharedEngine = null;
}	

// SimpleAudioEngine - background music

/** Preloads a music file so it will be ready to play as background music */
public function preloadBackgroundMusic (filePath:String)
{
	am.preloadBackgroundMusic ( filePath );
}

/** plays background music in a loop*/
public function playBackgroundMusic (filePath:String)
{
	am.playBackgroundMusic ( filePath, true );
}

/** plays background music, if loop is true the music will repeat otherwise it will be played once */
public function playBackgroundMusic ( filePath:String, loop:Bool ) :Void
{
	am.playBackgroundMusic ( filePath, loop );
}

/** stops playing background music */
public function stopBackgroundMusic ()
{
	am.stopBackgroundMusic();
}

/** pauses the background music */
public function pauseBackgroundMusic () {
	am.pauseBackgroundMusic();
}	

/** resume background music that has been paused */
public function resumeBackgroundMusic () {
	am.resumeBackgroundMusic();
}	

/** rewind the background music */
public function rewindBackgroundMusic () {
	am.rewindBackgroundMusic();
}

/** returns whether or not the background music is playing */
public function isBackgroundMusicPlaying () :Bool {
	return am.isBackgroundMusicPlaying();
}	

public function getWillPlayBackgroundMusic () :Bool {
	return am.willPlayBackgroundMusic();
}

// SimpleAudioEngine - sound effects

/** plays an audio effect with a file path, pitch, pan and gain */
public function playEffect (filePath:String, pitch:Float=1.0, pan:Float=0.0, gain:Float=1.0) :Int
{
	var soundId :Int = bufferManager.bufferForFile ( filePath, true );
	if (soundId != kCDNoBuffer) {
		return soundEngine.playSound (soundId, 0, pitch, pan, gain(gain,false));
	} else {
		return CD_MUTE;
	}	
}

/** stop a sound that is playing, note you must pass in the soundId that is returned when you started playing the sound with playEffect */
public function stopEffect (soundId:Int)  {
	[soundEngine.stopSound ( soundId );
}	

/** preloads an audio effect */
public function preloadEffect (filePath:String) 
{
	var soundId :Int = bufferManager.bufferForFile ( filePath, true );
	if (soundId == kCDNoBuffer) {
		CDLOG("Denshion::SimpleAudioEngine sound failed to preload "+filePath);
	}
}

/** unloads an audio effect from memory */
public function unloadEffect (filePath:String) 
{
	trace("Denshion::SimpleAudioEngine unloadedEffect "+filePath);
	bufferManager.releaseBufferForFile ( filePath );
}

// Audio Interrupt Protocol
public function mute () :Bool
{
	return mute_;
}

public function setMute (muteValue:Bool) :Bool
{
	if (mute_ != muteValue) {
		mute_ = muteValue;
		am.mute = mute_;
	}
	return mute_;
}

public function enabled () :Bool
{
	return enabled_;
}

public function setEnabled (enabledValue:Bool) :Bool
{
	if (enabled_ != enabledValue) {
		enabled_ = enabledValue;
		am.enabled = enabled_;
	}
	return enabled_;
}


// SimpleAudioEngine - BackgroundMusicVolume
public function getBackgroundMusicVolume () :Float {
	return am.backgroundMusic.volume;
}
public function setBackgroundMusicVolume (volume:Float) :Float
{
	return am.backgroundMusic.volume = volume;
}	

// SimpleAudioEngine - EffectsVolume
public function getEffectsVolume () :Float
{
	return am.soundEngine.masterGain;
}
public function setEffectsVolume (volume:Float) :Float
{
	return am.soundEngine.masterGain = volume;
}	

/** Gets a CDSoundSource object set up to play the specified file. */
public function soundSourceForFile (filePath:String) :CDSoundSource {
	var soundId :Int = bufferManager.bufferForFile ( filePath, true );
	if (soundId != kCDNoBuffer) {
		var result :CDSoundSource = soundEngine.soundSourceForSound (soundId, 0);
		trace("Denshion::SimpleAudioEngine sound source created for "+filePath);
		return result;
	} else {
		return null;
	}	
}	

} 
