#ifndef _MBAudioDriver_H
#define _MBAudioDriver_H
#import <MBVoIP/MBVoIP.h>
#import <AVFoundation/AVFoundation.h>

class MBAudioDriver:public IMediaEngine_internal_audioInDevice, public IMediaEngine_internal_audioOutDevice
{
    
public:
    MBAudioDriver(void);
    ~MBAudioDriver(void);
    
    /*
     * ####### IMediaEngine_internal_audioInDevice
     */
	virtual int audioDevInOpen(IMediaEngine_ChannelParams* param,int sampleRate, int codecFrameLen, void* pProcess);
	virtual int audioDevInStart(IMediaEngine_ChannelParams* param);
	virtual int audioDevInStop(IMediaEngine_ChannelParams* param);
	virtual int audioDevInClose(IMediaEngine_ChannelParams* param);
    
    /*
     * ####### IMediaEngine_internal_audioOutDevice
     */
	virtual int audioDevOutOpen(IMediaEngine_ChannelParams* param,int sampleRate,int sampleLen,void* pProcess);
	virtual int audioDevOutStart(IMediaEngine_ChannelParams* param);
	virtual int audioDevOutStop(IMediaEngine_ChannelParams* param);
	virtual int audioDevOutClose(IMediaEngine_ChannelParams* param);
    
    CMediaEngine *m_pMediaEngine;
    CMediaEngineSetting *m_pMediaEngineSetting;
    
    void Start_RemoteIO();
	void Stop_RemoteIO();
	void Release_Remote();	
	void Init_RemoteIO();
	void setSampleRate(float sample) {iSampleRate = sample;};
    void SetInitSpeakerMode(bool bSpeaker);
private:
	float iSampleRate;
    IHostParticipant* waveIn;
    IHostParticipant* waveOut;
    int iWaveInOpen;
    int iWaveInStarted;
    int iWaveOutOpen;
    int iWaveOutStarted;
    
    bool bInitSpeakerOn;
};

#endif //_MBAudioDriver_H
