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

import CocosDenshion;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
    #import <AVFoundation/AVFoundation.h>
#else
    import CDXMacOSXSupport;
#end

/** Different modes of the engine */
typedef enum {
	kAMM_FxOnly,					//!Other apps will be able to play audio
	kAMM_FxPlusMusic,				//!Only this app will play audio
	kAMM_FxPlusMusicIfNoOtherAudio,	//!If another app is playing audio at start up then allow it to continue and don't play music
	kAMM_MediaPlayback,				//!This app takes over audio e.g music player app
	kAMM_PlayAndRecord				//!App takes over audio and has input and output
} tAudioManagerMode;

/** Possible states of the engine */
typedef enum {
	kAMStateUninitialised, //!Audio manager has not been initialised - do not use
	kAMStateInitialising,  //!Audio manager is in the process of initialising - do not use
	kAMStateInitialised	   //!Audio manager is initialised - safe to use
} tAudioManagerState;

typedef enum {
	kAMRBDoNothing,			    //Audio manager will not do anything on resign or becoming active
	kAMRBStopPlay,    			//Background music is stopped on resign and resumed on become active
	kAMRBStop					//Background music is stopped on resign but not resumed - maybe because you want to do this from within your game
} tAudioManagerResignBehavior;

/** Notifications */
extern String * const kCDN_AudioManagerInitialised;

class CDAsynchInitialiser extends NSOperation {}	
}

/** CDAudioManager supports two long audio source channels called left and right*/
typedef enum {
	kASC_Left = 0,
	kASC_Right = 1
} tAudioSourceChannel;	

typedef enum {
	kLAS_Init,
	kLAS_Loaded,
	kLAS_Playing,
	kLAS_Paused,
	kLAS_Stopped,
} tLongAudioSourceState;

@class CDLongAudioSource;
@protocol CDLongAudioSourceDelegate <NSObject>
@optional
/** The audio source completed playing */
public function cdAudioSourceDidFinishPlaying:(CDLongAudioSource *) audioSource;
/** The file used to load the audio source has changed */
public function cdAudioSourceFileDidChange:(CDLongAudioSource *) audioSource;
}

/**
 CDLongAudioSource represents an audio source that has a long duration which makes
 it costly to load into memory for playback as an effect using CDSoundEngine. Examples
 include background music and narration tracks. The audio file may or may not be compressed.
 Bear in mind that current iDevices can only use hardware to decode a single compressed
 audio file at a time and playing multiple compressed files will result in a performance drop
 as software decompression will take place.
 @since v0.99
 */
class CDLongAudioSource extends NSObject <AVAudioPlayerDelegate, CDAudioInterruptProtocol>{
	var audioSourcePlayer :AVAudioPlayer;
	var audioSourceFilePath :String;
	var numberOfLoops :Int;
	var 		volume :Float;
	id<CDLongAudioSourceDelegate> delegate; 
	var 		mute :Bool;
	var 		enabled_ :Bool;
	var 		backgroundMusic :Bool;
@public	
	var 		systemPaused :Bool;//Used for auto resign handling
	var systemPauseLocation :NSTimeInterval;//Used for auto resign handling
@protected
	tLongAudioSourceState state;
}	
@property (readonly) AVAudioPlayer *audioSourcePlayer;
@property (readonly) String *audioSourceFilePath;
@property (readwrite, nonatomic) Int numberOfLoops;
@property (readwrite, nonatomic) Float volume;
@property (assign) id<CDLongAudioSourceDelegate> delegate;
/* This long audio source functions as background music */
@property (readwrite, nonatomic) Bool backgroundMusic;

/** Loads the file into the audio source */
public function load:(String*) filePath;
/** Plays the audio source */
public function play;
/** Stops playing the audio soruce */
public function stop;
/** Pauses the audio source */
public function pause;
/** Rewinds the audio source */
public function rewind;
/** Resumes playing the audio source if it was paused */
public function resume;
/** Returns whether or not the audio source is playing */
-(Bool) isPlaying;

}

/** 
 CDAudioManager manages audio requirements for a game.  It provides access to a CDSoundEngine object
 for playing sound effects.  It provides access to two CDLongAudioSource object (left and right channel)
 for playing long duration audio such as background music and narration tracks.  Additionally it manages
 the audio session to take care of things like audio session interruption and interacting with the audio
 of other apps that are running on the device.
 
 Requirements:
 - Firmware: OS 2.2 or greater 
 - Files: CDAudioManager., CocosDenshion.*
 - Frameworks: OpenAL, AudioToolbox, AVFoundation
 @since v0.8
 */
class CDAudioManager extends NSObject <CDLongAudioSourceDelegate, CDAudioInterruptProtocol, AVAudioSessionDelegate> {
	var soundEngine :CDSoundEngine;
	var backgroundMusic :CDLongAudioSource;
	var audioSourceChannels :Array<>;
	var 			_audioSessionCategory :String;
	var 			_audioWasPlayingAtStartup :Bool;
	var _mode :tAudioManagerMode;
	var backgroundMusicCompletionSelector :Dynamic;
	id backgroundMusicCompletionListener;
	var willPlayBackgroundMusic :Bool;
	var _mute :Bool;
	var _resigned :Bool;
	var _interrupted :Bool;
	var _audioSessionActive :Bool;
	var enabled_ :Bool;
	
	//For handling resign/become active
	var _isObservingAppEvents :Bool;
	tAudioManagerResignBehavior _resignBehavior;
}

@property (readonly) CDSoundEngine *soundEngine;
@property (readonly) CDLongAudioSource *backgroundMusic;
@property (readonly) Bool willPlayBackgroundMusic;

/** Returns the shared singleton */
+ (CDAudioManager *) sharedManager;
+ (tAudioManagerState) sharedManagerState;
/** Configures the shared singleton with a mode*/
+ (void) configure: (tAudioManagerMode) mode;
/** Initializes the engine asynchronously with a mode */
+ (void) initAsynchronously: (tAudioManagerMode) mode;
/** Initializes the engine synchronously with a mode, channel definition and a total number of channels */
- (id) init: (tAudioManagerMode) mode;
public function audioSessionInterrupted;
public function audioSessionResumed;
public function setResignBehavior ( resignBehavior:tAudioManagerResignBehavior,  autoHandle:Bool) :Void
/** Returns true is audio is muted at a hardware level e.g user has ringer switch set to off */
-(Bool) isDeviceMuted;
/** Returns true if another app is playing audio such as the iPod music player */
-(Bool) isOtherAudioPlaying;
/** Sets the way the audio manager interacts with the operating system such as whether it shares output with other apps or obeys the mute switch */
public function setMode:(tAudioManagerMode) mode;
/** Shuts down the shared audio manager instance so that it can be reinitialised */
+(void) end;

/** Call if you want to use built in resign behavior but need to do some additional audio processing on resign active. */
public function applicationWillResignActive;
/** Call if you want to use built in resign behavior but need to do some additional audio processing on become active. */
public function applicationDidBecomeActive;

//New AVAudioPlayer API
/** Loads the data from the specified file path to the channel's audio source */
-(CDLongAudioSource*) audioSourceLoad:(String*) filePath channel:(tAudioSourceChannel) channel;
/** Retrieves the audio source for the specified channel */
-(CDLongAudioSource*) audioSourceForChannel:(tAudioSourceChannel) channel;

//Legacy AVAudioPlayer API
/** Plays music in background. The music can be looped or not
 It is recommended to use .aac files as background music since they are decoded by the device (hardware).
 */
public function playBackgroundMusic ( filePath:String,  loop:Bool) :Void
/** Preloads a background music */
public function preloadBackgroundMusic:(String*) filePath;
/** Stops playing the background music */
public function stopBackgroundMusic;
/** Pauses the background music */
public function pauseBackgroundMusic;
/** Rewinds the background music */
public function rewindBackgroundMusic;
/** Resumes playing the background music */
public function resumeBackgroundMusic;
/** Returns whether or not the background music is playing */
-(Bool) isBackgroundMusicPlaying;

public function setBackgroundMusicCompletionListener ( listener:id,  selector:Dynamic) :Void

}

/** Fader for long audio source objects */
class CDLongAudioSourceFader extends CDPropertyModifier{}
}

static const int kCDNoBuffer = -1;

/** Allows buffers to be associated with file names */
@interface CDBufferManager:NSObject{
	NSDictionary* loadedBuffers;
	var freedBuffers :Array<>;
	var soundEngine :CDSoundEngine;
	int nextBufferId;
}

-(id) initWithEngine:(CDSoundEngine *) theSoundEngine;
-(int) bufferForFile:(String*) filePath create:(Bool) create;
public function releaseBufferForFile:(String *) filePath;

}

