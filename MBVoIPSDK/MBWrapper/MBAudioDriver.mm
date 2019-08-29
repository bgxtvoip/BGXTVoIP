#include "MBAudioDriver.h"

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <iostream>
#import <cstdlib>
#import <ctime>
#import <vector>

AudioComponentInstance audioUnit;
AudioBufferList *bufferList;
int g_index;

using namespace std;

#define kOutputBus 0
#define kInputBus 1
#define SAMPLE_RATE 44100
IHostParticipant*   g_waveIn = NULL;
IHostParticipant*   g_waveOut = NULL;
static bool bRemoteInit = false;
static bool bRemoteStart = false;
vector<int> _pcm;
int _index;
char *sampleBuffer;

void generateTone(
                  vector<int>& pcm,
                  int freq,
                  double lengthMS,
                  int sampleRate,
                  double riseTimeMS,
                  double gain)
{
    int numSamples = ((double) sampleRate) * lengthMS / 1000.;
    int riseTimeSamples = ((double) sampleRate) * riseTimeMS / 1000.;
    
    if(gain > 1.)
        gain = 1.;
    if(gain < 0.)
        gain = 0.;
    
    pcm.resize(numSamples);
    
    for(int i = 0; i < numSamples; ++i)
    {
        double value = sin(2. * M_PI * freq * i / sampleRate);
        if(i < riseTimeSamples)
            value *= sin(i * M_PI / (2.0 * riseTimeSamples));
        if(i > numSamples - riseTimeSamples - 1)
            value *= sin(2. * M_PI * (i - (numSamples - riseTimeSamples) + riseTimeSamples)/ (4. * riseTimeSamples));
        
        pcm[i] = (int) (value * 32500.0 * gain);
        pcm[i] += (pcm[i]<<16);
    }
    
}


void checkStatus(OSStatus s)
{
}

#define TARGET_IOS_AUDIO_SIZE 512
static char recordAudioData[TARGET_IOS_AUDIO_SIZE];
static int recordAudioPos;
static char playAudioData[TARGET_IOS_AUDIO_SIZE];
static int playAudioPos;
static char* pPlayDataBuff;
static int iPlaySize;

static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    
    // TODO: Use inRefCon to access our interface object to do stuff
    // Then, use inNumberFrames to figure out how much data is available, and make
    // that much space available in buffers in an AudioBufferList.
    
    // <- Fill this up with buffers (you will want to malloc it, as it's a dynamic-length list)
    
    // Then:
    // Obtain recorded samples
    AudioBufferList list;
    
    // redundant
    list.mNumberBuffers = 1;
    list.mBuffers[0].mData = sampleBuffer;
    list.mBuffers[0].mDataByteSize = 2 * inNumberFrames;
    list.mBuffers[0].mNumberChannels = 1;
	
    ioData = &list;
	
    AudioUnitRender(audioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
    
	// the sample buffer now contains samples you can work with
    
	
    
    
	//int totalNumberOfSamples = inNumberFrames;//_pcm.size();
	for(UInt32 i = 0; i < ioData->mNumberBuffers; ++i)
	{
        int size = ioData->mBuffers[i].mDataByteSize;
        if(recordAudioPos < TARGET_IOS_AUDIO_SIZE)
        {
            memcpy(recordAudioData+recordAudioPos, ioData->mBuffers[i].mData, size);
            recordAudioPos += size;
            if(recordAudioPos < TARGET_IOS_AUDIO_SIZE) break;
        }
        if(g_waveIn != NULL)
        {
            g_waveIn->TransferIntoRecordAudio((char*)recordAudioData, recordAudioPos);
            recordAudioPos = 0;
            //->sendCaptureAudioData((char*)ioData->mBuffers[i].mData, size, totalNumberOfSamples);
			//NSLog(@"record size=%d,total=%d,leftNum=%d.",size,totalNumberOfSamples,leftNum);
		}
	}
	
    /*   OSStatus status;
     //cout << "xxxx";
     g_index = inNumberFrames;
     //inTimeStamp->mSampleTime = g_index;
     status = AudioUnitRender(audioUnit,
     ioActionFlags,
     inTimeStamp,
     inBusNumber,
     inNumberFrames,
     bufferList);
     checkStatus(status); */
    
    // Now, we have the samples we just read sitting in buffers in bufferList
    //DoStuffWithTheRecordedAudio(bufferList);
    return noErr;
}

static OSStatus playbackCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData) {
    // Notes: ioData contains buffers (may be more than one!)
    // Fill them up as much as you can. Remember to set the size value in each buffer to match how
    // much data is in the buffer.
    // cout << "index = " << _index<<end1;
    /*    cout << "numBuffers = " << ioData->mNumberBuffers;
     int num = g_index;
     for(int i=0; i < ioData->mNumberBuffers; i++)
     {
     if(num > 0)
     {
     memcpy(ioData->mBuffers[i].mData,
     bufferList->mBuffers[i].mData, bufferList->mBuffers[i].mDataByteSize);
     }
     else {
     memset(ioData->mBuffers[i].mData,0, ioData->mBuffers[i].mDataByteSize);
     }
     
     }
     g_index = 0; */
	//cout<<"index = "<<_index<<endl;
	//cout<<"numBuffers = "<<ioData->mNumberBuffers<<endl;
    
    //int totalNumberOfSamples = inNumberFrames;//_pcm.size();
	for(UInt32 i = 0; i < ioData->mNumberBuffers; ++i)
	{
		if(g_waveOut != NULL)
		{
			int size = ioData->mBuffers[i].mDataByteSize;
            if(playAudioPos == 0)
            {
            pPlayDataBuff = g_waveOut->GetPlayAudioDataFromEng(NULL, iPlaySize);
            }
            else
            {
                pPlayDataBuff = NULL;
            }
            
            if(pPlayDataBuff != NULL)
            {
                memcpy(playAudioData, pPlayDataBuff, iPlaySize);
            }

            memcpy(ioData->mBuffers[i].mData,playAudioData+playAudioPos,size);
            playAudioPos += size;
            if(playAudioPos >= iPlaySize) playAudioPos = 0;

            //luca	g_pVoip->sendPlayAudioData( (char*)ioData->mBuffers[i].mData, size, totalNumberOfSamples);
			//NSLog(@"play size=%d,total=%d,playValue=%d.",size,totalNumberOfSamples,playValue);
            
		}
        // memcpy(ioData->mBuffers[i].mData, &_pcm[0], ioData->mBuffers[i].mDataByteSize) ;
        
        /*			int samplesLeft = totalNumberOfSamples - _index;
         int numSamples = ioData->mBuffers[i].mDataByteSize / 4;
         if(samplesLeft > 0)
         {
         if(samplesLeft < numSamples)
         {
         memcpy(ioData->mBuffers[i].mData, &_pcm[_index], samplesLeft * 4);
         _index += samplesLeft;
         memset((char*) ioData->mBuffers[i].mData + samplesLeft * 4, 0, (numSamples - samplesLeft) * 4) ;
         }
         else
         {
         memcpy(ioData->mBuffers[i].mData, &_pcm[_index], numSamples * 4) ;
         _index += numSamples;
         }
         }
         else
         memset(ioData->mBuffers[i].mData, 0, ioData->mBuffers[i].mDataByteSize); */
	}
	return noErr;
}


MBAudioDriver::MBAudioDriver(void)
                :m_pMediaEngine(NULL)
                ,m_pMediaEngineSetting(NULL)
{
    m_pMediaEngineSetting = CMediaEngineSetting::getInstance();
    iSampleRate = 8000.0;
    waveIn = NULL;
    waveOut = NULL;
    iWaveInOpen = 0;
    iWaveInStarted = 0;
    iWaveOutOpen = 0;
    iWaveOutStarted = 0;
    bInitSpeakerOn = false;
}

MBAudioDriver::~MBAudioDriver(void)
{

}

/*
 * ####### IMediaEngine_internal_audioInDevice
 */
int MBAudioDriver::audioDevInOpen(IMediaEngine_ChannelParams* param,int sampleRate, int codecFrameLen, void* pProcess)
{
    printf(">>>>audioDevInOpen>>>, samplerate=%d.\n",sampleRate);
    MbStatus status = MB_SUCCESS_OK;
    waveIn = (IHostParticipant*)pProcess;
    g_waveIn = waveIn;
    iSampleRate = (float)sampleRate;
    iWaveInOpen ++;
    
    memset(recordAudioData, 0x00, sizeof(recordAudioData));
    recordAudioPos = 0;
    
    Init_RemoteIO();
    return status;
};
int MBAudioDriver::audioDevInStart(IMediaEngine_ChannelParams* param)
{
    printf(">>>>audioDevInStart>>>\n");
    MbStatus status = MB_SUCCESS_OK;
    iWaveInStarted ++;
    Start_RemoteIO();
    return status;
};
int MBAudioDriver::audioDevInStop(IMediaEngine_ChannelParams* param)
{
    printf(">>>>audioDevInStop>>>\n");
    MbStatus status = MB_SUCCESS_OK;
    iWaveInStarted --;
    Stop_RemoteIO();
    return status;
};
int MBAudioDriver::audioDevInClose(IMediaEngine_ChannelParams* param)
{
    printf(">>>>audioDevInClose>>>\n");
    MbStatus status = MB_SUCCESS_OK;
    iWaveInOpen --;
    Release_Remote();
    return status;
};

/*
 * ####### IMediaEngine_internal_audioOutDevice
 */
int MBAudioDriver::audioDevOutOpen(IMediaEngine_ChannelParams* param,int sampleRate,int sampleLen,void* pProcess)
{
    printf(">>>>audioDevOutOpen>>>sampleRate=%d.\n",sampleRate);
    MbStatus status = MB_SUCCESS_OK;
    waveOut = (IHostParticipant*)pProcess;
    g_waveOut = waveOut;
    iWaveOutOpen ++;
    
    memset(playAudioData, 0x00, sizeof(playAudioData));
    playAudioPos = 0;
    pPlayDataBuff = NULL;
    iPlaySize = 0;

    Init_RemoteIO();
    return status;
};
int MBAudioDriver::audioDevOutStart(IMediaEngine_ChannelParams* param)
{
    printf(">>>>audioDevOutStart>>>\n");
    MbStatus status = MB_SUCCESS_OK;
    iWaveOutStarted ++;
    Start_RemoteIO();
    return status;
};
int MBAudioDriver::audioDevOutStop(IMediaEngine_ChannelParams* param)
{
    printf(">>>>audioDevOutStop>>>\n");
    MbStatus status = MB_SUCCESS_OK;
    iWaveOutStarted --;
    Stop_RemoteIO();	
    return status;
};
int MBAudioDriver::audioDevOutClose(IMediaEngine_ChannelParams* param)
{
    printf(">>>>audioDevOutClose>>>\n");
    MbStatus status = MB_SUCCESS_OK;
    iWaveOutOpen --;
    Release_Remote();
    return status;
};

void MBAudioDriver::Start_RemoteIO()
{
    if(bRemoteStart)
    {
        printf("Start_RemoteIO had started, exit\n");
        return;
    }
    printf("Start_RemoteIO run start.\n");
    bRemoteStart = true;
	OSStatus status = AudioOutputUnitStart(audioUnit);
	checkStatus(status);

#warning working;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        AVAudioSessionRouteDescription *currentRouteDescription = [[AVAudioSession sharedInstance] currentRoute];
        AVAudioSessionPortDescription *currentOutputPortDescription = currentRouteDescription.outputs.firstObject;
        BOOL isSpeaker = [currentOutputPortDescription.portType isEqualToString:AVAudioSessionPortBuiltInSpeaker];
        if (isSpeaker == NO) {
            if ([currentOutputPortDescription.portType isEqualToString:AVAudioSessionPortBuiltInReceiver]) {
                AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                NSError *error = nil;
                [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
            }
        }
    }
#warning working;
    checkStatus(status);
}

void MBAudioDriver::Stop_RemoteIO()
{
    if(!bRemoteStart)
    {
        printf("Stop_RemoteIO had stop, exit\n");
        return;
    }
    printf("Stop_RemoteIO run stop\n");
    bRemoteStart = false;
	OSStatus status = AudioOutputUnitStop(audioUnit);
	checkStatus(status);
}

void MBAudioDriver::Release_Remote()
{
    if(bRemoteStart)
    {
        Stop_RemoteIO();
    }
    if(!bRemoteInit)
    {
        printf("Release_Remote had released, exit\n");
        return;
    }
    printf("Release_Remote run release \n");
    bRemoteInit = false;
#warning working;
//	AudioSessionSetActive(false);
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [audioSession setActive:NO error:&error];
    NSLog(@"error : %@", [error description]);
#warning working;
	AudioUnitUninitialize(audioUnit);
	AudioComponentInstanceDispose(audioUnit);
	free(sampleBuffer);
	sampleBuffer = NULL;
}

void MBAudioDriver::SetInitSpeakerMode(bool bSpeaker)
{
    NSLog(@"SetInitSpeakerMode bSpeaker=%d.",bSpeaker);
    bInitSpeakerOn = bSpeaker;
}

void MBAudioDriver::Init_RemoteIO()
{
	OSStatus status;
    if(bRemoteInit)
    {
        printf("Init_RemoteIO: had bee init, exit.\n");
        return;
    }
    printf("Init_RemoteIO: run init iSampleRate=%f.\n",iSampleRate);
	_index = 0;
    bRemoteInit = true;
	// Describe audio component
	AudioComponentDescription desc;
	desc.componentType = kAudioUnitType_Output;
	//desc.componentSubType = kAudioUnitSubType_RemoteIO;
	desc.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
	desc.componentFlags = 0;
	desc.componentFlagsMask = 0;
	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
	// Get component
	AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
	// Get audio units
	status = AudioComponentInstanceNew(inputComponent, &audioUnit);
	checkStatus(status);
    
	// Enable IO for recording
	UInt32 flag = 1;
	status = AudioUnitSetProperty(audioUnit,
	                              kAudioOutputUnitProperty_EnableIO,
	                              kAudioUnitScope_Input,
	                              kInputBus,
	                              &flag,
	                              sizeof(flag));
	checkStatus(status);
    
	
	// Enable IO for playback
	flag = 1;
	status = AudioUnitSetProperty(audioUnit,
	                              kAudioOutputUnitProperty_EnableIO,
	                              kAudioUnitScope_Output,
	                              kOutputBus,
	                              &flag,
	                              sizeof(flag));
	checkStatus(status);
    
	AudioStreamBasicDescription audioFormat;
	// Describe format
	audioFormat.mSampleRate			= iSampleRate;
	audioFormat.mFormatID			= kAudioFormatLinearPCM;
	audioFormat.mFormatFlags		= kLinearPCMFormatFlagIsSignedInteger |
    kLinearPCMFormatFlagIsPacked;
	audioFormat.mFramesPerPacket	= 1;
	audioFormat.mChannelsPerFrame	= 1;
	audioFormat.mBitsPerChannel		= 16;
	audioFormat.mBytesPerPacket		= 2;
	audioFormat.mBytesPerFrame		= 2;
	audioFormat.mReserved			= 0;
    
	// Apply format
	status = AudioUnitSetProperty(audioUnit,
	                              kAudioUnitProperty_StreamFormat,
	                              kAudioUnitScope_Output,
	                              kInputBus,
	                              &audioFormat,
	                              sizeof(audioFormat));
	checkStatus(status);
	
	status = AudioUnitSetProperty(audioUnit,
	                              kAudioUnitProperty_StreamFormat,
	                              kAudioUnitScope_Input,
	                              kOutputBus,
	                              &audioFormat,
	                              sizeof(audioFormat));
	checkStatus(status);
    
    
	// Set input callback
	AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = recordingCallback;
	callbackStruct.inputProcRefCon = this;
	status = AudioUnitSetProperty(audioUnit,
	                              kAudioOutputUnitProperty_SetInputCallback,
	                              kAudioUnitScope_Global,
	                              kInputBus,
	                              &callbackStruct,
	                              sizeof(callbackStruct));
	checkStatus(status);
    
	// Set output callback
	callbackStruct.inputProc = playbackCallback;
	callbackStruct.inputProcRefCon = this;
	status = AudioUnitSetProperty(audioUnit,
	                              kAudioUnitProperty_SetRenderCallback,
	                              kAudioUnitScope_Global,
	                              kOutputBus,
	                              &callbackStruct,
	                              sizeof(callbackStruct));
	checkStatus(status);
	
	// Disable buffer allocation for the recorder (optional - do this if we want to pass in our own)
    /*	flag = 0;
     status = AudioUnitSetProperty(audioUnit,
     kAudioUnitProperty_ShouldAllocateBuffer,
     kAudioUnitScope_Output,
     kInputBus,
     &flag,
     sizeof(flag));   */
	
#warning working;
//	AudioSessionInitialize(NULL,NULL,NULL,NULL);
//	AudioSessionSetActive(true);
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [audioSession setActive:YES error:&error];
    NSLog(@"error : %@", [error description]);
//	UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
//	status = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    NSLog(@"error : %@", [error description]);
	
//	Float64 float64 = (Float64)iSampleRate;
//	UInt32 pSize = sizeof(float64);
	
//	AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareSampleRate, pSize, &float64);
//	AudioSessionSetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, pSize, &float64);
    [audioSession setPreferredSampleRate:(double)iSampleRate error:&error];
    NSLog(@"error : %@", [error description]);
	
	
	float aBufferLength = 0.04; // In seconds
	if(iSampleRate == 16000.0)
		aBufferLength = 0.02;
//	UInt32 xSize = sizeof(aBufferLength);
//    AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration,
//                            xSize, &aBufferLength);
//	
//	AudioSessionSetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration,
//							xSize, &aBufferLength);
    [audioSession setPreferredIOBufferDuration:aBufferLength error:&error];
    NSLog(@"error : %@", [error description]);
	
	sampleBuffer = (char*)malloc(1024 * 4);
    /*	bufferList = (AudioBufferList*)malloc(sizeof(AudioBufferList));
     bufferList->mNumberBuffers = 10;
     for(int i=0; i<bufferList->mNumberBuffers; i++)
     {
     bufferList->mBuffers[i].mNumberChannels = 1;
     bufferList->mBuffers[i].mDataByteSize = 1024 * 2 * 2;
     bufferList->mBuffers[i].mData= malloc(bufferList->mBuffers[i].mDataByteSize);
     memset(bufferList->mBuffers[i].mData,0,bufferList->mBuffers[i].mDataByteSize);
     }  */
    
    UInt32 turnOff = 0;
    AudioUnitSetProperty(audioUnit, kAUVoiceIOProperty_VoiceProcessingEnableAGC, kAudioUnitScope_Global, kInputBus, &turnOff, sizeof(turnOff));
    AudioUnitSetProperty(audioUnit, kAUVoiceIOProperty_VoiceProcessingEnableAGC, kAudioUnitScope_Global, kOutputBus, &turnOff, sizeof(turnOff));
    
    g_index = 0;
    
    // Initialise
    status = AudioUnitInitialize(audioUnit);
    checkStatus(status);
}

