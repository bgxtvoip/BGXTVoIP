#ifndef MBVideoInDevice_h
#define MBVideoInDevice_h

using namespace std;

#include <iostream>
#include <exception>

#import <MBVoIP/MBVoIP.h>
@protocol MBMediaEngineDelegate;

class MBVideoInDevice : public IMediaEngine_internal_videoInDevice
{
public:
    MBVideoInDevice(void);
    ~MBVideoInDevice(void);
    
    // IMediaEngine_internal_videoInDevice
    virtual MbStatus videoInDevCreate(int id);
    virtual MbStatus videoInDevOpen(IMediaEngine_VideoParams* params,void* pReceiver);
    virtual MbStatus videoInDevStart(IMediaEngine_VideoParams* params);
    virtual MbStatus videoInDevStop(IMediaEngine_VideoParams* params);
    virtual MbStatus videoInDevClose(IMediaEngine_VideoParams* params);
    virtual MbStatus videoInDevTerminate(IMediaEngine_VideoParams* params);
    virtual MbStatus videoInDevSwitch(int id);
    virtual MbStatus videoInDevRestart(IMediaEngine_VideoParams* params,void* pReceiver);
    virtual MbStatus videoInDevGetState(MBVideoDevOperationParams* params);
    // functions
    MbStatus SendRawVideoData(unsigned char *pData, int iWidth, int iHeight);
    MbStatus SendRawVideoData(unsigned char *pData, int iWidth, int iHeight, bool bIsForcelyLandscapeMode);
    // objective c
    id <MBMediaEngineDelegate> delegate;
private:
    IMediaEngine_VideoParams *m_pVideoParams;
    IMediaEngine_internal_VideoReceiver *m_pVideoReceiver;
    MBVideoFrame m_videoFrame;
    MBVideoFrameControl m_videoFrameControl;
    unsigned char *m_pRawVideoDataBuffer;
    unsigned int m_rawVideoDataBufferLength;
};

#endif
