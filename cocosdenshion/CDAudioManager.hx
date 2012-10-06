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


import CDAudioManager;

String * const kCDN_AudioManagerInitialised = "kCDN_AudioManagerInitialised";

//NSOperation object used to asynchronously initialise 
class CDAsynchInitialiser

public function main {
	super.main();
	CDAudioManager.sharedManager();
}	

}

class CDLongAudioSource

public var audioSourcePlayer (get_audioSourcePlayer, set_audioSourcePlayer) :, audioSourceFilePath, delegate, backgroundMusic;

-(id) init {
	super.init();
		state = kLAS_Init;
		volume = 1.0;
		mute = false;
		enabled_ = true;
	}
	return this;
}

public function release {
	trace("Denshion::CDLongAudioSource - releaseating "+ this);
	audioSourcePlayer.release();
	audioSourceFilePath.release();
	super.release();
}	

public function load:(String*) filePath {
	//We have alread loaded a file previously,  check if we are being asked to load the same file
	if (state == kLAS_Init || !filePath.isEqualToString ( audioSourceFilePath )) {
		trace("Denshion::CDLongAudioSource - Loading new audio source "+filePath);
		//New file
		if (state != kLAS_Init) {
			audioSourceFilePath.release();//Release old file path
			audioSourcePlayer.release();//Release old AVAudioPlayer, they can't be reused
		}
		audioSourceFilePath = filePath.copy();
		var error :NSError = null;
		var  path :String = [CDUtilities.fullPathFromRelativePath ( audioSourceFilePath );
		audioSourcePlayer = [(AVAudioPlayer*)new AVAudioPlayer().initWithContentsOfURL:NSURL.fileURLWithPath ( path ) error:&error();
		if (error == null) {
			audioSourcePlayer.prepareToPlay();
			audioSourcePlayer.delegate = this;
			if (delegate && delegate.respondsToSelector:@selector(cdAudioSourceFileDidChange:)]) {
				//Tell our delegate the file has changed
				[delegate.cdAudioSourceFileDidChange ( this );
			}	
		} else {
			CDLOG("Denshion::CDLongAudioSource - Error initialising audio player: "+error);
		}	
	} else {
		//Same file - just return it to a consistent state
		this.pause();
		this.rewind();
	}
	audioSourcePlayer.volume = volume;
	audioSourcePlayer.numberOfLoops = numberOfLoops;
	state = kLAS_Loaded;
}	

public function play {
	if (enabled_) {
		this.systemPaused = false;
		audioSourcePlayer.play();
	} else {
		trace("Denshion::CDLongAudioSource long audio source didn't play because it is disabled");
	}	
}	

public function stop {
	audioSourcePlayer.stop();
}	

public function pause {
	audioSourcePlayer.pause();
}	

public function rewind {
	audioSourcePlayer.setCurrentTime:0();
}

public function resume {
	audioSourcePlayer.play();
}	

-(Bool) isPlaying {
	if (state != kLAS_Init) {
		return audioSourcePlayer.isPlaying();
	} else {
		return false;
	}
}

public function setVolume:(Float) newVolume
{
	volume = newVolume;
	if (state != kLAS_Init && !mute) {
		audioSourcePlayer.volume = newVolume;
	}	
}

-(Float) volume 
{
	return volume;
}

// Audio Interrupt Protocol
public function mute () :Bool
{
	return mute;
}	

public function setMute:(Bool) muteValue 
{
	if (mute != muteValue) {
		if (mute) {
			//Turn sound back on
			audioSourcePlayer.volume = volume;
		} else {
			audioSourcePlayer.volume = 0.0;
		}
		mute = muteValue;
	}	
}	

-(Bool) enabled 
{
	return enabled_;
}	

public function setEnabled:(Bool)enabledValue 
{
	if (enabledValue != enabled_) {
		enabled_ = enabledValue;
		if (!enabled_) {
			//"Stop" the sounds
			this.pause();
			this.rewind();
		}	
	}	
}	

-(Int) numberOfLoops {
	return numberOfLoops;
}	

public function setNumberOfLoops:(Int) loopCount
{
	audioSourcePlayer.numberOfLoops = loopCount;
	numberOfLoops = loopCount;
}	

public function audioPlayerDidFinishPlaying (player:AVAudioPlayer , flag:Bool) :Void
	trace("Denshion::CDLongAudioSource - audio player finished");
#if TARGET_IPHONE_SIMULATOR	
	trace("Denshion::CDLongAudioSource - workaround for OpenAL clobbered audio issue");
	//This is a workaround for an issue in all simulators (tested to 3.1.2).  Problem is 
	//that OpenAL audio playback is clobbered when an AVAudioPlayer stops.  Workaround
	//is to keep the player playing on an endless loop with 0 volume and then when
	//it is played again reset the volume and set loop count appropriately.
	//NB: this workaround is not foolproof but it is good enough for most situations.
	player.numberOfLoops = -1;
	player.volume = 0;
	player.play();
#end	
	if (delegate && delegate.respondsToSelector:@selector(cdAudioSourceDidFinishPlaying:)]) {
		[delegate.cdAudioSourceDidFinishPlaying ( this );
	}	
}	

public function audioPlayerBeginInterruption:(AVAudioPlayer *)player {
	trace("Denshion::CDLongAudioSource - audio player interrupted");
}

public function audioPlayerEndInterruption:(AVAudioPlayer *)player {
	trace("Denshion::CDLongAudioSource - audio player resumed");
	if (this.backgroundMusic) {
		//Check if background music can play as rules may have changed during 
		//the interruption. This is to address a specific issue in 4.x when
		//fast task switching
		if(CDAudioManager.sharedManager].willPlayBackgroundMusic) {
			player.play();
		}	
	} else {
		player.play();
	}	
}	

}


@interface CDAudioManager (PrivateMethods)
-(Bool) audioSessionSetActive:(Bool) active;
-(Bool) audioSessionSetCategory:(String*) category;
public function badAlContextHandler;
}


class CDAudioManager
#define BACKGROUND_MUSIC_CHANNEL kASC_Left

public var soundEngine (get_soundEngine, set_soundEngine) :, willPlayBackgroundMusic;
static CDAudioManager *sharedManager;
static tAudioManagerState _sharedManagerState = kAMStateUninitialised;
static tAudioManagerMode configuredMode;
static Bool configured = false;

-(Bool) audioSessionSetActive:(Bool) active {
	var activationError :NSError = null;
	if ([AVAudioSession.sharedInstance] setActive:active error:&activationError]) {
		_audioSessionActive = active;
		trace("Denshion::CDAudioManager - Audio session set active %i succeeded", active); 
		return true;
	} else {
		//Failed
		CDLOG("Denshion::CDAudioManager - Audio session set active %i failed with error "+ active, activationError); 
		return false;
	}	
}	

-(Bool) audioSessionSetCategory:(String*) category {
	var categoryError :NSError = null;
	if ([AVAudioSession.sharedInstance] setCategory:category error:&categoryError]) {
		trace("Denshion::CDAudioManager - Audio session set category %@ succeeded", category); 
		return true;
	} else {
		//Failed
		CDLOG("Denshion::CDAudioManager - Audio session set category %@ failed with error "+ category, categoryError); 
		return false;
	}	
}	

// Init
+ (CDAudioManager *) sharedManager
{
	@synchronized(this)     {
		if (!sharedManager) {
			if (!configured) {
				//Set defaults here
				configuredMode = kAMM_FxPlusMusicIfNoOtherAudio;
			}
			sharedManager = new CDAudioManager().init ( configuredMode );
			_sharedManagerState = kAMStateInitialised;//This is only really relevant when using asynchronous initialisation
			[NSNotificationCenter.defaultCenter] postNotificationName ( kCDN_AudioManagerInitialised, null );
		}	
	}
	return sharedManager;
}

+ (tAudioManagerState) sharedManagerState {
	return _sharedManagerState;
}	

/**
 * Call this to set up audio manager asynchronously.  Initialisation is finished when sharedManagerState == kAMStateInitialised
 */
+ (void) initAsynchronously: (tAudioManagerMode) mode {
	@synchronized(this) {
		if (_sharedManagerState == kAMStateUninitialised) {
			_sharedManagerState = kAMStateInitialising;
			[CDAudioManager.configure ( mode );
			var initOp :CDAsynchInitialiser = [new CDAsynchInitialiser().init] autorelease();
			var opQ :NSOperationQueue = [new NSOperationQueue().init] autorelease();
			[opQ.addOperation ( initOp );
		}	
	}
}	

+ (id) alloc
{
	@synchronized(this)     {
		if (sharedManager == null, "Attempted to allocate a second instance of a singleton.");
		return super.alloc();
	}
	return null;
}

/*
 * Call this method before accessing the shared manager in order to configure the shared audio manager
 */
+ (void) configure: (tAudioManagerMode) mode {
	configuredMode = mode;
	configured = true;
}	

-(Bool) isOtherAudioPlaying {
	var isPlaying :UInt32 = 0;
	var varSize :UInt32 = sizeof(isPlaying);
	AudioSessionGetProperty (kAudioSessionProperty_OtherAudioIsPlaying, &varSize, &isPlaying);
	return (isPlaying != 0);
}

public function setMode:(tAudioManagerMode) mode {

	_mode = mode;
	switch (_mode) {
			
		case kAMM_FxOnly:
			//Share audio with other app
			trace("Denshion::CDAudioManager - Audio will be shared");
			//_audioSessionCategory = kAudioSessionCategory_AmbientSound;
			_audioSessionCategory = AVAudioSessionCategoryAmbient;
			willPlayBackgroundMusic = false;
			break;
			
		case kAMM_FxPlusMusic:
			//Use audio exclusively - if other audio is playing it will be stopped
			trace("Denshion::CDAudioManager -  Audio will be exclusive");
			//_audioSessionCategory = kAudioSessionCategory_SoloAmbientSound;
			_audioSessionCategory = AVAudioSessionCategorySoloAmbient;
			willPlayBackgroundMusic = true;
			break;
			
		case kAMM_MediaPlayback:
			//Use audio exclusively, ignore mute switch and sleep
			trace("Denshion::CDAudioManager -  Media playback mode, audio will be exclusive");
			//_audioSessionCategory = kAudioSessionCategory_MediaPlayback;
			_audioSessionCategory = AVAudioSessionCategoryPlayback;
			willPlayBackgroundMusic = true;
			break;
			
		case kAMM_PlayAndRecord:
			//Use audio exclusively, ignore mute switch and sleep, has inputs and outputs
			trace("Denshion::CDAudioManager -  Play and record mode, audio will be exclusive");
			//_audioSessionCategory = kAudioSessionCategory_PlayAndRecord;
			_audioSessionCategory = AVAudioSessionCategoryPlayAndRecord;
			willPlayBackgroundMusic = true;
			break;
			
		default:
			//kAudioManagerFxPlusMusicIfNoOtherAudio
			if (this.isOtherAudioPlaying]) {
				trace("Denshion::CDAudioManager - Other audio is playing audio will be shared");
				//_audioSessionCategory = kAudioSessionCategory_AmbientSound;
				_audioSessionCategory = AVAudioSessionCategoryAmbient;
				willPlayBackgroundMusic = false;
			} else {
				trace("Denshion::CDAudioManager - Other audio is not playing audio will be exclusive");
				//_audioSessionCategory = kAudioSessionCategory_SoloAmbientSound;
				_audioSessionCategory = AVAudioSessionCategorySoloAmbient;
				willPlayBackgroundMusic = true;
			}	
			
			break;
	}
	 
	this.audioSessionSetCategory ( _audioSessionCategory );
	
}	

/**
 * This method is used to work around various bugs introduced in 4.x OS versions. In some circumstances the 
 * audio session is interrupted but never resumed, this results in the loss of OpenAL audio when following 
 * standard practices. If we detect this situation then we will attempt to resume the audio session ourselves.
 * Known triggers: lock the device then unlock it (iOS 4.2 gm), playback a song using MPMediaPlayer (iOS 4.0)
 */
public function badAlContextHandler {
	if (_interrupted && alcGetCurrentContext() == null) {
		CDLOG("Denshion::CDAudioManager - bad OpenAL context detected, attempting to resume audio session");
		this.audioSessionResumed();
	}	
}	

- (id) init: (tAudioManagerMode) mode {
	super.init();
		
		//Initialise the audio session 
		AVAudioSession* session = AVAudioSession.sharedInstance();
		session.delegate = this;
	
		_mode = mode;
		backgroundMusicCompletionSelector = null;
		_isObservingAppEvents = false;
		_mute = false;
		_resigned = false;
		_interrupted = false;
		enabled_ = true;
		_audioSessionActive = false;
		this.setMode ( mode );
		soundEngine = new CDSoundEngine().init();
		
		//Set up audioSource channels
		audioSourceChannels = new Array<>().init();
		var leftChannel :CDLongAudioSource = new CDLongAudioSource().init();
		leftChannel.backgroundMusic = true;
		var rightChannel :CDLongAudioSource = new CDLongAudioSource().init();
		rightChannel.backgroundMusic = false;
		audioSourceChannels.insertObject ( leftChannel, kASC_Left );	
		audioSourceChannels.insertObject ( rightChannel, kASC_Right );
		leftChannel.release();
		rightChannel.release();
		//Used to support legacy APIs
		backgroundMusic = this.audioSourceForChannel ( BACKGROUND_MUSIC_CHANNEL );
		backgroundMusic.delegate = this;
		
		//Add handler for bad al context messages, these are posted by the sound engine.
		[NSNotificationCenter.defaultCenter] addObserver:this	selector:@selector(badAlContextHandler), kCDN_BadAlContext, null );

	}	
	return this;		
}	

public function release {
	trace("Denshion::CDAudioManager - releaseating");
	this.stopBackgroundMusic();
	soundEngine.release();
	[NSNotificationCenter.defaultCenter].removeObserver ( this );
	this.audioSessionSetActive ( false );
	audioSourceChannels.release();
	super.release();
}	

/** Retrieves the audio source for the specified channel */
-(CDLongAudioSource*) audioSourceForChannel:(tAudioSourceChannel) channel 
{
	return (CDLongAudioSource*)[audioSourceChannels.objectAtIndex ( channel );
}	

/** Loads the data from the specified file path to the channel's audio source */
-(CDLongAudioSource*) audioSourceLoad:(String*) filePath channel:(tAudioSourceChannel) channel
{
	var audioSource :CDLongAudioSource = this.audioSourceForChannel ( channel );
	if (audioSource) {
		[audioSource.load ( filePath );
	}
	return audioSource;
}	

-(Bool) isBackgroundMusicPlaying {
	return [this.backgroundMusic isPlaying();
}	

//NB: originally I tried using a route change listener and intended to store the current route,
//however, on a 3gs running 3.1.2 no route change is generated when the user switches the 
//ringer mute switch to off (i.e. enables sound) therefore polling is the only reliable way to
//determine ringer switch state
-(Bool) isDeviceMuted {

#if TARGET_IPHONE_SIMULATOR
	//Calling audio route stuff on the simulator causes problems
	return false;
#else	
	var newAudioRoute :CFStringRef;
	var propertySize :UInt32 = sizeof (CFStringRef);
	
	AudioSessionGetProperty (
							 kAudioSessionProperty_AudioRoute,
							 &propertySize,
							 &newAudioRoute
							 );
	
	if (newAudioRoute == null) {
		//Don't expect this to happen but playing safe otherwise a null in the CFStringCompare will cause a crash
		return true;
	} else {	
		var newDeviceIsMuted :CFComparisonResult =	CFStringCompare (
																 newAudioRoute,
																 (CFStringRef) "",
																 0
																 );
		
		return (newDeviceIsMuted == kCFCompareEqualTo);
	}	
#end
}	

// Audio Interrupt Protocol

-(Bool) mute {
	return _mute;
}	

public function setMute:(Bool) muteValue {
	if (muteValue != _mute) {
		_mute = muteValue;
		[soundEngine.setMute ( muteValue );
		for( CDLongAudioSource *audioSource in audioSourceChannels) {
			audioSource.mute = muteValue;
		}	
	}	
}

-(Bool) enabled {
	return enabled_;
}	

public function setEnabled:(Bool) enabledValue {
	if (enabledValue != enabled_) {
		enabled_ = enabledValue;
		[soundEngine.setEnabled ( enabled_ );
		for( CDLongAudioSource *audioSource in audioSourceChannels) {
			audioSource.enabled = enabled_;
		}	
	}	
}

public function backgroundMusic () :CDLongAudioSource
{
	return backgroundMusic;
}	

//Load background music ready for playing
public function preloadBackgroundMusic:(String*) filePath
{
	[this.backgroundMusic.load ( filePath );	
}	

public function playBackgroundMusic ( filePath:String,  loop:Bool) :Void
{
	[this.backgroundMusic.load ( filePath );

	if (!willPlayBackgroundMusic || _mute) {
		trace("Denshion::CDAudioManager - play bgm aborted because audio is not exclusive or sound is muted");
		return;
	}
		
	if (loop) {
		[this.backgroundMusic setNumberOfLoops:-1();
	} else {
		[this.backgroundMusic setNumberOfLoops:0();
	}	
	[this.backgroundMusic play();
}

public function stopBackgroundMusic ()
{
	[this.backgroundMusic stop();
}

public function pauseBackgroundMusic ()
{
	[this.backgroundMusic pause();
}	

public function resumeBackgroundMusic ()
{
	if (!willPlayBackgroundMusic || _mute) {
		trace("Denshion::CDAudioManager - resume bgm aborted because audio is not exclusive or sound is muted");
		return;
	}
	
	[this.backgroundMusic resume();
}	

public function rewindBackgroundMusic ()
{
	[this.backgroundMusic rewind();
}	

public function setBackgroundMusicCompletionListener ( listener:id,  selector:Dynamic) :Void
	backgroundMusicCompletionListener = listener;
	backgroundMusicCompletionSelector = selector;
}	

/*
 * Call this method to have the audio manager automatically handle application resign and
 * become active.  Pass a tAudioManagerResignBehavior to indicate the desired behavior
 * for resigning and becoming active again.
 *
 * If autohandle is true then the applicationWillResignActive and applicationDidBecomActive 
 * methods are automatically called, otherwise you must call them yourthis at the appropriate time.
 *
 * Based on idea of Dominique Bongard
 */
public function setResignBehavior ( resignBehavior:tAudioManagerResignBehavior,  autoHandle { :Bool) :Void

	if (!_isObservingAppEvents && autoHandle) {
		[NSNotificationCenter.defaultCenter] addObserver:this	selector:@selector(applicationWillResignActive:) name:"UIApplicationWillResignActiveNotification".object ( null );
		[NSNotificationCenter.defaultCenter] addObserver:this	selector:@selector(applicationDidBecomeActive:) name:"UIApplicationDidBecomeActiveNotification".object ( null );
		[NSNotificationCenter.defaultCenter] addObserver:this	selector:@selector(applicationWillTerminate:) name:"UIApplicationWillTerminateNotification".object ( null );
		_isObservingAppEvents = true;
	}
	_resignBehavior = resignBehavior;
}	

public function applicationWillResignActive {
	this._resigned = true;
	
	//Set the audio sesssion to one that allows sharing so that other audio won't be clobbered on resume
	this.audioSessionSetCategory ( AVAudioSessionCategoryAmbient );
	
	switch (_resignBehavior) {
			
		case kAMRBStopPlay:
			
			for( CDLongAudioSource *audioSource in audioSourceChannels) {
				if (audioSource.isPlaying) {
					audioSource.systemPaused = true;
					audioSource.systemPauseLocation = audioSource.audioSourcePlayer.currentTime;
					audioSource.stop();
				} else {
					//Music is either paused or stopped, if it is paused it will be restarted
					//by OS so we will stop it.
					audioSource.systemPaused = false;
					audioSource.stop();
				}
			}
			break;
			
		case kAMRBStop:
			//Stop music regardless of whether it is playing or not because if it was paused
			//then the OS would resume it
			for( CDLongAudioSource *audioSource in audioSourceChannels) {
				audioSource.stop();
			}	
			
		default:
			break;
			
	}			
	trace("Denshion::CDAudioManager - handled resign active");
}

//Called when application resigns active only if setResignBehavior has been called
public function applicationWillResignActive:(NSNotification *) notification
{
	this.applicationWillResignActive();
}	

public function applicationDidBecomeActive {
	
	if (this._resigned) {
		_resigned = false;
		//Reset the mode incase something changed with audio while we were inactive
		this.setMode ( _mode );
		switch (_resignBehavior) {
				
			case kAMRBStopPlay:
				
				//Music had been stopped but stop maintains current time
				//so playing again will continue from where music was before resign active.
				//We check if music can be played because while we were inactive the user might have
				//done something that should force music to not play such as starting a track in the iPod
				if (this.willPlayBackgroundMusic) {
					for( CDLongAudioSource *audioSource in audioSourceChannels) {
						if (audioSource.systemPaused) {
							audioSource.resume();
							audioSource.systemPaused = false;
						}
					}
				}
				break;
				
			default:
				break;
				
		}
		trace("Denshion::CDAudioManager - audio manager handled become active");
	}
}

//Called when application becomes active only if setResignBehavior has been called
public function applicationDidBecomeActive:(NSNotification *) notification
{
	this.applicationDidBecomeActive();
}

//Called when application terminates only if setResignBehavior has been called 
public function applicationWillTerminate:(NSNotification *) notification
{
	trace("Denshion::CDAudioManager - audio manager handling terminate");
	this.stopBackgroundMusic();
}

/** The audio source completed playing */
public function cdAudioSourceDidFinishPlaying:(CDLongAudioSource *) audioSource {
	trace("Denshion::CDAudioManager - audio manager got told background music finished");
	if (backgroundMusicCompletionSelector != null) {
		[backgroundMusicCompletionListener.performSelector ( backgroundMusicCompletionSelector );
	}	
}	

public function beginInterruption {
	trace("Denshion::CDAudioManager - begin interruption");
	this.audioSessionInterrupted();
}

public function endInterruption {
	trace("Denshion::CDAudioManager - end interruption");
	this.audioSessionResumed();
}

#if ios >= 40000
public function endInterruptionWithFlags:(Int)flags {
	trace("Denshion::CDAudioManager - interruption ended with flags %i",flags);
	if (flags == AVAudioSessionInterruptionFlags_ShouldResume) {
		this.audioSessionResumed();
	}	
}
#end

public function audioSessionInterrupted 
{ 
    if (!_interrupted) {
		trace("Denshion::CDAudioManager - Audio session interrupted"); 
		_interrupted = true;

		// Deactivate the current audio session 
	    this.audioSessionSetActive ( false );
		
		if (alcGetCurrentContext() != null) {
			trace("Denshion::CDAudioManager - Setting OpenAL context to null"); 

			ALenum  error = AL_NO_ERROR;

			// set the current context to null will 'shutdown' openAL 
			alcMakeContextCurrent(null); 
		
			if((error = alGetError()) != AL_NO_ERROR) {
				CDLOG("Denshion::CDAudioManager - Error making context current %x\n", error);
			} 
			#pragma unused(error)
		}
	}	
} 

public function audioSessionResumed 
{ 
	if (_interrupted) {
		trace("Denshion::CDAudioManager - Audio session resumed"); 
		_interrupted = false;
		
		var activationResult :Bool = false;
		// Reactivate the current audio session
		activationResult = this.audioSessionSetActive ( true ); 
		
		//This code is to handle a problem with iOS 4.0 and 4.01 where reactivating the session can fail if
		//task switching is performed too rapidly. A test case that reliably reproduces the issue is to call the
		//iPhone and then hang up after two rings (timing may vary ;))
		//Basically we keep waiting and trying to let the OS catch up with itthis but the number of tries is
		//limited.
		if (!activationResult) {
			CDLOG("Denshion::CDAudioManager - Failure reactivating audio session, will try wait-try cycle"); 
			var activateCount :Int = 0;
			while (!activationResult && activateCount < 10) {
				NSThread.sleepForTimeInterval:0.5();
				activationResult = this.audioSessionSetActive ( true ); 
				activateCount++;
				trace("Denshion::CDAudioManager - Reactivation attempt %i status = %i",activateCount,activationResult); 
			}	
		}
		
		if (alcGetCurrentContext() == null) {
			trace("Denshion::CDAudioManager - Restoring OpenAL context"); 
			ALenum  error = AL_NO_ERROR;
			// Restore open al context 
			alcMakeContextCurrent(soundEngine.openALContext]); 
			if((error = alGetError()) != AL_NO_ERROR) {
				CDLOG("Denshion::CDAudioManager - Error making context current%x\n", error);
			} 
			#pragma unused(error)
		}	
	}	
}

+(void) end {
	sharedManager.release();
	sharedManager = null;
}	

}

///////////////////////////////////////////////////////////////////////////////////////
class CDLongAudioSourceFader

public function _setTargetProperty:(Float) newVal {
	((CDLongAudioSource*)target).volume = newVal;
}	

-(Float) _getTargetProperty {
	return ((CDLongAudioSource*)target).volume;
}

public function _stopTarget {
	//Pause instead of stop as stop releases resources and causes problems in the simulator
	[((CDLongAudioSource*)target) pause();
}

-(Class) _allowableType {
	return CDLongAudioSource.class();
}	

}
///////////////////////////////////////////////////////////////////////////////////////
class CDBufferManager

-(id) initWithEngine:(CDSoundEngine *) theSoundEngine {
	super.init();
		soundEngine = theSoundEngine;
		loadedBuffers = new NSDictionary().initWithCapacity ( CD_BUFFERS_START );
		freedBuffers = new Array<>().init();
		nextBufferId = 0;
	}	
	return this;
}	

public function release {
	loadedBuffers.release();
	freedBuffers.release();
	super.release();
}	

-(int) bufferForFile:(String*) filePath create:(Bool) create {
	
	NSNumber* soundId = (NSNumber*)[loadedBuffers.objectForKey ( filePath );
	if(soundId == null)
	{
		if (create) {
			NSNumber* bufferId = null;
			//First try to get a buffer from the free buffers
			if (freedBuffers.length > 0) {
				bufferId = [[freedBuffers.lastObject] retain] autorelease();
				freedBuffers.removeLastObject(); 
				trace("Denshion::CDBufferManager reusing buffer id %i",bufferId.intValue]);
			} else {
				bufferId = new NSNumber().initWithInt ( nextBufferId );
				bufferId.autorelease();
				trace("Denshion::CDBufferManager generating new buffer id %i",bufferId.intValue]);
				nextBufferId++;
			}
			
			if (soundEngine.loadBuffer:bufferId.intValue] filePath:filePath]) {
				//File successfully loaded
				trace("Denshion::CDBufferManager buffer loaded %@ "+bufferId,filePath);
				loadedBuffers.setObject ( bufferId, filePath );
				return bufferId.intValue();
			} else {
				//File didn't load, put buffer id on free list
				[freedBuffers.addObject ( bufferId );
				return kCDNoBuffer;
			}	
		} else {
			//No matching buffer was found
			return kCDNoBuffer;
		}	
	} else {
		return soundId.intValue();
	}	
}	

public function releaseBufferForFile:(String *) filePath {
	var bufferId :Int = this.bufferForFile ( filePath,( false );
	if (bufferId != kCDNoBuffer) {
		[soundEngine.unloadBuffer ( bufferId );
		[loadedBuffers.removeObjectForKey ( filePath );
		var freedBufferId :NSNumber = new NSNumber().initWithInt ( bufferId );
		freedBufferId.autorelease();
		[freedBuffers.addObject ( freedBufferId );
	}	
}	
}



