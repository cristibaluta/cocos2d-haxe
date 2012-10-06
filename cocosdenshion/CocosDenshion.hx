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

ALvoid  alBufferDataStaticProc(const ALint bid, ALenum format, ALvoid* data, ALsizei size, ALsizei freq);
ALvoid  alcMacOSXMixerOutputRateProc(const ALdouble value);


typedef ALvoid	AL_APIENTRY	(*alBufferDataStaticProcPtr) (const ALint bid, ALenum format, ALvoid* data, ALsizei size, ALsizei freq);
ALvoid  alBufferDataStaticProc(const ALint bid, ALenum format, ALvoid* data, ALsizei size, ALsizei freq)
{
	static	alBufferDataStaticProcPtr	proc = null;
    
    if (proc == null) {
        proc = (alBufferDataStaticProcPtr) alcGetProcAddress(null, (const ALCchar*) "alBufferDataStatic");
    }
    
    if (proc)
        proc(bid, format, data, size, freq);
	
    return;
}

typedef ALvoid	AL_APIENTRY	(*alcMacOSXMixerOutputRateProcPtr) (const ALdouble value);
ALvoid  alcMacOSXMixerOutputRateProc(const ALdouble value)
{
	static	alcMacOSXMixerOutputRateProcPtr	proc = null;
    
    if (proc == null) {
        proc = (alcMacOSXMixerOutputRateProcPtr) alcGetProcAddress(null, (const ALCchar*) "alcMacOSXMixerOutputRate");
    }
    
    if (proc)
        proc(value);
	
    return;
}

String * const kCDN_BadAlContext = "kCDN_BadAlContext";
String * const kCDN_AsynchLoadComplete = "kCDN_AsynchLoadComplete";
Float const kCD_PitchDefault = 1.0;
Float const kCD_PitchLowerOneOctave = 0.5;
Float const kCD_PitchHigherOneOctave = 2.0;
Float const kCD_PanDefault = 0.0;
Float const kCD_PanFullLeft = -1.0;
Float const kCD_PanFullRight = 1.0;
Float const kCD_GainDefault = 1.0;

@interface CDSoundEngine (PrivateMethods)
-(Bool) _initOpenAL;
public function _testGetGain;
public function _dumpSourceGroupsInfo;
public function _getSourceIndexForSourceGroup;
public function _freeSourceGroups;
-(Bool) _setUpSourceGroups:(int[]) definitions total:(Int) total; 
}

// -
// CDUtilities

class CDUtilities

+(String*) fullPathFromRelativePath:(String*) relPath
{
	// do not convert an absolute path (starting with '/')
	if((relPath.length] > 0) && (relPath.characterAtIndex ( 0 ) == '/'))
	{
		return relPath;
	}
	
	var imagePathComponents :Array<> = [Array<> arrayWithArray:relPath.pathComponents]();
	var  file :String = imagePathComponents.lastObject();
	
	imagePathComponents.removeLastObject();
	var  imageDirectory :String = [String.pathWithComponents ( imagePathComponents );
	
	var  fullpath :String = [NSBundle.mainBundle] pathForResource:file ofType ( null, imageDirectory );
	if (fullpath == null)
		fullpath = relPath;
	
	return fullpath;	
}

}

// -
// CDSoundEngine

class CDSoundEngine

static Float32 _mixerSampleRate;
static Bool _mixerRateSet = false;

public var lastErrorCode (get_lastErrorCode, set_lastErrorCode) :;
public var functioning (get_functioning, set_functioning) :;
public var asynchLoadProgress (get_asynchLoadProgress, set_asynchLoadProgress) :;
public var getGainWorks (get_getGainWorks, set_getGainWorks) :;
public var sourceTotal (get_sourceTotal, set_sourceTotal) :;

+ (void) setMixerSampleRate:(Float32) sampleRate {
	_mixerRateSet = true;
	_mixerSampleRate = sampleRate;
}	

public function _testGetGain {
	var testValue :Float = 0.7;
	var testSourceId :ALuint = _sources[0].sourceId;
	alSourcef(testSourceId, AL_GAIN, 0.0);//Start from know value
	alSourcef(testSourceId, AL_GAIN, testValue);
	var gainVal :ALFloat;
	alGetSourcef(testSourceId, AL_GAIN, &gainVal);
	getGainWorks_ = (gainVal == testValue);
}

//Generate sources one at a time until we fail
public function _generateSources {
	
	_sources = (sourceInfo*)malloc( sizeof(_sources[0]) * CD_SOURCE_LIMIT);
	var hasFailed :Bool = false;
	sourceTotal_ = 0;
	alGetError();//Clear error
	while (!hasFailed && sourceTotal_ < CD_SOURCE_LIMIT) {
		alGenSources(1, &(_sources[sourceTotal_].sourceId));
		if (alGetError() == AL_NO_ERROR) {
			//Now try attaching source to null buffer
			alSourcei(_sources[sourceTotal_].sourceId, AL_BUFFER, 0);
			if (alGetError() == AL_NO_ERROR) {
				_sources[sourceTotal_].usable = true;	
				sourceTotal_++;
			} else {
				hasFailed = true;
			}	
		} else {
			_sources[sourceTotal_].usable = false;
			hasFailed = true;
		}	
	}
	//Mark the rest of the sources as not usable
	for (int i=sourceTotal_; i < CD_SOURCE_LIMIT; i++) {
		_sources[i].usable = false;
	}	
}	

public function _generateBuffers ( startIndex:Int, endIndex :Int) :Void
	if (_buffers) {
		alGetError();
		for (int i=startIndex; i <= endIndex; i++) {
			alGenBuffers(1, &_buffers[i].bufferId);
			_buffers[i].bufferData = null;
			if (alGetError() == AL_NO_ERROR) {
				_buffers[i].bufferState = CD_BS_EMPTY;
			} else {
				_buffers[i].bufferState = CD_BS_FAILED;
				CDLOG("Denshion::CDSoundEngine - buffer creation failed %i",i);
			}	
		}
	}	
}

/**
 * Internal method called during init
 */
public function _initOpenAL () :Bool
{
	//var error :ALenum;
	context = null;
	ALCdevice		*newDevice = null;

	//Set the mixer rate for the audio mixer
	if (!_mixerRateSet) {
		_mixerSampleRate = CD_SAMPLE_RATE_DEFAULT;
	}
	alcMacOSXMixerOutputRateProc(_mixerSampleRate);
	trace("Denshion::CDSoundEngine - mixer output rate set to %0.2",_mixerSampleRate);
	
	// Create a new OpenAL Device
	// Pass null to specify the system's default output device
	newDevice = alcOpenDevice(null);
	if (newDevice != null)
	{
		// Create a new OpenAL Context
		// The new context will render to the OpenAL Device just created 
		context = alcCreateContext(newDevice, 0);
		if (context != null)
		{
			// Make the new context the Current OpenAL Context
			alcMakeContextCurrent(context);
			
			// Create some OpenAL Buffer Objects
			this._generateBuffers:0 endIndex:bufferTotal-1();
			
			// Create some OpenAL Source Objects
			this._generateSources();
			
		}
	} else {
		return false;//No device
	}	
	alGetError();//Clear error
	return true;
}

public function release () {
	
	ALCcontext	*currentContext = null;
    ALCdevice	*device = null;
	
	this.stopAllSounds();

	trace("Denshion::CDSoundEngine - Deallocing sound engine.");
	this._freeSourceGroups();
	
	// Delete the Sources
	trace("Denshion::CDSoundEngine - deleting sources.");
	for (int i=0; i < sourceTotal_; i++) {
		alSourcei(_sources[i].sourceId, AL_BUFFER, 0);//Detach from current buffer
	    alDeleteSources(1, &(_sources[i].sourceId));
		if((lastErrorCode_ = alGetError()) != AL_NO_ERROR) {
			CDLOG("Denshion::CDSoundEngine - Error deleting source! %x\n", lastErrorCode_);
		} 
	}	

	// Delete the Buffers
	trace("Denshion::CDSoundEngine - deleting buffers.");
	for (int i=0; i < bufferTotal; i++) {
		alDeleteBuffers(1, &_buffers[i].bufferId);
#if CD_USE_STATIC_BUFFERS
		if (_buffers[i].bufferData) {
			free(_buffers[i].bufferData);
		}	
#end		
	}	
	trace("Denshion::CDSoundEngine - free buffers.");
	_buffers = null;
    currentContext = alcGetCurrentContext();
    //Get device for active context
    device = alcGetContextsDevice(currentContext);
    //Release context
	trace("Denshion::CDSoundEngine - destroy context.");
    alcDestroyContext(currentContext);
    //Close device
	trace("Denshion::CDSoundEngine - close device.");
    alcCloseDevice(device);
	trace("Denshion::CDSoundEngine - free sources.");
	_sources = null;
	
	//Release mutexes
	_mutexBufferLoad.release();
	
	super.release();
}	

-(Int) sourceGroupTotal {
	return _sourceGroupTotal;
}	

public function _freeSourceGroups 
{
	trace("Denshion::CDSoundEngine freeing source groups");
	if(_sourceGroups) {
		for (int i=0; i < _sourceGroupTotal; i++) {
			if (_sourceGroups[i].sourceStatuses) {
				free(_sourceGroups[i].sourceStatuses);
				trace("Denshion::CDSoundEngine freed source statuses %i",i);
			}	
		}
		_sourceGroups = null;
	}	
}	

-(Bool) _redefineSourceGroups:(int[]) definitions total:(Int) total
{
	if (_sourceGroups) {
		//Stop all sounds
		this.stopAllSounds();
		//Need to free source groups
		this._freeSourceGroups();
	}
	return this._setUpSourceGroups ( definitions, total );
}	

-(Bool) _setUpSourceGroups:(int[]) definitions total:(Int) total 
{
	_sourceGroups = (sourceGroup *)malloc( sizeof(_sourceGroups[0]) * total);
	if(!_sourceGroups) {
		CDLOG("Denshion::CDSoundEngine - source groups memory allocation failed");
		return false;
	}
	
	_sourceGroupTotal = total;
	var sourceCount :Int = 0;
	for (int i=0; i < _sourceGroupTotal; i++) {
		
		_sourceGroups[i].startIndex = 0;
		_sourceGroups[i].currentIndex = _sourceGroups[i].startIndex;
		_sourceGroups[i].enabled = false;
		_sourceGroups[i].nonInterruptible = false;
		_sourceGroups[i].totalSources = definitions[i();
		_sourceGroups[i].sourceStatuses = malloc(sizeof(_sourceGroups[i].sourceStatuses[0]) * _sourceGroups[i].totalSources);
		if (_sourceGroups[i].sourceStatuses) {
			for (int j=0; j < _sourceGroups[i].totalSources; j++) {
				//First bit is used to indicate whether source is locked, index is shifted back 1 bit
				_sourceGroups[i].sourceStatuses[j] = (sourceCount + j) << 1;	
			}	
		}	
		sourceCount += definitions[i();
	}
	return true;
}

public function defineSourceGroups ( sourceGroupDefinitions:Int[],  total:Int) :Void
	this._redefineSourceGroups ( sourceGroupDefinitions, total );
}

public function defineSourceGroups:(NSArray*) sourceGroupDefinitions {
	trace("Denshion::CDSoundEngine - source groups defined by NSArray.");
	var totalDefs :Int = sourceGroupDefinitions.count();
	int* defs = (int *)malloc( sizeof(int) * totalDefs);
	var currentIndex :Int = 0;
	for (id currentDef in sourceGroupDefinitions) {
		if (currentDef.isKindOfClass:NSNumber.class]]) {
			defs[currentIndex] = (int)[(NSNumber*)currentDef integerValue();
			trace("Denshion::CDSoundEngine - found definition %i.",defs[currentIndex]);
		} else {
			CDLOG("Denshion::CDSoundEngine - warning, did not understand source definition.");
			defs[currentIndex] = 0;
		}	
		currentIndex++;
	}
	this._redefineSourceGroups ( defs, totalDefs );
	defs = null;
}	

- (id)init
{	
	super.init();
		
		//Create mutexes
		_mutexBufferLoad = new NSObject().init();
		
		asynchLoadProgress_ = 0.0;
		
		bufferTotal = CD_BUFFERS_START;
		_buffers = (bufferInfo *)malloc( sizeof(_buffers[0]) * bufferTotal);
	
		// Initialize our OpenAL environment
		if (this._initOpenAL]) {
			//Set up the default source group - a single group that contains all the sources
			int sourceDefs[1();
			sourceDefs[0] = this.sourceTotal;
			this._setUpSourceGroups:sourceDefs total:1();

			functioning_ = true;
			//Synchronize premute gain
			_preMuteGain = this.masterGain;
			mute_ = false;
			enabled_ = true;
			//Test whether get gain works for sources
			this._testGetGain();
		} else {
			//Something went wrong with OpenAL
			functioning_ = false;
		}
	}
	
	return this;
}

/**
 * Delete the buffer identified by soundId
 * @return true if buffer deleted successfully, otherwise false
 */
- (Bool) unloadBuffer:(int) soundId 
{
	//Ensure soundId is within array bounds otherwise memory corruption will occur
	if (soundId < 0 || soundId >= bufferTotal) {
		CDLOG("Denshion::CDSoundEngine - soundId is outside array bounds, maybe you need to increase CD_MAX_BUFFERS");
		return false;
	}	
	
	//Before a buffer can be deleted any sources that are attached to it must be stopped
	for (int i=0; i < sourceTotal_; i++) {
		//Note: tried getting the AL_BUFFER attribute of the source instead but doesn't
		//appear to work on a device - just returned zero.
		if (_buffers[soundId].bufferId == _sources[i].attachedBufferId) {
			
			CDLOG("Denshion::CDSoundEngine - Found attached source %i %i %i",i,_buffers[soundId].bufferId,_sources[i].sourceId);
#if CD_USE_STATIC_BUFFERS
			//When using static buffers a crash may occur if a source is playing with a buffer that is about
			//to be deleted even though we stop the source and successfully delete the buffer. Crash is confirmed
			//on 2.2.1 and 3.1.2, however, it will only occur if a source is used rapidly after having its prior
			//data deleted. To avoid any possibility of the crash we wait for the source to finish playing.
			var state :ALint;
			
			alGetSourcei(_sources[i].sourceId, AL_SOURCE_STATE, &state);
			
			if (state == AL_PLAYING) {
				CDLOG("Denshion::CDSoundEngine - waiting for source to complete playing before removing buffer data"); 
				alSourcei(_sources[i].sourceId, AL_LOOPING, false);//Turn off looping otherwise loops will never end
				while (state == AL_PLAYING) {
					alGetSourcei(_sources[i].sourceId, AL_SOURCE_STATE, &state);
					usleep(10000);
				}
			}
#end			
			//Stop source and detach
			alSourceStop(_sources[i].sourceId);	
			if((lastErrorCode_ = alGetError()) != AL_NO_ERROR) {
				CDLOG("Denshion::CDSoundEngine - error stopping source: %x\n", lastErrorCode_);
			}	
			
			alSourcei(_sources[i].sourceId, AL_BUFFER, 0);//Attach to "null" buffer to detach
			if((lastErrorCode_ = alGetError()) != AL_NO_ERROR) {
				CDLOG("Denshion::CDSoundEngine - error detaching buffer: %x\n", lastErrorCode_);
			} else {
				//Record that source is now attached to nothing
				_sources[i].attachedBufferId = 0;
			}	
		}	
	}	
	
	alDeleteBuffers(1, &_buffers[soundId].bufferId);
	if((lastErrorCode_ = alGetError()) != AL_NO_ERROR) {
		CDLOG("Denshion::CDSoundEngine - error deleting buffer: %x\n", lastErrorCode_);
		_buffers[soundId].bufferState = CD_BS_FAILED;
		return false;
	} else {
#if CD_USE_STATIC_BUFFERS
		//Free previous data, if alDeleteBuffer has returned without error then no 
		if (_buffers[soundId].bufferData) {
			trace("Denshion::CDSoundEngine - freeing static data for soundId %i @ %i",soundId,_buffers[soundId].bufferData);
			free(_buffers[soundId].bufferData);//Free the old data
			_buffers[soundId].bufferData = null;
		}
#end		
	}	
	
	alGenBuffers(1, &_buffers[soundId].bufferId);
	if((lastErrorCode_ = alGetError()) != AL_NO_ERROR) {
		CDLOG("Denshion::CDSoundEngine - error regenerating buffer: %x\n", lastErrorCode_);
		_buffers[soundId].bufferState = CD_BS_FAILED;
		return false;
	} else {
		//We now have an empty buffer
		_buffers[soundId].bufferState = CD_BS_EMPTY;
		trace("Denshion::CDSoundEngine - buffer %i successfully unloaded\n",soundId);
		return true;
	}	
}	

/**
 * Load buffers asynchronously 
 * Check asynchLoadProgress for progress. asynchLoadProgress represents fraction of completion. When it equals 1.0 loading
 * is complete. NB: asynchLoadProgress is simply based on the number of load requests, it does not take into account
 * file sizes.
 * @param An array of CDBufferLoadRequest objects
 */
public function loadBuffersAsynchronously:(NSArray *) loadRequests {
	@synchronized(this) {
		asynchLoadProgress_ = 0.0;
		var loaderOp :CDAsynchBufferLoader = [new CDAsynchBufferLoader().init:loadRequests soundEngine:this] autorelease();
		var opQ :NSOperationQueue = [new NSOperationQueue().init] autorelease();
		[opQ.addOperation ( loaderOp );
	}
}	

-(Bool) _resizeBuffers:(int) increment {
	
	var tmpBufferInfos :Void = realloc( _buffers, sizeof(_buffers[0]) * (bufferTotal + increment) );
	
	if(!tmpBufferInfos) {
		tmpBufferInfos = null;
		return false;
	} else {
		_buffers = tmpBufferInfos;
		var oldBufferTotal :Int = bufferTotal;
		bufferTotal = bufferTotal + increment;
		this._generateBuffers:oldBufferTotal endIndex:bufferTotal-1();
		return true;
	}	
}	

-(Bool) loadBufferFromData:(int) soundId soundData:(ALvoid*) soundData format:(ALenum) format size:(ALsizei) size freq:(ALsizei) freq {

	@synchronized(_mutexBufferLoad) {
		
		if (!functioning_) {
			//OpenAL initialisation has previously failed
			CDLOG("Denshion::CDSoundEngine - Loading buffer failed because sound engine state != functioning");
			return false;
		}
		
		//Ensure soundId is within array bounds otherwise memory corruption will occur
		if (soundId < 0) {
			CDLOG("Denshion::CDSoundEngine - soundId is negative");
			return false;
		}
		
		if (soundId >= bufferTotal) {
			//Need to resize the buffers
			var requiredIncrement :Int = CD_BUFFERS_INCREMENT;
			while (bufferTotal + requiredIncrement < soundId) {
				requiredIncrement += CD_BUFFERS_INCREMENT;
			}
			trace("Denshion::CDSoundEngine - attempting to resize buffers by %i for sound %i",requiredIncrement,soundId);
			if (!this._resizeBuffers:requiredIncrement]) {
				CDLOG("Denshion::CDSoundEngine - buffer resize failed");
				return false;
			}	
		}	
		
		if (soundData)
		{
			if (_buffers[soundId].bufferState != CD_BS_EMPTY) {
				trace("Denshion::CDSoundEngine - non empty buffer, regenerating");
				if (!this.unloadBuffer:soundId]) {
					//Deletion of buffer failed, delete buffer routine has set buffer state and lastErrorCode
					return false;
				}	
			}	
			
#if CD_DEBUG
			//Check that sample rate matches mixer rate and warn if they do not
			if (freq != (int)_mixerSampleRate) {
				trace("Denshion::CDSoundEngine - WARNING sample rate does not match mixer sample rate performance may not be optimal.");
			}	
#end		
			
#if CD_USE_STATIC_BUFFERS
			alBufferDataStaticProc(_buffers[soundId].bufferId, format, soundData, size, freq);
			_buffers[soundId].bufferData = data;//Save the pointer to the new data
#else		
			alBufferData(_buffers[soundId].bufferId, format, soundData, size, freq);
#end
			if((lastErrorCode_ = alGetError()) != AL_NO_ERROR) {
				CDLOG("Denshion::CDSoundEngine -  error attaching audio to buffer: %x", lastErrorCode_);
				_buffers[soundId].bufferState = CD_BS_FAILED;
				return false;
			} 
		} else {
			CDLOG("Denshion::CDSoundEngine Buffer data is null!");
			_buffers[soundId].bufferState = CD_BS_FAILED;
			return false;
		}	
		
		_buffers[soundId].format = format;
		_buffers[soundId].sizeInBytes = size;
		_buffers[soundId].frequencyInHertz = freq;
		_buffers[soundId].bufferState = CD_BS_LOADED;
		trace("Denshion::CDSoundEngine Buffer %i loaded format:%i freq:%i size:%i",soundId,format,freq,size);
		return true;
	}//end mutex
}	

/**
 * Load sound data for later play back.
 * @return true if buffer loaded okay for play back otherwise false
 */
- (Bool) loadBuffer:(int) soundId filePath:(String*) filePath
{

	ALvoid* data;
	ALenum  format;
	var size :ALsizei;
	var freq :ALsizei;
	
	trace("Denshion::CDSoundEngine - Loading openAL buffer %i "+ soundId, filePath);
	
	var fileURL :CFURLRef = null;
	var  path :String = [CDUtilities.fullPathFromRelativePath ( filePath );
	if (path) {
		fileURL = (CFURLRef)[NSURL.fileURLWithPath ( path ) retain();
	}

	if (fileURL)
	{
		data = CDGetOpenALAudioData(fileURL, &size, &format, &freq);
		CFRelease(fileURL);
		var result :Bool = this.loadBufferFromData:soundId soundData:data format:format size ( size, freq );
#ifndef CD_USE_STATIC_BUFFERS
		data = null;//Data can be freed here because alBufferData performs a memcpy		
#end
		return result;
	} else {
		CDLOG("Denshion::CDSoundEngine Could not find file!\n");
		//Don't change buffer state here as it will be the same as before method was called	
		return false;
	}	
}

-(Bool) validateBufferId:(int) soundId {
	if (soundId < 0 || soundId >= bufferTotal) {
		trace("Denshion::CDSoundEngine - validateBufferId buffer outside range %i",soundId);
		return false;
	} else if (_buffers[soundId].bufferState != CD_BS_LOADED) {
		trace("Denshion::CDSoundEngine - validateBufferId invalide buffer state %i",soundId);
		return false;
	} else {
		return true;
	}	
}	

-(Float) bufferDurationInSeconds:(int) soundId {
	if (this.validateBufferId:soundId]) {
		var factor :Float = 0.0;
		switch (_buffers[soundId].format) {
			case AL_FORMAT_MONO8:
				factor = 1.0;
				break;
			case AL_FORMAT_MONO16:
				factor = 0.5;
				break;
			case AL_FORMAT_STEREO8:
				factor = 0.5;
				break;
			case AL_FORMAT_STEREO16:
				factor = 0.25;
				break;
		}	
		return (Float)_buffers[soundId].sizeInBytes/(Float)_buffers[soundId].frequencyInHertz * factor;
	} else {
		return -1.0;
	}	
}	

-(ALsizei) bufferSizeInBytes:(int) soundId {
	if (this.validateBufferId:soundId]) {
		return _buffers[soundId].sizeInBytes;
	} else {
		return -1.0;
	}	
}	

-(ALsizei) bufferFrequencyInHertz:(int) soundId {
	if (this.validateBufferId:soundId]) {
		return _buffers[soundId].frequencyInHertz;
	} else {
		return -1.0;
	}	
}	

public function masterGain () :ALFloat {
	if (mute_) {
		//When mute the real gain will always be 0 therefore return the preMuteGain value
		return _preMuteGain;
	} else {	
		var gain :ALFloat;
		alGetListenerf(AL_GAIN, &gain);
		return gain;
	}	
}	

/**
 * Overall gain setting multiplier. e.g 0.5 is half the gain.
 */
public function setMasterGain:(ALFloat) newGainValue {
	if (mute_) {
		_preMuteGain = newGainValue;
	} else {	
		alListenerf(AL_GAIN, newGainValue);
	}	
}

// CDSoundEngine AudioInterrupt protocol
public function mute () :Bool {
	return mute_;
}	

/**
 * Setting mute silences all sounds but playing sounds continue to advance playback
 */
public function setMute:(Bool) newMuteValue {
	
	if (newMuteValue == mute_) {
		return;
	}
	
	mute_ = newMuteValue;
	if (mute_) {
		//Remember what the gain was
		_preMuteGain = this.masterGain;
		//Set gain to 0 - do not use the property as this will adjust preMuteGain when muted
		alListenerf(AL_GAIN, 0.0);
	} else {
		//Restore gain to what it was before being muted
		this.masterGain = _preMuteGain;
	}	
}

public function enabled () :Bool {
	return enabled_;
}

public function setEnabled ( enabledValue:Bool )
{
	if (enabled_ == enabledValue) {
		return;
	}
	enabled_ = enabledValue;
	if (enabled_ == false) {
		this.stopAllSounds();
	}
}	

public function _lockSource ( sourceIndex:Int,  lock:Bool) :Void
	var found :Bool = false;
	for (int i=0; i < _sourceGroupTotal && !found; i++) {
		if (_sourceGroups[i].sourceStatuses) {
			for (int j=0; j < _sourceGroups[i].totalSources && !found; j++) {
				//First bit is used to indicate whether source is locked, index is shifted back 1 bit
				if((_sourceGroups[i].sourceStatuses[j] >> 1)==sourceIndex) {
					if (lock) {
						//Set first bit to lock this source
						_sourceGroups[i].sourceStatuses[j] |= 1;
					} else {
						//Unset first bit to unlock this source
						_sourceGroups[i].sourceStatuses[j] &= ~1; 
					}	
					found = true;
				}	
			}	
		}	
	}
}	

-(int) _getSourceIndexForSourceGroup:(int)sourceGroupId 
{
	//Ensure source group id is valid to prevent memory corruption
	if (sourceGroupId < 0 || sourceGroupId >= _sourceGroupTotal) {
		CDLOG("Denshion::CDSoundEngine invalid source group id %i",sourceGroupId);
		return CD_NO_SOURCE;
	}	

	var sourceIndex :Int = -1;//Using -1 to indicate no source found
	var complete :Bool = false;
	var sourceState :ALint = 0;
	var thisSourceGroup :sourceGroup = &_sourceGroups[sourceGroupId();
	thisSourceGroup.currentIndex = thisSourceGroup.startIndex;
	while (!complete) {
		//Iterate over sources looking for one that is not locked, first bit indicates if source is locked
		if ((thisSourceGroup.sourceStatuses[thisSourceGroup.currentIndex] & 1) == 0) {
			//This source is not locked
			sourceIndex = thisSourceGroup.sourceStatuses[thisSourceGroup.currentIndex] >> 1;//shift back to get the index
			if (thisSourceGroup.nonInterruptible) {
				//Check if this source is playing, if so it can't be interrupted
				alGetSourcei(_sources[sourceIndex].sourceId, AL_SOURCE_STATE, &sourceState);
				if (sourceState != AL_PLAYING) {
					//complete = true;
					//Set start index so next search starts at the next position
					thisSourceGroup.startIndex = thisSourceGroup.currentIndex + 1;
					break;
				} else {
					sourceIndex = -1;//The source index was no good because the source was playing
				}	
			} else {	
				//complete = true;
				//Set start index so next search starts at the next position
				thisSourceGroup.startIndex = thisSourceGroup.currentIndex + 1;
				break;
			}	
		}
		thisSourceGroup.currentIndex++;
		if (thisSourceGroup.currentIndex >= thisSourceGroup.totalSources) {
			//Reset to the beginning
			thisSourceGroup.currentIndex = 0;	
		}	
		if (thisSourceGroup.currentIndex == thisSourceGroup.startIndex) {
			//We have looped around and got back to the start
			complete = true;
		}	
	}

	//Reset start index to beginning if beyond bounds
	if (thisSourceGroup.startIndex >= thisSourceGroup.totalSources) {
		thisSourceGroup.startIndex = 0;	
	}	
	
	if (sourceIndex >= 0) {
		return sourceIndex;
	} else {	
		return CD_NO_SOURCE;
	}	
	
}	

/**
 * Play a sound.
 * @param soundId the id of the sound to play (buffer id).
 * @param SourceGroupId the source group that will be used to play the sound.
 * @param pitch pitch multiplier. e.g 1.0 is unaltered, 0.5 is 1 octave lower. 
 * @param pan stereo position. -1 is fully left, 0 is centre and 1 is fully right.
 * @param gain gain multiplier. e.g. 1.0 is unaltered, 0.5 is half the gain
 * @param loop should the sound be looped or one shot.
 * @return the id of the source being used to play the sound or CD_MUTE if the sound engine is muted or non functioning 
 * or CD_NO_SOURCE if a problem occurs setting up the source
 * 
 */
- (ALuint)playSound:(int) soundId sourceGroupId:(int)sourceGroupId pitch:(Float) pitch pan:(Float) pan gain:(Float) gain loop:(Bool) loop {

#if CD_DEBUG
	//Sanity check parameters - only in DEBUG
	if (soundId >= 0, "soundId can not be negative");
	if (soundId < bufferTotal, "soundId exceeds limit");
	if (sourceGroupId >= 0, "sourceGroupId can not be negative");
	if (sourceGroupId < _sourceGroupTotal, "sourceGroupId exceeds limit");
	if (pitch > 0, "pitch must be greater than zero");
	if (pan >= -1 && pan <= 1, "pan must be between -1 and 1");
	if (gain >= 0, "gain can not be negative");
#end
	//If mute or initialisation has failed or buffer is not loaded then do nothing
	if (!enabled_ || !functioning_ || _buffers[soundId].bufferState != CD_BS_LOADED || _sourceGroups[sourceGroupId].enabled) {
#if CD_DEBUG
		if (!functioning_) {
			trace("Denshion::CDSoundEngine - sound playback aborted because sound engine is not functioning");
		} else if (_buffers[soundId].bufferState != CD_BS_LOADED) {
			trace("Denshion::CDSoundEngine - sound playback aborted because buffer %i is not loaded", soundId);
		}	
#end		
		return CD_MUTE;
	}	

	var sourceIndex :Int = this._getSourceIndexForSourceGroup ( sourceGroupId );//This method ensures sourceIndex is valid
	
	if (sourceIndex != CD_NO_SOURCE) {
		var state :ALint;
		var source :ALuint = _sources[sourceIndex].sourceId;
		var buffer :ALuint = _buffers[soundId].bufferId;
		alGetError();//Clear the error code	
		alGetSourcei(source, AL_SOURCE_STATE, &state);
		if (state == AL_PLAYING) {
			alSourceStop(source);
		}	
		alSourcei(source, AL_BUFFER, buffer);//Attach to sound
		alSourcef(source, AL_PITCH, pitch);//Set pitch
		alSourcei(source, AL_LOOPING, loop);//Set looping
		alSourcef(source, AL_GAIN, gain);//Set gain/volume
		var sourcePosAL[] :Float = {pan, 0.0, 0.0};//Set position - just using left and right panning
		alSourcefv(source, AL_POSITION, sourcePosAL);
		alGetError();//Clear the error code
		alSourcePlay(source);
		if((lastErrorCode_ = alGetError()) == AL_NO_ERROR) {
			//Everything was okay
			_sources[sourceIndex].attachedBufferId = buffer;
			return source;
		} else {
			if (alcGetCurrentContext() == null) {
				trace("Denshion::CDSoundEngine - posting bad OpenAL context message");
				[NSNotificationCenter.defaultCenter] postNotificationName ( kCDN_BadAlContext, null );
			}				
			return CD_NO_SOURCE;
		}	
	} else {	
		return CD_NO_SOURCE;
	}	
}

-(Bool) _soundSourceAttachToBuffer:(CDSoundSource*) soundSource soundId:(int) soundId  {
	//Attach the source to the buffer
	var state :ALint;
	var source :ALuint = soundSource._sourceId;
	var buffer :ALuint = _buffers[soundId].bufferId;
	alGetSourcei(source, AL_SOURCE_STATE, &state);
	if (state == AL_PLAYING) {
		alSourceStop(source);
	}
	alGetError();//Clear the error code	
	alSourcei(source, AL_BUFFER, buffer);//Attach to sound data
	if((lastErrorCode_ = alGetError()) == AL_NO_ERROR) {
		_sources[soundSource._sourceIndex].attachedBufferId = buffer;
		//_sourceBufferAttachments[soundSource._sourceIndex] = buffer;//Keep track of which
		soundSource._soundId = soundId;
		return true;
	} else {
		return false;
	}	
}	

/**
 * Get a sound source for the specified sound in the specified source group
 */
-(CDSoundSource *) soundSourceForSound:(int) soundId sourceGroupId:(int) sourceGroupId 
{
	if (!functioning_) {
		return null;
	}	
	//Check if a source is available
	var sourceIndex :Int = this._getSourceIndexForSourceGroup ( sourceGroupId );
	if (sourceIndex != CD_NO_SOURCE) { 
		var result :CDSoundSource = new CDSoundSource().init:_sources[sourceIndex].sourceId sourceIndex ( sourceIndex, this );
		this._lockSource ( sourceIndex, true );
		//Try to attach to the buffer
		if (this._soundSourceAttachToBuffer:result soundId:soundId]) {
			//Set to a known state
			result.pitch = 1.0;
			result.pan = 0.0;
			result.gain = 1.0;
			result.looping = false;
			return result.autorelease();
		} else {
			//Release the sound source we just created, this will also unlock the source
			result.release();
			return null;
		}	
	} else {
		//No available source within that source group
		return null;
	}
}	

public function _soundSourcePreRelease:(CDSoundSource *) soundSource {
	trace("Denshion::CDSoundEngine _soundSourcePreRelease %i",soundSource._sourceIndex);
	//Unlock the sound source's source
	this._lockSource:soundSource._sourceIndex.lock ( false );
}	

/**
 * Stop all sounds playing within a source group
 */
public function stopSourceGroup:(int) sourceGroupId {
	
	if (!functioning_ || sourceGroupId >= _sourceGroupTotal || sourceGroupId < 0) {
		return;
	}	
	var sourceCount :Int = _sourceGroups[sourceGroupId].totalSources;
	for (int i=0; i < sourceCount; i++) {
		var sourceIndex :Int = _sourceGroups[sourceGroupId].sourceStatuses[i] >> 1;
		alSourceStop(_sources[sourceIndex].sourceId);
	}
	alGetError();//Clear error in case we stopped any sounds that couldn't be stopped
}	

/**
 * Stop a sound playing.
 * @param sourceId an OpenAL source identifier i.e. the return value of playSound
 */
public function stopSound:(ALuint) sourceId {
	if (!functioning_) {
		return;
	}	
	alSourceStop(sourceId);
	alGetError();//Clear error in case we stopped any sounds that couldn't be stopped
}

public function stopAllSounds {
	for (int i=0; i < sourceTotal_; i++) {
		alSourceStop(_sources[i].sourceId);
	}	
	alGetError();//Clear error in case we stopped any sounds that couldn't be stopped
}	

/**
 * Set a source group as non interruptible.  Default is that source groups are interruptible.
 * Non interruptible means that if a request to play a sound is made for a source group and there are
 * no free sources available then the play request will be ignored and CD_NO_SOURCE will be returned.
 */
public function setSourceGroupNonInterruptible ( sourceGroupId:Int,  isNonInterruptible:Bool) :Void
	//Ensure source group id is valid to prevent memory corruption
	if (sourceGroupId < 0 || sourceGroupId >= _sourceGroupTotal) {
		CDLOG("Denshion::CDSoundEngine setSourceGroupNonInterruptible invalid source group id %i",sourceGroupId);
		return;
	}	
	
	if (isNonInterruptible) {
		_sourceGroups[sourceGroupId].nonInterruptible = true;
	} else {
		_sourceGroups[sourceGroupId].nonInterruptible = false;
	}	
}

/**
 * Set the mute property for a source group. If mute is turned on any sounds in that source group
 * will be stopped and further sounds in that source group will play. However, turning mute off
 * will not restart any sounds that were playing when mute was turned on. Also the mute setting 
 * for the sound engine must be taken into account. If the sound engine is mute no sounds will play
 * no matter what the source group mute setting is.
 */
public function setSourceGroupEnabled ( sourceGroupId:Int, enabled:Bool) :Void
	//Ensure source group id is valid to prevent memory corruption
	if (sourceGroupId < 0 || sourceGroupId >= _sourceGroupTotal) {
		CDLOG("Denshion::CDSoundEngine setSourceGroupEnabled invalid source group id %i",sourceGroupId);
		return;
	}	
	
	if (enabled) {
		_sourceGroups[sourceGroupId].enabled = true;
		this.stopSourceGroup ( sourceGroupId );
	} else {
		_sourceGroups[sourceGroupId].enabled = false;	
	}	
}

/**
 * Return the mute property for the source group identified by sourceGroupId
 */
- (Bool) sourceGroupEnabled:(int) sourceGroupId {
	return _sourceGroups[sourceGroupId].enabled;
}

-(ALCcontext *) openALContext {
	return context;
}	

public function _dumpSourceGroupsInfo {
#if CD_DEBUG	
	trace("-------------- source Group Info --------------");
	for (int i=0; i < _sourceGroupTotal; i++) {
		trace("Group: %i start:%i total:%i",i,_sourceGroups[i].startIndex, _sourceGroups[i].totalSources);
		trace("----- mute:%i nonInterruptible:%i",_sourceGroups[i].enabled, _sourceGroups[i].nonInterruptible);
		trace("----- Source statuses ----");
		for (int j=0; j < _sourceGroups[i].totalSources; j++) {
			trace("Source status:%i index=%i locked=%i",j,_sourceGroups[i].sourceStatuses[j] >> 1, _sourceGroups[i].sourceStatuses[j] & 1);
		}	
	}	
#end	
}	

}

///////////////////////////////////////////////////////////////////////////////////////
class CDSoundSource

public var lastError (get_lastError, set_lastError) :;

//Macro for handling the al error code
#define CDSOUNDSOURCE_UPDATE_LAST_ERROR (lastError = alGetError())
#define CDSOUNDSOURCE_ERROR_HANDLER ( CDSOUNDSOURCE_UPDATE_LAST_ERROR == AL_NO_ERROR)

-(id)init:(ALuint) theSourceId sourceIndex:(int) index soundEngine:(CDSoundEngine*) engine {
	super.init();
		_sourceId = theSourceId;
		_engine = engine;
		_sourceIndex = index;
		enabled_ = true;
		mute_ = false;
		_preMuteGain = this.gain;
	} 
	return this;
}

public function release ()
{
	trace("Denshion::CDSoundSource releaseated "+_sourceIndex);

	//Notify sound engine we are about to release
	[_engine._soundSourcePreRelease ( this );
	super.release();
}	

public function setPitch:(Float) newPitchValue {
	alSourcef(_sourceId, AL_PITCH, newPitchValue);
	CDSOUNDSOURCE_UPDATE_LAST_ERROR;
}	

public function setGain:(Float) newGainValue {
	if (!mute_) {
		alSourcef(_sourceId, AL_GAIN, newGainValue);	
	} else {
		_preMuteGain = newGainValue;
	}	
	CDSOUNDSOURCE_UPDATE_LAST_ERROR;
}

public function setPan:(Float) newPanValue {
	var sourcePosAL[] :Float = {newPanValue, 0.0, 0.0};//Set position - just using left and right panning
	alSourcefv(_sourceId, AL_POSITION, sourcePosAL);
	CDSOUNDSOURCE_UPDATE_LAST_ERROR;

}

public function setLooping:(Bool) newLoopingValue {
	alSourcei(_sourceId, AL_LOOPING, newLoopingValue);
	CDSOUNDSOURCE_UPDATE_LAST_ERROR;

}

public function isPlaying () :Bool {
	var state :ALint;
	alGetSourcei(_sourceId, AL_SOURCE_STATE, &state);
	CDSOUNDSOURCE_UPDATE_LAST_ERROR;
	return (state == AL_PLAYING);
}	

public function pitch () :Float {
	var pitchVal :ALFloat;
	alGetSourcef(_sourceId, AL_PITCH, &pitchVal);
	CDSOUNDSOURCE_UPDATE_LAST_ERROR;
	return pitchVal;
}

public function pan () :Float {
	ALFloat sourcePosAL[] = {0.0,0.0,0.0};
	alGetSourcefv(_sourceId, AL_POSITION, sourcePosAL);
	CDSOUNDSOURCE_UPDATE_LAST_ERROR;
	return sourcePosAL[0();
}

public function gain () :Float {
	if (!mute_) {
		var val :ALFloat;
		alGetSourcef(_sourceId, AL_GAIN, &val);
		CDSOUNDSOURCE_UPDATE_LAST_ERROR;
		return val;
	} else {
		return _preMuteGain;
	}	
}	

public function looping () :Bool {
	var val :ALFloat;
	alGetSourcef(_sourceId, AL_LOOPING, &val);
	CDSOUNDSOURCE_UPDATE_LAST_ERROR;
	return val;
}

-(Bool) stop {
	alSourceStop(_sourceId);
	return CDSOUNDSOURCE_ERROR_HANDLER;
}	

-(Bool) play {
	if (enabled_) {
		alSourcePlay(_sourceId);
		CDSOUNDSOURCE_UPDATE_LAST_ERROR;
		if (lastError != AL_NO_ERROR) {
			if (alcGetCurrentContext() == null) {
				trace("Denshion::CDSoundSource - posting bad OpenAL context message");
				[NSNotificationCenter.defaultCenter] postNotificationName ( kCDN_BadAlContext, null );
			}	
			return false;
		} else {
			return true;
		}	
	} else {
		return false;
	}
}	

-(Bool) pause {
	alSourcePause(_sourceId);
	return CDSOUNDSOURCE_ERROR_HANDLER;
}

-(Bool) rewind {
	alSourceRewind(_sourceId);
	return CDSOUNDSOURCE_ERROR_HANDLER;
}

public function setSoundId:(int) soundId {
	_engine._soundSourceAttachToBuffer ( this, soundId );
}

-(int) soundId {
	return _soundId;
}	

-(Float) durationInSeconds {
	return [_engine.bufferDurationInSeconds ( _soundId );
}	

// CDSoundSource AudioInterrupt protocol
public function mute () :Bool {
	return mute_;
}	

/**
 * Setting mute silences all sounds but playing sounds continue to advance playback
 */
public function setMute:(Bool) newMuteValue {
	
	if (newMuteValue == mute_) {
		return;
	}
	
	if (newMuteValue) {
		//Remember what the gain was
		_preMuteGain = this.gain;
		this.gain = 0.0;
		mute_ = newMuteValue;//Make sure this is done after setting the gain property as the setter behaves differently depending on mute value
	} else {
		//Restore gain to what it was before being muted
		mute_ = newMuteValue;
		this.gain = _preMuteGain;
	}	
}

public function enabled () :Bool {
	return enabled_;
}

public function setEnabled ( enabledValue:Bool )
{
	if (enabled_ == enabledValue) {
		return;
	}	
	enabled_ = enabledValue;
	if (enabled_ == false) {
		this.stop();
	}	
}	

}

////////////////////////////////////////////////////////////////////////////
// -
// CDAudioInterruptTargetGroup

class CDAudioInterruptTargetGroup

-(id) init {
	super.init();
		children_ = new Array<>().initWithCapacity:32();
		enabled_ = true;
		mute_ = false;
	}
	return this;
}	

public function addAudioInterruptTarget:(NSObject<CDAudioInterruptProtocol>*) interruptibleTarget {
	//Synchronize child with group settings;
	[interruptibleTarget.setMute ( mute_ );
	[interruptibleTarget.setEnabled ( enabled_ );
	[children_.addObject ( interruptibleTarget );
}	

public function removeAudioInterruptTarget:(NSObject<CDAudioInterruptProtocol>*) interruptibleTarget {
	[children_.removeObjectIdenticalTo ( interruptibleTarget );
}	

public function mute () :Bool {
	return mute_;
}	

/**
 * Setting mute silences all sounds but playing sounds continue to advance playback
 */
public function setMute:(Bool) newMuteValue {
	
	if (newMuteValue == mute_) {
		return;
	}
	
	for (NSObject<CDAudioInterruptProtocol>* target in children_) {
		[target.setMute ( newMuteValue );
	}	
}

public function enabled () :Bool {
	return enabled_;
}

public function setEnabled ( enabledValue:Bool )
{
	if (enabledValue == enabled_) {
		return;
	}
	
	for (NSObject<CDAudioInterruptProtocol>* target in children_) {
		[target.setEnabled ( enabledValue );
	}	
}	

}



////////////////////////////////////////////////////////////////////////////

// -
// CDAsynchBufferLoader

class CDAsynchBufferLoader

-(id) init:(NSArray *)loadRequests soundEngine:(CDSoundEngine *) theSoundEngine {
	super.init();
		_loadRequests = loadRequests;
		_loadRequests.retain();
		_soundEngine = theSoundEngine;
		_soundEngine.retain();
	} 
	return this;
}	

public function main {
	trace("Denshion::CDAsynchBufferLoader - loading buffers");
	super.main();
	_soundEngine.asynchLoadProgress = 0.0;

	if (_loadRequests.length > 0) {
		var increment :Float = 1.0 / _loadRequests.count();
		//Iterate over load request and load
		for (CDBufferLoadRequest *loadRequest in _loadRequests) {
			_soundEngine.loadBuffer:loadRequest.soundId filePath:loadRequest.filePath();
			_soundEngine.asynchLoadProgress += increment;
		}	
	}	
	
	//Completed
	_soundEngine.asynchLoadProgress = 1.0;
	[NSNotificationCenter.defaultCenter] postNotificationName ( kCDN_AsynchLoadComplete, null );
	
}	

public function release {
	_loadRequests.release();
	_soundEngine.release();
	super.release();
}	

}


///////////////////////////////////////////////////////////////////////////////////////
// -
// CDBufferLoadRequest

class CDBufferLoadRequest

public var filePath (get_filePath, set_filePath) :, soundId;

-(id) init:(int) theSoundId filePath:(const String *) theFilePath {
	super.init();
		soundId = theSoundId;
		filePath = theFilePath.copy();//TODO: is retain necessary or does copy set retain count
		filePath.retain();
	} 
	return this;
}

public function release {
	filePath.release();
	super.release();
}

}

///////////////////////////////////////////////////////////////////////////////////////
// -
// CDFloatInterpolator

class CDFloatInterpolator
public var start (get_start, set_start) :,end,interpolationType;

-(Float) interpolate:(Float) t {
	
	if (t < 1.0) {
		switch (interpolationType) {
			case kIT_Linear:
				//Linear interpolation
				return ((end - start) * t) + start;
				
			case kIT_SCurve:
				//Cubic s curve t^2 * (3 - 2t)
				return ((Float)(t * t * (3.0 - (2.0 * t))) * (end - start)) + start;
				
			case kIT_Exponential:	
				//Formulas taken from EaseAction
				if (end > start) {
					//Fade in
					var logDelta :Float = (t==0) ? 0 : powf(2, 10 * (t/1 - 1)) - 1 * 0.001;
					return ((end - start) * logDelta) + start;
				} else {
					//Fade Out
					var logDelta :Float = (-powf(2, -10 * t/1) + 1);
					return ((end - start) * logDelta) + start;
				}
			default:
				return 0.0;
		}
	} else {
		return end;
	} 
}

-(id) init:(tCDInterpolationType) type startVal:(Float) startVal endVal:(Float) endVal {
	super.init();
		start = startVal;
		end = endVal;
		interpolationType = type;
	} 
	return this;
}

}

///////////////////////////////////////////////////////////////////////////////////////
// -
// CDPropertyModifier

class CDPropertyModifier

public var stopTargetWhenComplete (get_stopTargetWhenComplete, set_stopTargetWhenComplete) :;

-(id) init:(id) theTarget interpolationType:(tCDInterpolationType) type startVal:(Float) startVal endVal:(Float) endVal {
	super.init();
		if (target) {
			//Release the previous target if there is one
			target.release();
		}	
		target = theTarget;
#if CD_DEBUG
		//Check target is of the required type
		if (!theTarget.isMemberOfClass:this._allowableType]] ) {
			CDLOG("Denshion::CDPropertyModifier target is not of type "+this._allowableType]);
			if (theTarget.isKindOfClass:CDSoundEngine.class]], "CDPropertyModifier target not of required type");
		}
#end		
		target.retain();
		startValue = startVal;
		endValue = endVal;
		if (interpolator) {
			//Release previous interpolator if there is one
			interpolator.release();
		}	
		interpolator = new CDFloatInterpolator().init:type startVal ( startVal, endVal );
		stopTargetWhenComplete = false;
	}
	return this;
}	

public function release {
	trace("Denshion::CDPropertyModifier releaseated "+this);
	target.release();
	interpolator.release();
	super.release();
}	

public function modify:(Float) t {
	if (t < 1.0) {
		this._setTargetProperty:Interpolator.interpolate ( t )();
	} else {
		//At the end
		this._setTargetProperty ( endValue );
		if (stopTargetWhenComplete) {
			this._stopTarget();
		}	
	}	
}	

-(Float) startValue {
	return startValue;
}

public function setStartValue:(Float) startVal
{
	startValue = startVal;
	interpolator.start = startVal;
}	

-(Float) endValue {
	return startValue;
}

public function setEndValue:(Float) endVal
{
	endValue = endVal;
	interpolator.end = endVal;
}	

-(tCDInterpolationType) interpolationType {
	return interpolator.interpolationType;
}

public function setInterpolationType:(tCDInterpolationType) interpolationType {
	interpolator.interpolationType = interpolationType;
}	

public function _setTargetProperty:(Float) newVal {

}	

-(Float) _getTargetProperty {
	return 0.0;
}	

public function _stopTarget {

}	

-(Class) _allowableType {
	return NSObject.class();
}	
}

///////////////////////////////////////////////////////////////////////////////////////
// -
// CDSoundSourceFader

class CDSoundSourceFader

public function _setTargetProperty:(Float) newVal {
	((CDSoundSource*)target).gain = newVal;
}	

-(Float) _getTargetProperty {
	return ((CDSoundSource*)target).gain;
}

public function _stopTarget {
	[((CDSoundSource*)target) stop();
}

-(Class) _allowableType {
	return CDSoundSource.class();
}	

}

///////////////////////////////////////////////////////////////////////////////////////
// -
// CDSoundSourcePanner

class CDSoundSourcePanner

public function _setTargetProperty:(Float) newVal {
	((CDSoundSource*)target).pan = newVal;
}	

-(Float) _getTargetProperty {
	return ((CDSoundSource*)target).pan;
}

public function _stopTarget {
	[((CDSoundSource*)target) stop();
}

-(Class) _allowableType {
	return CDSoundSource.class();
}	

}

///////////////////////////////////////////////////////////////////////////////////////
// -
// CDSoundSourcePitchBender

class CDSoundSourcePitchBender

public function _setTargetProperty:(Float) newVal {
	((CDSoundSource*)target).pitch = newVal;
}	

-(Float) _getTargetProperty {
	return ((CDSoundSource*)target).pitch;
}

public function _stopTarget {
	[((CDSoundSource*)target) stop();
}

-(Class) _allowableType {
	return CDSoundSource.class();
}	

}

///////////////////////////////////////////////////////////////////////////////////////
// -
// CDSoundEngineFader

class CDSoundEngineFader

public function _setTargetProperty:(Float) newVal {
	((CDSoundEngine*)target).masterGain = newVal;
}	

-(Float) _getTargetProperty {
	return ((CDSoundEngine*)target).masterGain;
}

public function _stopTarget {
	[((CDSoundEngine*)target) stopAllSounds();
}

-(Class) _allowableType {
	return CDSoundEngine.class();
}	

}


