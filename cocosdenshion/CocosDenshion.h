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
@file
@b IMPORTANT
There are 3 different ways of using CocosDenshion. Depending on which you choose you 
will need to include different files and frameworks.

@par SimpleAudioEngine
This is recommended for basic audio requirements. If you just want to play some sound fx
and some background music and have no interest in learning the lower level workings then
this is the interface to use.

Requirements:
 - Firmware: OS 2.2 or greater 
 - Files: SimpleAudioEngine., CocosDenshion.*
 - Frameworks: OpenAL, AudioToolbox, AVFoundation
 
@par CDAudioManager
CDAudioManager is basically a thin wrapper around an AVAudioPlayer object used for playing
background music and a CDSoundEngine object used for playing sound effects. It manages the
audio session for you deals with audio session interruption. It is fairly low level and it
is expected you have some understanding of the underlying technologies. For example, for 
many use cases regarding background music it is expected you will work directly with the
backgroundMusic AVAudioPlayer which is exposed as a property.
 
Requirements:
  - Firmware: OS 2.2 or greater 
  - Files: CDAudioManager., CocosDenshion.*
  - Frameworks: OpenAL, AudioToolbox, AVFoundation

@par CDSoundEngine
CDSoundEngine is a sound engine built upon OpenAL and derived from Apple's oalTouch 
example. It can playback up to 32 sounds simultaneously with control over pitch, pan
and gain.  It can be set up to handle audio session interruption automatically.  You 
may decide to use CDSoundEngine directly instead of CDAudioManager or SimpleAudioEngine
because you require OS 2.0 compatibility.
 
Requirements:
  - Firmware: OS 2.0 or greater 
  - Files: CocosDenshion.*
  - Frameworks: OpenAL, AudioToolbox
 
*/ 

#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>

import CDConfig;


#if !defined(CD_DEBUG) || CD_DEBUG == 0
#define CDLOG(...) do {} while (0)
#define trace(...) do {} while (0)

#else CD_DEBUG == 1
#define CDLOG(...) trace(__VA_ARGS__)
#define trace(...) do {} while (0)

#else CD_DEBUG > 1
#define CDLOG(...) trace(__VA_ARGS__)
#define trace(...) trace(__VA_ARGS__)
#end // CD_DEBUG


import CDOpenALSupport;

//Tested source limit on 2.2.1 and 3.1.2 with up to 128 sources and appears to work. Older OS versions e.g 2.2 may support only 32
#define CD_SOURCE_LIMIT 32 //Total number of sources we will ever want, may actually get less
#define CD_NO_SOURCE 0xFEEDFAC //Return value indicating playback failed i.e. no source
#define CD_IGNORE_AUDIO_SESSION 0xBEEFBEE //Used internally to indicate audio session will not be handled
#define CD_MUTE      0xFEEDBAB //Return value indicating sound engine is muted or non functioning
#define CD_NO_SOUND = -1;

#define CD_SAMPLE_RATE_HIGH 44100
#define CD_SAMPLE_RATE_MID  22050
#define CD_SAMPLE_RATE_LOW  16000
#define CD_SAMPLE_RATE_BASIC 8000
#define CD_SAMPLE_RATE_DEFAULT 44100

extern String * const kCDN_BadAlContext;
extern String * const kCDN_AsynchLoadComplete;

extern Float const kCD_PitchDefault;
extern Float const kCD_PitchLowerOneOctave;
extern Float const kCD_PitchHigherOneOctave;
extern Float const kCD_PanDefault;
extern Float const kCD_PanFullLeft;
extern Float const kCD_PanFullRight;
extern Float const kCD_GainDefault;

enum bufferState {
	CD_BS_EMPTY = 0,
	CD_BS_LOADED = 1,
	CD_BS_FAILED = 2
};

typedef struct _sourceGroup {
	int startIndex;
	int currentIndex;
	int totalSources;
	bool enabled;
	bool nonInterruptible;
	int *sourceStatuses;//pointer into array of source status information
} sourceGroup;

typedef struct _bufferInfo {
	var bufferId :ALuint;
	int bufferState;
	void* bufferData;
	var format :ALenum;
	var sizeInBytes :ALsizei;
	var frequencyInHertz :ALsizei;
} bufferInfo;	

typedef struct _sourceInfo {
	bool usable;
	var sourceId :ALuint;
	var attachedBufferId :ALuint;
} sourceInfo;	

// CDAudioTransportProtocol

@protocol CDAudioTransportProtocol <NSObject>
/** Play the audio */
-(Bool) play;
/** Pause the audio, retain resources */
-(Bool) pause;
/** Stop the audio, release resources */
-(Bool) stop;
/** Return playback to beginning */
-(Bool) rewind;
}

// CDAudioInterruptProtocol

@protocol CDAudioInterruptProtocol <NSObject>
/** Is audio mute */
-(Bool) mute;
/** If true then audio is silenced but not stopped, calls to start new audio will proceed but silently */
public function setMute:(Bool) muteValue;
/** Is audio enabled */
-(Bool) enabled;
/** If NO then all audio is stopped and any calls to start new audio will be ignored */
public function setEnabled:(Bool) enabledValue;
}

// CDUtilities
/**
 Collection of utilities required by CocosDenshion
 */
class CDUtilities extends NSObject
{
}	

/** Fundamentally the same as the corresponding method is CCFileUtils but added to break binding to cocos2d */
+(String*) fullPathFromRelativePath:(String*) relPath;

}


// CDSoundEngine

/** CDSoundEngine is built upon OpenAL and works with SDK 2.0.
 CDSoundEngine is a sound engine built upon OpenAL and derived from Apple's oalTouch 
 example. It can playback up to 32 sounds simultaneously with control over pitch, pan
 and gain.  It can be set up to handle audio session interruption automatically.  You 
 may decide to use CDSoundEngine directly instead of CDAudioManager or SimpleAudioEngine
 because you require OS 2.0 compatibility.
 
 Requirements:
 - Firmware: OS 2.0 or greater 
 - Files: CocosDenshion.*
 - Frameworks: OpenAL, AudioToolbox
 
 @since v0.8
 */
@class CDSoundSource;
class CDSoundEngine extends NSObject <CDAudioInterruptProtocol> {
	
	var _buffers :bufferInfo;
	var _sources :sourceInfo;
	sourceGroup	    *_sourceGroups;
	var context :ALCcontext;
	var 	_sourceGroupTotal :Int;
	var _audioSessionCategory :UInt32;
	var 		_handleAudioSession :Bool;
	var _preMuteGain :ALFloat;
	NSObject        *_mutexBufferLoad;
	var 		mute_ :Bool;
	var 		enabled_ :Bool;

	var lastErrorCode_ :ALenum;
	var 		functioning_ :Bool;
	var 		asynchLoadProgress_ :Float;
	var 		getGainWorks_ :Bool;
	
	//For managing dynamic allocation of sources and buffers
	int sourceTotal_;
	int bufferTotal;
	 
}

@property (readwrite, nonatomic) ALFloat masterGain;
@property (readonly)  ALenum lastErrorCode;//Last OpenAL error code that was generated
@property (readonly)  Bool functioning;//Is the sound engine functioning
@property (readwrite) Float asynchLoadProgress;
@property (readonly)  Bool getGainWorks;//Does getting the gain for a source work
/** Total number of sources available */
@property (readonly) int sourceTotal;
/** Total number of source groups that have been defined */
@property (readonly) Int sourceGroupTotal;

/** Sets the sample rate for the audio mixer. For best performance this should match the sample rate of your audio content */
+(void) setMixerSampleRate:(Float32) sampleRate;

/** Initializes the engine with a group definition and a total number of groups */
public function init () :id;

/** Plays a sound in a channel group with a pitch, pan and gain. The sound could played looped or not */
-(ALuint) playSound:(int) soundId sourceGroupId:(int)sourceGroupId pitch:(Float) pitch pan:(Float) pan gain:(Float) gain loop:(Bool) loop;

/** Creates and returns a sound source object for the specified sound within the specified source group.
 */
-(CDSoundSource *) soundSourceForSound:(int) soundId sourceGroupId:(int) sourceGroupId;

/** Stops playing a sound */
public function stopSound:(ALuint) sourceId;
/** Stops playing a source group */
public function stopSourceGroup:(int) sourceGroupId;
/** Stops all playing sounds */
public function stopAllSounds;
public function defineSourceGroups:(NSArray*) sourceGroupDefinitions;
public function defineSourceGroups ( sourceGroupDefinitions:Int[],  total:Int) :Void
public function setSourceGroupNonInterruptible ( sourceGroupId:Int,  isNonInterruptible:Bool) :Void
public function setSourceGroupEnabled ( sourceGroupId:Int,  enabled:Bool) :Void
-(Bool) sourceGroupEnabled:(int) sourceGroupId;
-(Bool) loadBufferFromData:(int) soundId soundData:(ALvoid*) soundData format:(ALenum) format size:(ALsizei) size freq:(ALsizei) freq;
-(Bool) loadBuffer:(int) soundId filePath:(String*) filePath;
public function loadBuffersAsynchronously:(NSArray *) loadRequests;
-(Bool) unloadBuffer:(int) soundId;
-(ALCcontext *) openALContext;

/** Returns the duration of the buffer in seconds or a negative value if the buffer id is invalid */
-(Float) bufferDurationInSeconds:(int) soundId;
/** Returns the size of the buffer in bytes or a negative value if the buffer id is invalid */
-(ALsizei) bufferSizeInBytes:(int) soundId;
/** Returns the sampling frequency of the buffer in hertz or a negative value if the buffer id is invalid */
-(ALsizei) bufferFrequencyInHertz:(int) soundId;

/** Used internally, never call unless you know what you are doing */
public function _soundSourcePreRelease:(CDSoundSource *) soundSource;

}

// CDSoundSource
/** CDSoundSource is a wrapper around an OpenAL sound source.
 It allows you to manipulate properties such as pitch, gain, pan and looping while the 
 sound is playing. CDSoundSource is based on the old CDSourceWrapper class but with much
 added functionality.
 
 @since v1.0
 */
class CDSoundSource extends NSObject <CDAudioTransportProtocol, CDAudioInterruptProtocol> {
	var lastError :ALenum;
@public
	var _sourceId :ALuint;
	var _sourceIndex :ALuint;
	CDSoundEngine* _engine;
	int _soundId;
	var _preMuteGain :Float;
	var enabled_ :Bool;
	var mute_ :Bool;
}
@property (readwrite, nonatomic) Float pitch;
@property (readwrite, nonatomic) Float gain;
@property (readwrite, nonatomic) Float pan;
@property (readwrite, nonatomic) Bool looping;
@property (readonly)  Bool isPlaying;
@property (readwrite, nonatomic) int soundId;
/** Returns the duration of the attached buffer in seconds or a negative value if the buffer is invalid */
@property (readonly) Float durationInSeconds;

/** Stores the last error code that occurred. Check against AL_NO_ERROR */
@property (readonly) ALenum lastError;
/** Do not init yourthis, get an instance from the sourceForSound factory method on CDSoundEngine */
-(id)init:(ALuint) theSourceId sourceIndex:(int) index soundEngine:(CDSoundEngine*) engine;

}

// CDAudioInterruptTargetGroup

/** Container for objects that implement audio interrupt protocol i.e. they can be muted and enabled.
 Setting mute and enabled for the group propagates to all children. 
 Designed to be used with your CDSoundSource objects to get them to comply with global enabled and mute settings
 if that is what you want to do.*/
class CDAudioInterruptTargetGroup extends NSObject <CDAudioInterruptProtocol> {
	var mute_ :Bool;
	var enabled_ :Bool;
	var children_ :Array<>;
}
public function addAudioInterruptTarget:(NSObject<CDAudioInterruptProtocol>*) interruptibleTarget;
}

// CDAsynchBufferLoader

/** CDAsynchBufferLoader
 TODO
 */
class CDAsynchBufferLoader extends NSOperation {
	var _loadRequests :Array<>;
	var _soundEngine :CDSoundEngine;
}	

-(id) init:(NSArray *)loadRequests soundEngine:(CDSoundEngine *) theSoundEngine;

}

// CDBufferLoadRequest

/** CDBufferLoadRequest */
@interface CDBufferLoadRequest: NSObject
{
	var  filePath :String;
	int		 soundId;
	//id       loader;
}

@property (readonly) String *filePath;
@property (readonly) int soundId;

- (id)init:(int) theSoundId filePath:(const String *) theFilePath;
}

/** Interpolation type */
typedef enum {
	kIT_Linear,			//!Straight linear interpolation fade
	kIT_SCurve,			//!S curved interpolation
	kIT_Exponential 	//!Exponential interpolation
} tCDInterpolationType;

// CDFloatInterpolator
@interface CDFloatInterpolator: NSObject
{
	var start :Float;
	var end :Float;
	var lastValue :Float;
	tCDInterpolationType interpolationType;
}
@property (readwrite, nonatomic) Float start;
@property (readwrite, nonatomic) Float end;
@property (readwrite, nonatomic) tCDInterpolationType interpolationType;

/** Return a value between min and max based on t which represents fractional progress where 0 is the start
 and 1 is the end */
-(Float) interpolate:(Float) t;
-(id) init:(tCDInterpolationType) type startVal:(Float) startVal endVal:(Float) endVal;

}

// CDPropertyModifier

/** Base class for classes that modify properties such as pitch, pan and gain */
@interface CDPropertyModifier: NSObject
{
	var interpolator :CDFloatInterpolator;
	var startValue :Float;
	var endValue :Float;
	id target;
	var stopTargetWhenComplete :Bool;
	
}
@property (readwrite, nonatomic) Bool stopTargetWhenComplete;
@property (readwrite, nonatomic) Float startValue;
@property (readwrite, nonatomic) Float endValue;
@property (readwrite, nonatomic) tCDInterpolationType interpolationType;

-(id) init:(id) theTarget interpolationType:(tCDInterpolationType) type startVal:(Float) startVal endVal:(Float) endVal;
/** Set to a fractional value between 0 and 1 where 0 equals the start and 1 equals the end*/
public function modify:(Float) t;

public function _setTargetProperty:(Float) newVal;
-(Float) _getTargetProperty;
public function _stopTarget;
-(Class) _allowableType;

}

// CDSoundSourceFader

/** Fader for CDSoundSource objects */
class CDSoundSourceFader extends CDPropertyModifier{}
}

// CDSoundSourcePanner

/** Panner for CDSoundSource objects */
class CDSoundSourcePanner extends CDPropertyModifier{}
}

// CDSoundSourcePitchBender

/** Pitch bender for CDSoundSource objects */
class CDSoundSourcePitchBender extends CDPropertyModifier{}
}

// CDSoundEngineFader

/** Fader for CDSoundEngine objects */
class CDSoundEngineFader extends CDPropertyModifier{}
}




