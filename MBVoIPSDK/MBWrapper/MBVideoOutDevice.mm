#include "MBVideoOutDevice.h"
#include "MBMediaEngineDelegate.h"

MBVideoOutDevice::MBVideoOutDevice(void)
{
    this->m_pVideoParams = new IMediaEngine_VideoParams;
    this->m_pVideoParams->Init();
    
    this->delegate = nil;
    
    return;
}

MBVideoOutDevice::~MBVideoOutDevice(void)
{
    this->delegate = nil;
    
    if (this->m_pVideoParams) {
        delete this->m_pVideoParams;
        this->m_pVideoParams = NULL;
    }
    
    return;
}

// IMediaEngine_internal_videoOutDevice

MbStatus MBVideoOutDevice::videoOutDevCreate(int id)
{
    MbStatus status = MB_SUCCESS_OK;
    try {
        status = MB_ERROR_UNKNOWN;
        if ([[this->delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
            if ([this->delegate respondsToSelector:@selector(createVideoOutDevice:id:)]) {
                BOOL result = [this->delegate createVideoOutDevice:this id:id];
                if (result == YES) {
                    status = MB_SUCCESS_OK;
                }
            }
        }
        if (status != MB_SUCCESS_OK) {
            throw status;
        }
    } catch (int e) {
        status = e;
    } catch (exception e) {
        status = MB_ERROR_UNKNOWN;
    }
    return status;
}

MbStatus MBVideoOutDevice::videoOutDevOpen(IMediaEngine_VideoParams* params,void* pReceiver)
{
    MbStatus status = MB_SUCCESS_OK;
    try {
        if (params == NULL) {
            throw MB_ERROR_NULL_POINTER;
        }
        status = MB_ERROR_UNKNOWN;
        if ([[this->delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
            if ([this->delegate respondsToSelector:@selector(openVideoOutDevice:params:receiver:)]) {
                BOOL result = [this->delegate openVideoOutDevice:this params:params receiver:pReceiver];
                if (result == YES) {
                    status = MB_SUCCESS_OK;
                }
            }
        }
        if (status != MB_SUCCESS_OK) {
            throw status;
        }
        
        this->m_pVideoParams->Copy(params);
    } catch (int e) {
        status = e;
    } catch (exception e) {
        status = MB_ERROR_UNKNOWN;
    }
    return status;
}

MbStatus MBVideoOutDevice::videoOutDevStart(IMediaEngine_VideoParams* params)
{
    MbStatus status = MB_SUCCESS_OK;
    try {
        if (params == NULL) {
            throw MB_ERROR_NULL_POINTER;
        }
        status = MB_ERROR_UNKNOWN;
        if ([[this->delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
            if ([this->delegate respondsToSelector:@selector(startVideoOutDevice:params:)]) {
                BOOL result = [this->delegate startVideoOutDevice:this params:params];
                if (result == YES) {
                    status = MB_SUCCESS_OK;
                }
            }
        }
        if (status != MB_SUCCESS_OK) {
            throw status;
        }
        
        this->m_pVideoParams->Copy(params);
    } catch (int e) {
        status = e;
    } catch (exception e) {
        status = MB_ERROR_UNKNOWN;
    }
    return status;
}

MbStatus MBVideoOutDevice::videoOutDevStop(IMediaEngine_VideoParams* params)
{
    MbStatus status = MB_SUCCESS_OK;
    try {
        if (params == NULL) {
            throw MB_ERROR_NULL_POINTER;
        }
        if ([[this->delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
            if ([this->delegate respondsToSelector:@selector(stopVideoOutDevice:params:)]) {
                [this->delegate stopVideoOutDevice:this params:params];
            }
        }
        if (status != MB_SUCCESS_OK) {
            throw status;
        }
        
        this->m_pVideoParams->Copy(params);
    } catch (int e) {
        status = e;
    } catch (exception e) {
        status = MB_ERROR_UNKNOWN;
    }
    return status;
}

MbStatus MBVideoOutDevice::videoOutDevClose(IMediaEngine_VideoParams* params)
{
    MbStatus status = MB_SUCCESS_OK;
    try {
        if (params == NULL) {
            throw MB_ERROR_NULL_POINTER;
        }
        if ([[this->delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
            if ([this->delegate respondsToSelector:@selector(closeVideoOutDevice:params:)]) {
                [this->delegate closeVideoOutDevice:this params:params];
            }
        }
        if (status != MB_SUCCESS_OK) {
            throw status;
        }
        
        this->m_pVideoParams->Init();
    } catch (int e) {
        status = e;
    } catch (exception e) {
        status = MB_ERROR_UNKNOWN;
    }
    return status;
}

MbStatus MBVideoOutDevice::videoOutDevDisplay(IMediaEngine_VideoParams* params, char* pData, int iLen,MBVideoFrame* frame)
{
    MbStatus status = MB_SUCCESS_OK;
    try {
        if (params == NULL) {
            throw MB_ERROR_NULL_POINTER;
        }
        if ([[this->delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
            if ([this->delegate respondsToSelector:@selector(displayVideoOutDevice:params:data:length:videoFrame:)]) {
                [this->delegate displayVideoOutDevice:this params:params data:pData length:iLen videoFrame:frame];
            }
        }
        
        this->m_pVideoParams->Copy(params);
    } catch (int e) {
        status = e;
    } catch (exception e) {
        status = MB_ERROR_UNKNOWN;
    }
    return status;
}

MbStatus MBVideoOutDevice::videoOutDevReceivedCodecData(IMediaEngine_VideoParams* params, char* pData, int iLen)
{
    MbStatus status = MB_SUCCESS_OK;
    try {
        if (params == NULL) {
            throw MB_ERROR_NULL_POINTER;
        }
    } catch (int e) {
        status = e;
    } catch (exception e) {
        status = MB_ERROR_UNKNOWN;
    }
    return status;
}

MbStatus MBVideoOutDevice::videoOutDevTerminate()
{
    MbStatus status = MB_SUCCESS_OK;
    try {
        if ([[this->delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
            if ([this->delegate respondsToSelector:@selector(terminateVideoOutDevice)]) {
                [this->delegate terminateVideoOutDevice];
            }
        }
        if (status != MB_SUCCESS_OK) {
            throw status;
        }
    } catch (int e) {
        status = e;
    } catch (exception e) {
        status = MB_ERROR_UNKNOWN;
    }
    return status;
}
