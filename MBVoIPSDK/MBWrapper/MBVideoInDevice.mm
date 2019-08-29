#include "MBVideoInDevice.h"
#include "MBMediaEngineDelegate.h"
#include "MediaEngineWrapper.h"

MBVideoInDevice::MBVideoInDevice(void)
{
    this->m_pVideoParams = new IMediaEngine_VideoParams;
    this->m_pVideoParams->Init();
    this->m_pVideoReceiver = NULL;
    memset(&(this->m_videoFrame), 0x0, sizeof(MBVideoFrame));
    memset(&(this->m_videoFrameControl), 0x0, sizeof(MBVideoFrameControl));
    this->m_pRawVideoDataBuffer = NULL;
    this->m_rawVideoDataBufferLength = 0;
    
    this->delegate = nil;
    
    return;
}

MBVideoInDevice::~MBVideoInDevice(void)
{
    this->delegate = nil;
    
    if (this->m_pRawVideoDataBuffer != NULL) {
        free(this->m_pRawVideoDataBuffer);
        this->m_pRawVideoDataBuffer = NULL;
    }
    this->m_pVideoReceiver = NULL;
    if (this->m_pVideoParams) {
        delete this->m_pVideoParams;
        this->m_pVideoParams = NULL;
    }
    
    return;
}

// IMediaEngine_internal_videoInDevice

MbStatus MBVideoInDevice::videoInDevCreate(int id)
{
    MbStatus status = MB_SUCCESS_OK;
    try {
        status = MB_ERROR_UNKNOWN;
        if ([[this->delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
            if ([this->delegate respondsToSelector:@selector(createVideoInDevice:id:)]) {
                BOOL result = [this->delegate createVideoInDevice:this id:id];
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

MbStatus MBVideoInDevice::videoInDevOpen(IMediaEngine_VideoParams* params,void* pReceiver)
{
    MbStatus status = MB_SUCCESS_OK;
    try {
        if (params == NULL) {
            throw MB_ERROR_NULL_POINTER;
        }
        status = MB_ERROR_UNKNOWN;
        if ([[this->delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
            if ([this->delegate respondsToSelector:@selector(openVideoInDevice:params:receiver:)]) {
                BOOL result = [this->delegate openVideoInDevice:this params:params receiver:pReceiver];
                if (result == YES) {
                    status = MB_SUCCESS_OK;
                }
            }
        }
        if (status != MB_SUCCESS_OK) {
            throw status;
        }
        
        this->m_pVideoParams->Copy(params);
        this->m_pVideoReceiver = (IMediaEngine_internal_VideoReceiver *)pReceiver;
    } catch (int e) {
        status = e;
    } catch (exception e) {
        status = MB_ERROR_UNKNOWN;
    }
    
    return status;
}

MbStatus MBVideoInDevice::videoInDevStart(IMediaEngine_VideoParams* params)
{
    MbStatus status = MB_SUCCESS_OK;
    try {
        if (params == NULL) {
            throw MB_ERROR_NULL_POINTER;
        }
        status = MB_ERROR_UNKNOWN;
        if ([[this->delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
            if ([this->delegate respondsToSelector:@selector(startVideoInDevice:params:)]) {
                BOOL result = [this->delegate startVideoInDevice:this params:params];
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

MbStatus MBVideoInDevice::videoInDevStop(IMediaEngine_VideoParams* params)
{
    MbStatus status = MB_SUCCESS_OK;
    try {
        if (params == NULL) {
            throw MB_ERROR_NULL_POINTER;
        }
        if ([[this->delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
            if ([this->delegate respondsToSelector:@selector(stopVideoInDevice:params:)]) {
                [this->delegate stopVideoInDevice:this params:params];
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

MbStatus MBVideoInDevice::videoInDevClose(IMediaEngine_VideoParams* params)
{
    MbStatus status = MB_SUCCESS_OK;
    try {
        if (params == NULL) {
            throw MB_ERROR_NULL_POINTER;
        }
        if ([[this->delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
            if ([this->delegate respondsToSelector:@selector(closeVideoInDevice:params:)]) {
                [this->delegate closeVideoInDevice:this params:params];
            }
        }
        if (status != MB_SUCCESS_OK) {
            throw status;
        }
        
        this->m_pVideoReceiver = NULL;
        this->m_pVideoParams->Init();
    } catch (int e) {
        status = e;
    } catch (exception e) {
        status = MB_ERROR_UNKNOWN;
    }
    return status;
}

MbStatus MBVideoInDevice::videoInDevTerminate(IMediaEngine_VideoParams* params)
{
    MbStatus status = MB_SUCCESS_OK;
    try {
        if ([[this->delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
            if ([this->delegate respondsToSelector:@selector(terminateVideoInDevice:params:)]) {
                [this->delegate terminateVideoInDevice:this params:params];
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

MbStatus MBVideoInDevice::videoInDevSwitch(int id)
{
    MbStatus status = MB_SUCCESS_OK;
    try {
    } catch (int e) {
        status = e;
    } catch (exception e) {
        status = MB_ERROR_UNKNOWN;
    }
    return status;
}

MbStatus MBVideoInDevice::videoInDevRestart(IMediaEngine_VideoParams* params,void* pReceiver)
{
    MbStatus status = MB_SUCCESS_OK;
    try {
    } catch (int e) {
        status = e;
    } catch (exception e) {
        status = MB_ERROR_UNKNOWN;
    }
    return status;
}

MbStatus MBVideoInDevice::videoInDevGetState(MBVideoDevOperationParams* params)
{
    MbStatus status = MB_SUCCESS_OK;
    try {
    } catch (int e) {
        status = e;
    } catch (exception e) {
        status = MB_ERROR_UNKNOWN;
    }
    return status;
}

// functions

MbStatus MBVideoInDevice::SendRawVideoData(unsigned char *pData, int iWidth, int iHeight)
{
    CMediaEngineWrapper *mediaEngineWrapper = CMediaEngineWrapper::getEngineWrapperInstance();
    bool bOnlyLandscape = true;
    if (mediaEngineWrapper != NULL)
    {
        bOnlyLandscape = mediaEngineWrapper->getOnlyLandscape();
    }
    return this->SendRawVideoData(pData, iWidth, iHeight, bOnlyLandscape);
}

MbStatus MBVideoInDevice::SendRawVideoData(unsigned char *pData, int iWidth, int iHeight, bool bOnlyLandscape)
{
    MbStatus status = MB_SUCCESS_OK;
    try {
        if (this->m_pVideoReceiver == NULL) {
            throw MB_ERROR_UNKNOWN;
        }
        if (pData == NULL) {
            throw MB_ERROR_NULL_POINTER;
        }
        
        int width = iWidth;
        int height = iHeight;
        if (bOnlyLandscape == true) {
            if (width < height) {
                width = iHeight;
                height = iWidth;
            }
        }
        
        if (this->m_pVideoParams->iCurrUsedWidth != width || this->m_pVideoParams->iCurrUsedHeight != height) {
            unsigned int length = width * height * 3 / 2;
            if (this->m_rawVideoDataBufferLength != length) {
                if (this->m_pRawVideoDataBuffer != NULL) {
                    free(this->m_pRawVideoDataBuffer);
                    this->m_pRawVideoDataBuffer = NULL;
                    this->m_rawVideoDataBufferLength = 0;
                }
                this->m_pRawVideoDataBuffer = (unsigned char *)malloc(sizeof(unsigned char *) * length);
                if (this->m_pRawVideoDataBuffer == NULL) {
                    throw MB_ERROR_OUT_RESOURCES;
                }
                this->m_rawVideoDataBufferLength = length;
            }
            
            CMediaEngine *mediaEngine = CMediaEngine::getInstance();
            if (mediaEngine) {
                mediaEngine->SetSenderVideoParams(this->m_pVideoParams->channelid, width, height, this->m_pVideoParams->iFrameRate, this->m_pVideoParams->iTargetBitrate, this->m_pVideoParams->iIFrameInterval, 0);
            }
            IHostParticipant *hostParticipant = (IHostParticipant *)this->m_pVideoReceiver;
            hostParticipant->ChangeVideoInResolution(this->m_pVideoParams->channelid, width, height);
            
            // Set up a video frame.
            int w = width;
            int h = height;
            
            int ww = (w + 1) >> 1;
            int hh = (h + 1) >> 1;
            
            this->m_videoFrame.fmt = MB_VIDEO_RAW_YUV420P;
            this->m_videoFrame.size.w = w;
            this->m_videoFrame.size.h = h;
            this->m_videoFrame.linesize[0] = w;
            this->m_videoFrame.linesize[1] = ww;
            this->m_videoFrame.linesize[2] = ww;
            this->m_videoFrame.data[0] = (char *)this->m_pRawVideoDataBuffer;
            this->m_videoFrame.data[1] = this->m_videoFrame.data[0] + this->m_videoFrame.linesize[0] * h;
            this->m_videoFrame.data[2] = this->m_videoFrame.data[1] + this->m_videoFrame.linesize[1] * hh;
            
            this->m_videoFrameControl.bRestart = true;
            
            this->m_pVideoParams->iCurrUsedWidth = width;
            this->m_pVideoParams->iCurrUsedHeight = height;
        }
        CMediaEngineVideoDB::MBChangeNV12ToYUV420SP(pData, this->m_pRawVideoDataBuffer, iWidth, iHeight, width, height, false, true);
        
        // Set up a video frame control.
        this->m_videoFrameControl.iCurrentStampTemp = CMediaEngineSetting::getTimeInMilliseconds();
        
        // Send
        int result = MB_SUCCESS_OK;
        if(this->m_pVideoReceiver)
            result = this->m_pVideoReceiver->videoInput(&(this->m_videoFrame), &(this->m_videoFrameControl), this->m_pRawVideoDataBuffer, this->m_rawVideoDataBufferLength);
        if (result != MB_SUCCESS_OK) {
            throw MB_ERROR_TRY_AGAIN;
        }
        
        this->m_videoFrameControl.bRestart = false;
    } catch (int e) {
        status = e;
    } catch (exception e) {
        status = MB_ERROR_UNKNOWN;
    }
    return status;
}
