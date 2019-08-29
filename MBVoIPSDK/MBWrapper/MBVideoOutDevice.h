#ifndef MBVideoOutDevice_h
#define MBVideoOutDevice_h

using namespace std;

#include <iostream>
#include <exception>

#import <MBVoIP/MBVoIP.h>
@protocol MBMediaEngineDelegate;

class MBVideoOutDevice : public IMediaEngine_internal_videoOutDevice
{
public:
    MBVideoOutDevice(void);
    ~MBVideoOutDevice(void);
    
    // IMediaEngine_internal_videoOutDevice
    virtual MbStatus videoOutDevCreate(int id);
    virtual MbStatus videoOutDevOpen(IMediaEngine_VideoParams* params,void* pReceiver);
    virtual MbStatus videoOutDevStart(IMediaEngine_VideoParams* params);
    virtual MbStatus videoOutDevStop(IMediaEngine_VideoParams* params);
    virtual MbStatus videoOutDevClose(IMediaEngine_VideoParams* params);
    virtual MbStatus videoOutDevDisplay(IMediaEngine_VideoParams* params, char* pData, int iLen,MBVideoFrame* frame);
    virtual MbStatus videoOutDevReceivedCodecData(IMediaEngine_VideoParams* params, char* pData, int iLen);
    virtual MbStatus videoOutDevTerminate();
    // objective c
    id <MBMediaEngineDelegate> delegate;
private:
    IMediaEngine_VideoParams *m_pVideoParams;
};

#endif
