#include "MediaEngineWrapper.h"
#include <stdio.h>
#include "MediaEngineWrapperLog.h"
#include "MBMediaEngineDelegate.h"
#include "MBMediaEngineManager.h"

#define MBLOGGER MediaEngineWrapperLog::MEDIAENGINEWRAPPER

static CMediaEngineWrapper *instance = NULL;


#define AUDIO_CODEC_NUMBER 12
#define AUDIO_CODEC_DYNAMIC_PAYLOAD_START 6
static int m_AudioCodecTypeAndPayload[AUDIO_CODEC_NUMBER][2]={
    {MEDIA_CODEC_G711_PCMU,	0},
    {MEDIA_CODEC_G711_PCMA,	8},
    {MEDIA_CODEC_G729,		18},
    {MEDIA_CODEC_G7231,		4},
    {MEDIA_CODEC_GSM,		3},
    {MEDIA_CODEC_G722,		9},
    {MEDIA_CODEC_AMR_NB,	98},
    {MEDIA_CODEC_AMR_WB,	99},
    {MEDIA_CODEC_AAC,		105},
    {MEDIA_CODEC_PCM_WB,	106},
    {MEDIA_CODEC_iLBC,		107},
    {MEDIA_CODEC_SILK,		108}};






#define VIDEO_CODEC_NUMBER 3
#define VIDEO_CODEC_DYNAMIC_PAYLOAD_START 1
static int m_VideoCodecTypeAndPayload[VIDEO_CODEC_NUMBER][2]= {
    {MEDIA_CODEC_H263,	34},
    {MEDIA_CODEC_MPEG4,	109},
    {MEDIA_CODEC_H264,	96}};

//static char srtpKey[] = {0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61,0x61};

CMediaEngineWrapper* CMediaEngineWrapper::getEngineWrapperInstance()
{
    if(instance)
        return instance;
    else
        instance = new CMediaEngineWrapper();
    return instance;
}

void CMediaEngineWrapper::deleteEngineWrapperInstance()
{
    if(instance)
        delete(instance);
    instance = NULL;
}

CMediaEngineWrapper::CMediaEngineWrapper()
{
#ifdef _DEBUG
    MBLogger::Initialize(MBLogger::STDOUT,MBLogger::Debug,".\\MBMediaEngine.log");
#else
    MBLogger::Initialize(MBLogger::STDOUT,MBLogger::Error,".\\MBMediaEngine.log");
#endif
    MBLogger::SetDisplayFullTime(true);
    MediaEngineWrapperLog::MEDIAENGINETEST = MBLogger::GetLogger("MEDIAENGINETEST");
    MediaEngineWrapperLog::MEDIAENGINETEST->SetLevel(MBLogger::Error);
    MediaEngineWrapperLog::MEDIAENGINEWRAPPER = MBLogger::GetLogger("MEDIAENGINEWRAPPER");
    MediaEngineWrapperLog::MEDIAENGINEWRAPPER->SetLevel(MBLogger::Error);
    MediaEngineWrapperLog::MEDIAENGINEDEVICE = MBLogger::GetLogger("MEDIAENGINEDEVICE");
    MediaEngineWrapperLog::MEDIAENGINEDEVICE->SetLevel(MBLogger::Error);
    MediaEngineLog::MEDIAENGINE = MBLogger::GetLogger("MEDIAENGINE");
    MediaEngineLog::MEDIAENGINE->SetLevel(MBLogger::Error);
    MediaEngineLog::MEDIACONF = MBLogger::GetLogger("MEDIACONF");
    MediaEngineLog::MEDIACONF->SetLevel(MBLogger::Error);
    MediaEngineLog::MEDIACONFAUDIO = MBLogger::GetLogger("MEDIACONFAUDIO");
    MediaEngineLog::MEDIACONFAUDIO->SetLevel(MBLogger::Error);
    MediaEngineLog::MEDIACONFVIDEO = MBLogger::GetLogger("MEDIACONFVIDEO");
    MediaEngineLog::MEDIACONFVIDEO->SetLevel(MBLogger::Error);
    MediaEngineLog::MEDIAFRAMEWORK = MBLogger::GetLogger("MEDIAFRAMEWORK");
    MediaEngineLog::MEDIAFRAMEWORK->SetLevel(MBLogger::Error);
    MediaEngineLog::MEDIACLASS = MBLogger::GetLogger("MEDIACLASS");
    MediaEngineLog::MEDIACLASS->SetLevel(MBLogger::Error);
    MediaEngineLog::MEDIATRANSPORT = MBLogger::GetLogger("MEDIATRANSPORT");
    MediaEngineLog::MEDIATRANSPORT->SetLevel(MBLogger::Error);
    MediaEngineLog::MEDIAVIDEOENCODER = MBLogger::GetLogger("MEDIAVIDEOENCODER");
    MediaEngineLog::MEDIAVIDEOENCODER->SetLevel(MBLogger::Error);
    MediaEngineLog::MEDIAVIDEODECODER = MBLogger::GetLogger("MEDIAVIDEODECODER");
    MediaEngineLog::MEDIAVIDEODECODER->SetLevel(MBLogger::Error);
    MediaEngineLog::RTP = MBLogger::GetLogger("RTP");
    MediaEngineLog::RTP->SetLevel(MBLogger::Error);
    MediaEngineLog::FECIMPL = MBLogger::GetLogger("FECIMPL");
    MediaEngineLog::FECIMPL->SetLevel(MBLogger::Error);
    MediaEngineLog::FECDEC = MBLogger::GetLogger("FECDEC");
    MediaEngineLog::FECDEC->SetLevel(MBLogger::Error);
    MediaEngineLog::FECENC = MBLogger::GetLogger("FECENC");
    MediaEngineLog::FECENC->SetLevel(MBLogger::Error);
    MediaEngineLog::AJB = MBLogger::GetLogger("AJB");
    MediaEngineLog::AJB->SetLevel(MBLogger::Error);
    MediaEngineLog::NETCHECKER = MBLogger::GetLogger("NETCHECKER");
    MediaEngineLog::NETCHECKER->SetLevel(MBLogger::Error);
	MediaEngineLog::MEDIAAUDIOPROCESS = MBLogger::GetLogger("MEDIAAUDIOPROCESS");
	MediaEngineLog::MEDIAAUDIOPROCESS->SetLevel(MBLogger::Error);
    //bVideoChannelRun = false;
    memset(channels,0x0,sizeof(MBMediaChannelAppDefs)*MB_TOTAL_CHANNEL_NUM);
    for(int i = 0; i < MB_TOTAL_CHANNEL_NUM; i++)
    {
        channels[i].callid = -1;
        channels[i].id = -1;
        channels[i].attachid = -1;
    }
    enableLipSync = 0;
    appCallbackCB = NULL;
#warning working;
    //        pfnRemoteVideoChangeCB = NULL;
#warning working;
    m_mediaEngine = NULL;
    cameraId = 0;
    m_mediaWrapperSetting = CMediaEngineWrapperSetting::getInstance();
    m_mediaSetting = CMediaEngineSetting::getInstance();
    m_mediaSetting->setSupportLoadAndSaveYUVData(false,false,false);
    m_mediaSetting->setCloseAudioInAndOutBoth(0);
    m_mediaSetting->clearCodecAndPayloadList();
    int cpu_count = 2;
/*#ifdef OS_IOS
     AndroidCpuFamily cpuFamily = android_getCpuFamily();
     cpu_count = android_getCpuCount();
     if(cpu_count <= 0)
     cpu_count = 1;
#endif*/
    SET_PARAMS_DATA *paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
    paramPreData->preParams.iRtpInterval = 1;
    paramPreData->preParams.iMaxVideoFrameInSendQueue = 3;
    paramPreData->preParams.iCPUCount = cpu_count;
    paramPreData->preParams.iH264EncodeMode = 7;
    paramPreData->preParams.iH264EncodeRateControlMode = 2;
    paramPreData->preParams.iMaxAudioFrameInSendQueue = 0;
    paramPreData->preParams.iAudioRTPWithFixedRTPTimeStamp = 0; //luca temp testing
    paramPreData->preParams.iLipSyncEnable = enableLipSync;  //enable lip sync 
    paramPreData->preParams.iRTPSequenceStartFromZero = false;
    m_mediaSetting->setParamsKey(ME_PRECONDITION_PARAMS, *paramPreData);
    
    SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
    paramImmData->immParams.iDecErrorNoDisplayUntilIFrame = 1;
    paramImmData->immParams.bAudioFEC = false;
    paramImmData->immParams.iAudioFECPayload = 111;
    paramImmData->immParams.iNoMediaNotifyTime = 15000;
    paramImmData->immParams.bUseAudioEncThread = 0;
    paramImmData->immParams.iH264NalSize = 1000;
    paramImmData->immParams.bNoSendRtpBeforeRecvSps = false;
    paramImmData->immParams.iVideoQuality = 1;
    paramImmData->immParams.bUseAudioEncThread = false;
    paramImmData->immParams.iSampleRate = 8000;
    paramImmData->immParams.iAudioSampleInConf = 8000;
    paramImmData->immParams.aecMode = MEDIA_AEC_DEFAULT;
    paramImmData->immParams.iAECTime = 2;
    paramImmData->immParams.iNsValue = 4;	// Set NS(NR) value. range: 0 - 6, 0: disable.
    paramImmData->immParams.iAgcMode = 2;	// Set AGC mode. 0: fixed agc, 1: dynamic agc
    paramImmData->immParams.iAgcValue = 20;  // set AGC value. Range: 0-15 if float agc, if 0-30 if fixed agc or adaptive, 0: disable. if set iAgcMode.
    paramImmData->immParams.iVadValue = 1;

    paramImmData->immParams.iAgcValueInPlay = 0;//20;
    paramImmData->immParams.iAgcModeInPlay = 0;//2;
    paramImmData->immParams.iNsValueInPlay = 0;//2;
    paramImmData->immParams.iVadValueInPlay = 1;
    
    paramImmData->immParams.iAudioRTPTosValue = 7;
    paramImmData->immParams.iAudioRTCPTosValue = 0;
    paramImmData->immParams.iVideoRTPTosValue = 4;
    paramImmData->immParams.iVideoRTCPTosValue = 0;
    paramImmData->immParams.bRestartDecoderRevHeader = false;
    m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS, *paramImmData);
    
    
    SET_PARAMS_DATA *paramRuntimeData = &(m_mediaSetting->getParamsKey(ME_RUNTIME_PARAMS));
    paramRuntimeData->runParams.fMicBefAecVolume = 0.3f;
    m_mediaSetting->setParamsKey(ME_RUNTIME_PARAMS, *paramRuntimeData);
    // video information
    localVideoParams.profile = 0x42E01F;
    localVideoParams.iWidth = 1280;
    localVideoParams.iHeight = 720;
    localVideoParams.iFrameRate = 15;
    localVideoParams.iIFrameInterval = 3;
    localVideoParams.iTargetBitrate = 512000;
    localVideoParams.size = MEDIA_VIDEO_SIZE_720P;
    MBSetDefaultIntoCurrentVideoParams();
    localDataParams.profile = localVideoParams.profile;
    localDataParams.iWidth = localVideoParams.iWidth;     
    localDataParams.iHeight = localVideoParams.iHeight;     
    localDataParams.iFrameRate = localVideoParams.iFrameRate; 
    localDataParams.iIFrameInterval = localVideoParams.iIFrameInterval;
    localDataParams.iTargetBitrate = localVideoParams.iTargetBitrate; 
    localDataParams.size = localVideoParams.size;
    setDefaultSenderParam();
    
    m_mediaWrapperSetting->setAudioParameters((char*)"use_audio_fec",(char*)"false");
    m_mediaWrapperSetting->setAudioParameters((char*)"use_audio_silk",(char*)"true");
    m_mediaWrapperSetting->setAudioParameters((char*)"use_audio_g711",(char*)"true");
    m_mediaWrapperSetting->setAudioParameters((char*)"use_audio_g723",(char*)"true");
    m_mediaWrapperSetting->setAudioParameters((char*)"use_audio_g729",(char*)"true");
    m_mediaWrapperSetting->setAudioParameters((char*)"use_audio_amrnb",(char*)"true");
    
    m_mediaWrapperSetting->setVideoParameters((char*)"use_video_fec",(char*)"false");
    m_mediaWrapperSetting->setVideoParametersInt((char*)"use_video_minimum_iframe_interval",2000);
    
    m_mediaStat = CMediaEngineStatistic::getInstance();
    m_mediaVideoDB = CMediaEngineVideoDB::getInstance();
    m_mediaUtils = CMediaEngineUtils::getInstance();
    m_mediaEngine = NULL;
#warning working;
    //        m_display = NULL;
    //        m_camera = NULL;
    m_pVideoInDevice = NULL;
    m_pVideoOutDevice = NULL;
#warning working;
    bDisplayMirror = false;
    
    bSupportRcvNetChecker = false;
    bSupportSendNetChecker = false;
    m_bOnlyLandscape = true;
}

CMediaEngineWrapper::~CMediaEngineWrapper()
{
    CMBMediaConfManager::DeleteInstance();
    CMediaEngine::deleteInstance();
    
    CMediaEngineWrapperSetting::deleteInstance();
    m_mediaWrapperSetting = NULL;
    CMediaEngineUtils::deleteInstance();
    m_mediaUtils = NULL;
    CMediaEngineStatistic::deleteInstance();
    m_mediaStat = NULL;
    CMediaEngineVideoDB::deleteInstance();
    m_mediaVideoDB = NULL;
    CMediaEngineSetting::deleteInstance();
    m_mediaSetting = NULL;
    
}

/***********************************************************************************
 * media engine start
 ************************************************************************************/
void CMediaEngineWrapper::CreateEngine()
{
    m_mediaEngine = CMediaEngine::getInstance();
    MediaEngineRegisterEvents((IMediaEngineEvent*)this);
    m_mediaSetting->setLogEnable(true);
    // conference object start
    pMediaManager = CMBMediaConfManager::GetInstance();
    pConf = pMediaManager->CreateConference();
    pConf->SetAudioInDevice(0, &m_audioDriver);
    pConf->SetAudioOutDevice(0, &m_audioDriver);
    pLocalParty = pConf->GetHostParticipant();
}

void CMediaEngineWrapper::DeleteEngine()
{
    MediaEngineRegisterEvents(NULL);
    ReleaseVideoDevices();
    
    if (m_mediaEngine == NULL) {
        MBLogError("m_mediaEngine = NULL");
    }
    else {
        CMediaEngine::deleteInstance();
        m_mediaEngine = NULL;
    }
    if(pConf)
    {
        pMediaManager->RemoveConference(pConf);
        pConf = NULL;
        pLocalParty = NULL;
    }
}

void CMediaEngineWrapper::setDefaultSenderParam()
{
    SetLocalVideoParameters(localVideoParams.iTargetBitrate,localVideoParams.iFrameRate,
                            localVideoParams.iIFrameInterval,localVideoParams.size);
}
void CMediaEngineWrapper::MBSetDefaultIntoCurrentVideoParams()
{
    currentVideoParams.iWidth = localVideoParams.iWidth;
    currentVideoParams.iHeight = localVideoParams.iHeight;
    currentVideoParams.iFrameRate = localVideoParams.iFrameRate;
    currentVideoParams.iIFrameInterval = localVideoParams.iIFrameInterval;
    currentVideoParams.iTargetBitrate = localVideoParams.iTargetBitrate;
    currentVideoParams.size = localVideoParams.size;
}

void CMediaEngineWrapper::MBSetMediaInfo(MBVideoMediaType type,MBMediaWrapperSet* value)
{
    if(NULL == value)
        return;
    switch(type)
    {
        case MB_LOCAL_REAL_TIME_VIDEO:
            localVideoParams.iWidth = value->width;
            localVideoParams.iHeight = value->height;
            localVideoParams.iFrameRate = value->framerate;
            localVideoParams.iIFrameInterval = value->iframeinterval;
            localVideoParams.iTargetBitrate = value->bitrate;
            localVideoParams.size = value->size;
            
            MBSetDefaultIntoCurrentVideoParams();
            setDefaultSenderParam();
            m_mediaVideoDB->setVideoCodecPriority(value->codecPriority);
            break;
        case MB_LOCAL_DATA_PRESENTATION:
            localDataParams.iWidth = value->width;
            localDataParams.iHeight = value->height;
            localDataParams.iFrameRate = value->framerate;
            localDataParams.iIFrameInterval = value->iframeinterval;
            localDataParams.iTargetBitrate = value->bitrate;
            localDataParams.size = value->size;
            break;
        default:
            break;
    }
}



void CMediaEngineWrapper::GetCurrentResolution(int &w, int &h)
{
    w = currentVideoParams.iWidth;
    h = currentVideoParams.iHeight;
}
void CMediaEngineWrapper::GetCurrentRemoteResolution(int &w, int &h)
{
#warning working;
    //        if(m_display)
    //        {
    //            return m_display->MBGetResolution(w,h);
    //        }
#warning working;
    
}
#warning working;
//    int CMediaEngineWrapper::SetOutputChangeCB(IMB_Display_Changed_event* pOutputEv)
//    {
//        pfnRemoteVideoChangeCB = pOutputEv;
//        return 0;
//
//    }
#warning working;

void CMediaEngineWrapper::setCurrentLocalVideoParam(IMediaEngine_VideoParams* currentParam)
{
    currentVideoParams.iWidth = currentParam->iWidth;
    currentVideoParams.iHeight = currentParam->iHeight;
    currentVideoParams.iFrameRate = currentParam->iFrameRate;
    currentVideoParams.iTargetBitrate = currentParam->iTargetBitrate;
}
void CMediaEngineWrapper::SetLocalVideoParameters(int bitrate,int framerate,
		int frameinterval,MediaVideoSize size, int h264profile)
{
    int w = 0;
    int h = 0;
    CMediaEngineSetting::GetResolutionDefine(size,w,h);
    int profileLevel = 0x4D801F;
    profileLevel = m_mediaSetting->CaculateProfileLevel(size,framerate,bitrate);
    MBLogInfo("CaculateProfileLevel=0x%x.",profileLevel);
    
    MBVideoCapableParams videoParams;
    memset(&videoParams,0x0,sizeof(MBVideoCapableParams));
    videoParams.h264Params.h264profile = 0x428000;
    videoParams.h264Params.h264profilelevel = profileLevel;
    videoParams.size = size;
    videoParams.width = w;
    videoParams.height = h;
    videoParams.bitrate = bitrate;
    videoParams.iframeinterval = frameinterval;
    videoParams.framerate = framerate;
    m_mediaSetting->SetVideoCapableParams(&videoParams);
}

void CMediaEngineWrapper::SetLocalVideoParameters(MBVideoCapableParams* param)
{
	int profileLevel = 0x4D801F;
	CMediaEngineSetting::SetVideoCapableParams(param);
	profileLevel = m_mediaSetting->CaculateProfileLevel(param->size,param->framerate,param->bitrate);
	MBLogInfo("2 CaculateProfileLevel=0x%x. param->size[%d]",profileLevel, param->size);
	MBVideoCapableParams* getParam = NULL;
	CMediaEngineSetting::GetVideoCapableParams(&getParam);
	//if(getParam)
	//	getParam->h264Params.h264profilelevel = profileLevel;
}

void CMediaEngineWrapper::ReleaseVideoDevices()
{
}
void CMediaEngineWrapper::ConstructDevices()
{
#warning working;
    //        MBLogInfo("ConstructDevices m_camera=%p,m_display=%p.",m_camera,m_display);
    //        if(m_camera == NULL)
    //        {
    //            m_camera = new MBCamera();
    //            m_camera->SetMediaEngineWrapper((CMediaEngineWrapper*)this);
    //            pConf->SetVideoInDevice(0,( IMediaEngine_internal_videoInDevice*)m_camera);
    //        }
    //        else
    //            return;
    //
    //        if(m_display == NULL)
    //        {
    //            m_display = new MBDisplay();
    //            pConf->SetVideoOutDevice(0,(IMediaEngine_internal_videoOutDevice*)m_display);
    //        }
    //        else
    //            return;
#warning working;
    
    
}

void CMediaEngineWrapper::DestructDevices()
{
#warning working;
    //        MBLogInfo("DestructDevices m_camera=%p,m_display=%p.",m_camera,m_display);
    //        if(m_display && (m_display->bInit || m_display->bStart))
    //            return;
    //        if(m_camera && (m_camera->bInit || m_camera->bStart))
    //            return;
    //        if(m_display != NULL)
    //            delete(m_display);
    //        m_display = NULL;
    //        if(m_camera != NULL)
    //            delete(m_camera);
    //        m_camera = NULL;
#warning working;
    
}

#warning working begin;
//    void CMediaEngineWrapper::SetVideoInputDevice(MBCamera* pInput)
//    {
//        MBLogInfo("SetVideoInputDevice CMBCamera=%p.",pInput);
//#ifdef OS_IOS
//        //m_camera = (MBCamera*)pInput;
//        m_camera = pInput;
//#endif
//    }
//    void CMediaEngineWrapper::SetVideoOutputDevice(MBDisplay* pOutput)
//    {
//        MBLogInfo("SetVideoOutputDevice CMBDisplay=%p.",pOutput);
//#ifdef OS_IOS
//       // m_display = (MBDisplay*)pOutput;
//        m_display = pOutput;
//#endif
//    }
#warning working end;


/***********************************************************************************
 * media engine end
 ************************************************************************************/





/***********************************************************************************
 * inherited interface functions below block includes the implementation of interface
 * start
 ************************************************************************************/
// IMediaEngineEvent
void CMediaEngineWrapper::ChannelAttach(int channelreceiveId,int channelsendId)
{
    channels[channelreceiveId].attachid = channelsendId;
    channels[channelsendId].attachid = channelreceiveId;
    channels[channelreceiveId].iReceivedVideoSliceNum = 0;
    RegisterRTCPReportStatistic(channelsendId,true,5);
    RegisterRTCPReportStatistic(channelreceiveId,true,5);
    memset(&(channels[channelreceiveId].info), 0x0, sizeof(MBRTPTimeStampInfo));
    channels[channelreceiveId].lipsyncgap = 0;
    memset(&(channels[channelsendId].info), 0x0, sizeof(MBRTPTimeStampInfo));
    channels[channelsendId].lipsyncgap = 0;
}

void CMediaEngineWrapper::ChannelCreate(int callid, int channelId,MediaType type,MediaChannelDirection direction)
{
#warning working start;
    try {
        switch (type) {
            case MEDIA_TYPE_AUDIO: {
                switch (direction) {
                    case MEDIA_CHANNEL_RECEIVER:
                        setDefaultSenderParam();
                        break;
                    case MEDIA_CHANNEL_SENDER:
                        break;
                        
                    default:
                        throw MB_ERROR_BAD_PARAMS;
                        break;
                }
                m_mediaEngine->RegisterAudioDriver(channelId, pLocalParty);
            }
                break;
#ifdef MB_MEDIA_ENGINE_VIDEO_SUPPORT
            case MEDIA_TYPE_VIDEO: {
                switch (direction) {
                    case MEDIA_CHANNEL_RECEIVER: {
                        if (this->m_pVideoOutDevice == NULL) {
                            this->m_pVideoOutDevice = new MBVideoOutDevice();
                            this->m_pVideoOutDevice->delegate = this->delegate;
                        }
                        if (this->m_pVideoOutDevice == NULL) {
                            throw MB_ERROR_OUT_RESOURCES;
                        }
                        pLocalParty->SetVideoOutDevice(this->m_pVideoOutDevice);
                        m_mediaEngine->RegisterVideoOutDevice(channelId, (IMediaEngine_internal_VideoOutDriver *)pLocalParty);
                    }
                        break;
                    case MEDIA_CHANNEL_SENDER: {
                        if (this->m_pVideoInDevice == NULL) {
                            this->m_pVideoInDevice = new MBVideoInDevice();
                            this->m_pVideoInDevice->delegate = this->delegate;
                        }
                        if (this->m_pVideoInDevice == NULL) {
                            throw MB_ERROR_OUT_RESOURCES;
                        }
                        pLocalParty->SetVideoInDevice(this->m_pVideoInDevice);
#ifdef MB_ENCODE_CAMERA
                        pLocalParty->bSupportRawData = false;
                        pLocalParty->bSupportEncodedData = true;
#else
                        pLocalParty->bSupportEncodedData = false;
                        pLocalParty->bSupportRawData = true;
#endif
                        m_mediaEngine->RegisterVideoInDevice(channelId, (IMediaEngine_internal_VideoInDriver *)pLocalParty);
                    }
                        break;
                        
                    default:
                        throw MB_ERROR_BAD_PARAMS;
                        break;
                }
            }
                break;
#endif
                
            default:
                throw MB_ERROR_BAD_PARAMS;
                break;
        }
        
        memset(&channels[channelId], 0x0, sizeof(MBMediaChannelAppDefs));
        channels[channelId].id = channelId;
        channels[channelId].type = type;
        channels[channelId].direction = direction;
        channels[channelId].attachid = -1;
        channels[channelId].callid = callid;
    } catch (int e) {
        //        status = e;
    } catch (exception e) {
        //        status = MB_ERROR_UNKNOWN;
    }
    
    return;
    
    
    //        if (type == MEDIA_TYPE_VIDEO_DATA) {
    //            return;
    //        }
    //        memset(&channels[channelId],0x0,sizeof(MBMediaChannelAppDefs));
    //        channels[channelId].id = channelId;
    //        channels[channelId].type = type;
    //        channels[channelId].direction = direction;
    //	channels[channelId].attachid = -1;
    //	channels[channelId].callid = callid;
    //        // set the channel id for application layer
    //        if(type == MEDIA_TYPE_AUDIO)
    //        {
    //            NSLog(@"audio");
    //            m_mediaEngine->RegisterAudioDriver(channelId,pLocalParty);
    //            if(direction == MEDIA_CHANNEL_RECEIVER)
    //            {
    //                setDefaultSenderParam();
    //            }
    //        }
    //        else
    //        {
    //#ifdef MB_MEDIA_ENGINE_VIDEO_SUPPORT
    //            if(direction == MEDIA_CHANNEL_RECEIVER)
    //            {
    //                NSLog(@"media receiver");
    //                if(m_display == NULL)
    //                {
    //                    m_display = new MBDisplay();
    //                }
    //                if(m_display == NULL)
    //                    return;
    //                m_display->bNativeDisplay = bHardwareDisplay;
    //                pLocalParty->SetVideoOutDevice((IMediaEngine_internal_videoOutDevice*)m_display);
    //#ifdef MB_WINDOWS_VIDEO_DEVICE
    //                if(hRemoteWindow)
    //                    m_display->SetDisplayHandle(hRemoteWindow);
    //#endif
    //                m_mediaEngine->RegisterVideoOutDevice(channelId,(IMediaEngine_internal_VideoOutDriver*)pLocalParty);
    //                m_display->MBSetOutputChangeCB(pfnRemoteVideoChangeCB);
    //            }
    //            else
    //            {
    //                NSLog(@"media sender");
    //			MBLogInfo("callback m_camera=%p,(cameraId)=%d.",m_camera,(cameraId));
    //                if(m_camera == NULL)
    //                {
    //                    NSLog(@"camera is null");
    //                    m_camera = new MBCamera();
    //                }
    //                else {
    //                    NSLog(@"camera is not null");
    //                }
    //                m_camera->SetMediaEngineWrapper((CMediaEngineWrapper*)this);
    //                m_camera->SetCameraID(cameraId);
    //#ifdef MB_WINDOWS_VIDEO_DEVICE
    //                if(hLocalWindow)
    //                    m_camera->SetPreviewHandle(hLocalWindow);
    //#endif
    //                m_camera->m_MediaEngine = m_mediaEngine;
    //                pLocalParty->SetVideoInDevice((IMediaEngine_internal_videoInDevice*)m_camera);
    //#ifdef MB_ENCODE_CAMERA
    //			pLocalParty->bSupportRawData = false;
    //			pLocalParty->bSupportEncodedData = true;
    //#else
    //			pLocalParty->bSupportEncodedData = false;
    //			pLocalParty->bSupportRawData = true;
    //#endif
    //                m_mediaEngine->RegisterVideoInDevice(channelId,(IMediaEngine_internal_VideoInDriver*)pLocalParty);
    //
    //            }
    //#endif
    //        }
#warning working end;
}

void CMediaEngineWrapper::ChannelSetLocalAddress(int callid,int channelId,char *ip, unsigned short port, MediaType type)
{
}

void CMediaEngineWrapper::ChannelSetRemoteAddress(int callid,int channelId,char *ip, unsigned short port, MediaType type)
{
}

void CMediaEngineWrapper::ChannelSetPayload(int channelId,MediaType type, MediaChannelDirection direction,MediaCodecType codecType, int payload)
{
    channels[channelId].codecType = codecType;
    channels[channelId].payload = payload;
}

void CMediaEngineWrapper::ChannelRelease(int channelId,MediaType type,MediaChannelDirection direction)
{
#warning working begin;
    try {
        switch (type) {
            case MEDIA_TYPE_AUDIO:
                break;
#ifdef MB_MEDIA_ENGINE_VIDEO_SUPPORT
            case MEDIA_TYPE_VIDEO:
                if (direction == MEDIA_CHANNEL_SENDER) {
                    RegisterRTCPReportStatistic(channelId, false, 2000);
                }
                break;
#endif
                
            default:
                break;
        }
    } catch (int e) {
    } catch (exception e) {
    }
    
    return;
    //        // set the channel id for application layer
    //        if(type == MEDIA_TYPE_VIDEO)
    //        {
    //#ifdef MB_MEDIA_ENGINE_VIDEO_SUPPORT
    //            if(direction == MEDIA_CHANNEL_SENDER)
    //            {
    //                RegisterRTCPReportStatistic(channelId,false,2000);
    //            }
    //#endif
    //        }
#warning working end;
}

void CMediaEngineWrapper::ChannelReleaseLeft(int channelId,MediaType type, MediaChannelDirection direction)
{
#warning working begin;
    try {
        switch (type) {
            case MEDIA_TYPE_AUDIO:
                break;
#ifdef MB_MEDIA_ENGINE_VIDEO_SUPPORT
            case MEDIA_TYPE_VIDEO:
                switch (direction) {
                    case MEDIA_CHANNEL_RECEIVER:
//                        pLocalParty->SetVideoOutDevice(NULL);
//                        if (this->m_pVideoOutDevice) {
//                            delete this->m_pVideoOutDevice;
//                            this->m_pVideoOutDevice = NULL;
//                        }
                        break;
                    case MEDIA_CHANNEL_SENDER:
//                        pLocalParty->SetVideoInDevice(NULL);
//                        if (this->m_pVideoInDevice) {
//                            delete this->m_pVideoInDevice;
//                            this->m_pVideoInDevice = NULL;
//                        }
                        break;
                        
                    default:
                        break;
                }
                break;
#endif
                
            default:
                break;
        }
    } catch (int e) {
    } catch (exception e) {
    }
    
    memset(&channels[channelId], 0x0, sizeof(MBMediaChannelAppDefs));
    channels[channelId].id = -1;
    channels[channelId].attachid = -1;
    channels[channelId].callid = -1;
    if (pConf) {
        pConf->DeleteChannelInfo(channelId);
    }
    
    //        // set the channel id for application layer
    //	//int callid = channels[channelId].callid;
    //        memset(&channels[channelId],0x0,sizeof(MBMediaChannelAppDefs));
    //	channels[channelId].id = -1;
    //	channels[channelId].attachid = -1;
    //	channels[channelId].callid = -1;
    //        if(pConf)
    //            pConf->DeleteChannelInfo(channelId);
    //        if(type == MEDIA_TYPE_VIDEO)
    //        {
    //#ifdef MB_MEDIA_ENGINE_VIDEO_SUPPORT
    //            if(direction == MEDIA_CHANNEL_RECEIVER)
    //            {
    //                if(m_display && !(m_display->bInit))
    //                {
    //                    m_display->MBSetOutputChangeCB(NULL);
    //                    pLocalParty->SetVideoOutDevice(NULL);
    //                    delete(m_display);
    //                    m_display = NULL;
    //                }
    //            }
    //            else
    //            {
    //                if(m_camera && !(m_camera->bInit) && !(m_camera->bExternalCreated))
    //                {
    //                    m_camera->m_MediaEngine = NULL;
    //                    m_camera->SetMediaEngineWrapper(NULL);
    //                    pLocalParty->SetVideoInDevice(NULL);
    //                    delete(m_camera);
    //                    m_camera = NULL;
    //                }
    //            }
    //#endif
    //        }
#warning working end;
}

void CMediaEngineWrapper::ChannelStateChanged(int channelId,MediaEngine_Channel_State state)
{}

void CMediaEngineWrapper::ChannelPlayFirstAudio(int channelId, int len, int sample)
{}

void CMediaEngineWrapper::MicrophoneDataCb(char* pData,int size)
{}

void CMediaEngineWrapper::SpeakerDataCb(char* pData,int size)
{}

void CMediaEngineWrapper::nInfoCb(MediaEngine_InfoCodes infoCodes, int value, char* infoReason)
{}

void CMediaEngineWrapper::nErrorCb(MediaEngine_ErrorCodes errorCodes, int value, char* errorReason, int channelId)
{
    id <MBMediaEngineDelegate> delegate = this->delegate;
    if ([[delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
        if ([delegate respondsToSelector:@selector(nErrorCb:value:errorReason:channelId:)]) {
            [delegate nErrorCb:errorCodes value:value errorReason:errorReason channelId:channelId];
        }
    }
    
    return;
}
void CMediaEngineWrapper::nNoMediaDataCb(int callId, int channelId, MediaType type, int iNoDataInterval)
{
    MBLogInfo("callid=%d,channelid=%d,type=%d, nodatainterval=%d.", callId, channelId, type, iNoDataInterval);
}
// get the  video frame, usually it works for getting the received video width and height from first video
void CMediaEngineWrapper::notifyReceiveVideoFrame(int id,MediaEngine_VIDEO_FORMAT type,int width,int height,MBRTPTimeStampInfo* rtpTimeInfo)
{
#ifdef MB_MEDIA_ENGINE_VIDEO_SUPPORT
    switch(type)
    {
        case ME_Video_Format_P_Frame:
            if(!channels[id].bHadReceivedIFrame)
            {
                // require I frame
                RequireSenderChannelToIFrameAsNext(id);
            }
            break;
        case ME_Video_Format_I_Frame:
	    if(channels[id].iReceivedVideoWidth > 0 && channels[id].iReceivedVideoHeight > 0)
	    {
                channels[id].bHadReceivedIFrame = true;
	    }
            break;
        case ME_Video_Format_H264_SPS:
            if(channels[id].iReceivedVideoWidth != width || channels[id].iReceivedVideoHeight != height)
            {
                if(channels[id].iReceivedVideoWidth == 0 || channels[id].iReceivedVideoHeight == 0)
                {
                    channels[id].iReceivedVideoWidth = width;
                    channels[id].iReceivedVideoHeight = height;
                }
                else
                {
                    channels[id].iReceivedVideoWidth = width;
                    channels[id].iReceivedVideoHeight = height;
                    channels[id].bHadReceivedIFrame = false;
                }
            }
	    channels[id].iReceivedVideoSliceNum = 0;
            break;
        default:
            break;
    }
	if(channels[id].iReceivedVideoSliceNum == 0 && channels[id].type == MEDIA_TYPE_VIDEO)
    {
        //bVideoNoSendVideoBeforeRecvSps
        int sendchannelid = channels[id].attachid;
        if(sendchannelid >= 0 )
        {
            m_mediaEngine->SetOnlySendVideoHeader(sendchannelid ,false);
        }
        /*SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
         paramImmData->immParams.bNoSendRtpBeforeRecvSps = false;
         m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS, *paramImmData); */
    }
    channels[id].iReceivedVideoSliceNum ++;
#endif
}

void CMediaEngineWrapper::notifyVideoReceivePacketLost(int id, MediaEngine_VIDEO_FORMAT type,int gap)
{
#ifdef MB_MEDIA_ENGINE_VIDEO_SUPPORT
    if(gap >= 0)
    {
        RequireSenderChannelToIFrameAsNext(id);
    }
#endif
}

void CMediaEngineWrapper::notifyVideoRequireFastUpdate(int id, MediaEngine_VIDEO_FORMAT type, int param, int value)
{
#ifdef MB_MEDIA_ENGINE_VIDEO_SUPPORT
    RequireSenderChannelToIFrameAsNext(id);
#endif
}

MbStatus CMediaEngineWrapper::SetMaximumBandwidth(int channelid, unsigned int bitrate)
{
    return m_mediaEngine->SetMaximumBandwidth(channelid, bitrate);
}
// require remote side to change bitrate
MbStatus CMediaEngineWrapper::RequestRemoteBitrateChanged(int channelid, unsigned int bitrate)
{
    return m_mediaEngine->RequestRemoteBitrateChanged(channelid, bitrate);
}

// IMediaEngine_Media_Envent
MbStatus CMediaEngineWrapper::RequestIFrameEv(int channelid, MediaEngine_IFrameReqMethod method)
{
    int sendchannelid = channels[channelid].attachid;
    if(sendchannelid>=0)
    {
        m_mediaEngine->SetIFrameAsNextFrame(sendchannelid);
    }
    MBLogInfo("channelid:%d.sendchannelid=%d.",channelid,sendchannelid);
    return MB_SUCCESS_OK;
}

MbStatus CMediaEngineWrapper::RequestRPSIEv(int channelid, 
							MediaEngine_IFrameReqMethod method,
							unsigned int senderssrc,			/* addressee ssrc */
							unsigned int payload,		/* payload		  */
							unsigned char* bitStr,		/* bitStr		  */
							unsigned int bitNum)
{
	int sendchannelid = channels[channelid].attachid;
	if(sendchannelid>=0)
	{
		m_mediaEngine->SetIFrameAsNextFrame(sendchannelid);
	}
	MBLogInfo("channelid:%d.sendchannelid=%d, method=%d, senderssrc=%u, payload=%u.",
			channelid,sendchannelid, method, senderssrc, payload);
	return MB_SUCCESS_OK;
}

MbStatus CMediaEngineWrapper::ReceivedRTCP_TMMBR(int channelid, unsigned int maxbr,unsigned int overhead)
{
    int sendchannelid = channels[channelid].attachid;
    if(sendchannelid>=0)
    {
        m_mediaEngine->SetNewVideoBitrate(sendchannelid, maxbr, overhead);
    }
    MBLogInfo("channelid:%d.sendchannelid=%d,max bitrate=%d.",channelid,sendchannelid,maxbr);
    return MB_SUCCESS_OK;
}

MbStatus CMediaEngineWrapper::ReceivedRTCP_TMMBN(int channelid, unsigned int maxbr,unsigned int overhead)
{
    int sendchannelid = channels[channelid].attachid;
    MBLogInfo("channelid:%d.sendchannelid=%d,max bitrate=%d.",channelid,sendchannelid,maxbr);
    return MB_SUCCESS_OK;
}

MbStatus CMediaEngineWrapper::ReceivedRTCP_XR_LossRLE(MBRTCPXRPacketParams *params)
{
    return MB_SUCCESS_OK;
}
MbStatus CMediaEngineWrapper::ReceivedRTCP_XR_DuplicatedRLE(MBRTCPXRPacketParams *params)
{
    return MB_SUCCESS_OK;
}
MbStatus CMediaEngineWrapper::ReceivedRTCP_XR_ReceiptTimes(MBRTCPXRPacketParams *params)
{
    return MB_SUCCESS_OK;
}
MbStatus CMediaEngineWrapper::ReceivedRTCP_XR_StatisticsSummary(MBRTCPXRStatisticSummaryParams *params)
{
    return MB_SUCCESS_OK;
}
MbStatus CMediaEngineWrapper::ReceivedRTCP_XR_VoipMetricsReport(MBRTCPXRVoipMetricsReportParams *params)
{
    return MB_SUCCESS_OK;
}

void CMediaEngineWrapper::ReceivedRTPPacket(int channelid ,const char *ip, unsigned short port, char *data, int len, bool *bDiscard)
{}

void CMediaEngineWrapper::ReceivedRTCPPacket(int channelid, const char *ip, unsigned short port, char *data, int len, bool *bDiscard)
{}

void CMediaEngineWrapper::FinishedEv(int channelid,char* deviceid)
{}

int CMediaEngineWrapper::RestartVideoInDevNetChecker(int channelid, int width, int height,
							int rate, IMediaEngine_ChannelParams* vpara)
{
	return MB_ERROR_UNKNOWN;
}

// IMediaEngine_rtp_data_event
void CMediaEngineWrapper::rtp_data_lost_event(int channelid, int curSeqId, int iLostNum)
{
    if(channels[channelid].type == MEDIA_TYPE_AUDIO)
        return;
    if(channelid >= 0 && iLostNum > 0)
    {
#ifdef MB_MEDIA_ENGINE_VIDEO_SUPPORT
        //MBLogDebug("channelid=%d,iLostNum=%d, try to require the IFrame.",channelid,iLostNum);
        RequireSenderChannelToIFrameAsNext(channelid);
#endif
    }
}

void CMediaEngineWrapper::rtp_data_info(int channelid,unsigned short timestamp)
{}

// IMediaEngine_RTCP_Statistic_Envent
int CMediaEngineWrapper::RTCPReportEv(int channelid,MediaRTCPStatisticsInfo rtcpInfo)
{
	MBLogInfo("channelid=%d,totalloss=%u,lostpercent=%u,jitter=%u,srLNTPtimestamp=%llu,srMNTPtimestamp=%llu,srTimestamp=%llu.",
		channelid,rtcpInfo.totalPacketLoss,rtcpInfo.packetLossPercent,rtcpInfo.jitter,
		rtcpInfo.srLNTPtimestamp,rtcpInfo.srMNTPtimestamp,rtcpInfo.srTimestamp);

	/*	if(channelid == m_videoSenderChannel)
	{
	unsigned int lostpercent= rtcpInfo.packetLossPercent;
	if(sendRTCPLostAccount == 0)
	{
	sendRTCPLostAccount--;
	if(sendRTCPLostAccount < -7)
	{
	sendRTCPLostAccount = 0;
	if(currentBitRate < 512000 && m_camera)
	{
	m_camera->SetChangedBitRate(20000);
	currentBitRate += 20000;
	}
	}
	}
	else if(lostpercent >= 7)
	{	
	if(sendRTCPLostAccount < 0)
	sendRTCPLostAccount = 0;
	sendRTCPLostAccount ++;
	// to many packet lost, we will try to reduce framerate
	if(sendRTCPLostAccount >= 2 && currentBitRate > 128000 && m_camera)
	{
	m_camera->SetChangedBitRate(-50000);
	currentBitRate -= 50000;
	sendRTCPLostAccount = 0;
	}
	}
	} */
	return 0;
}

int CMediaEngineWrapper::CaculateLipSync(MBRTPTimeStampInfo* audioInfo, MBRTPTimeStampInfo* videoInfo)
{
	int gap = 0;
	// caculate the latest audio rtp packet nntp time
	int audioTime = 0;
	if(audioInfo->i_currentTimeStamp64 >= audioInfo->i_nntpSyncTimeStamp32)
	{
		audioTime = (audioInfo->l_nntpTime64 + (audioInfo->i_currentTimeStamp64 - audioInfo->i_nntpSyncTimeStamp32))/90;
	}
	else
		return gap;

	//caculate the latest video rtp packet nntp time
	int videoTime = 0;
	if(videoInfo->i_currentTimeStamp64 >= videoInfo->i_nntpSyncTimeStamp32)
	{
		videoTime = (videoInfo->l_nntpTime64 + (videoInfo->i_currentTimeStamp64 - videoInfo->i_nntpSyncTimeStamp32))/90;
	}
	else
		return gap;

	int realTimeGap = 0;
	int mlTimeGap = 0;
	if(audioTime > videoTime)
	{
		mlTimeGap = audioInfo->i_currentMillonTime - videoInfo->i_currentMillonTime;
		realTimeGap = audioTime - videoTime;
		if(mlTimeGap < realTimeGap)
		{
			gap = mlTimeGap - realTimeGap;
		}
	}
	else
	{
		mlTimeGap =  videoInfo->i_currentMillonTime - audioInfo->i_currentMillonTime;
		realTimeGap = videoTime - audioTime;
		if(mlTimeGap > realTimeGap)
		{
			gap = mlTimeGap - realTimeGap;
		}
	}
	MBLogInfo("gap=%d.",gap);
	if(gap < 0)
		gap = -gap;
	return gap;
}

int CMediaEngineWrapper::FindChannel(int callid, MediaType type, MediaChannelDirection dirt)
{
	int id = -1;
	for(int i = 0; i < MB_TOTAL_CHANNEL_NUM; i ++)
	{
		if(channels[i].id >= 0 && channels[i].callid == callid && 
				channels[i].type == type && channels[i].direction == dirt)
		{
			id = i;
			break;
		}
	}
	return id;
}

// IMediaEngine_dtmf_event
void CMediaEngineWrapper::rtp_rfc2833_dtmf_received(int channelid, MediaEngineRFC2833DTMF *pDTMFEvent)
{
    MBLogInfo("event=%d.",(int)pDTMFEvent->event);
}

void CMediaEngineWrapper::rtp_inband_dtmf_received(int channelid, MediaEngineDTMFEvent event)
{
    MBLogInfo("receive inband dtmf event=%d.",(int)event);
}

//#ifdef EXTERNAL_TRANSPORT_DEMO
int CMediaEngineWrapper::SendRTPPacket(int channelid, const void *data, int len)	//success, return 0, else return negative
{
    return 0;
}
int CMediaEngineWrapper::SendRTCPPacket(int channelid, const void *data, int len)	//success, return 0, else return negative
{
    return 0;
}
//#endif
/***********************************************************************************
 * interface implementation end
 ************************************************************************************/


/***********************************************************************************
 * register callback class into media engine functions start
 ************************************************************************************/
void CMediaEngineWrapper::RegisterRTCPReportStatistic(int channelid,bool enable,int interval)
{
    m_mediaEngine->RegisterRTCPStatisticsEvent(channelid,enable,interval,( IMediaEngine_RTCP_Statistic_Envent*)this);
}

void CMediaEngineWrapper::RegisterRTPDataReport(int channelid,bool enable)
{
    m_mediaEngine->RegisterRTPDataInfoEvent(channelid,enable,(IMediaEngine_rtp_data_event*)this);
}
/***********************************************************************************
 * register callback class into media engine functions end
 ************************************************************************************/

/***********************************************************************************
 * video part control functions start
 ************************************************************************************/
#ifdef MB_MEDIA_ENGINE_VIDEO_SUPPORT
void CMediaEngineWrapper::registerAppCallback(IMediaEngine_require_to_app_Event* callback)
{
    appCallbackCB = callback;
}
void CMediaEngineWrapper::RequireSenderChannelToIFrameAsNext(int channelid)
{
    int sendchannelid = channels[channelid].attachid;
    if(sendchannelid < 0)
    {
        return;
    }
    int iinterval = m_mediaWrapperSetting->getIFrameRequestInterval();
    if(iinterval > 0)
    {
        channels[sendchannelid].iNowRequestTimeStamp = CMediaEngineSetting::getTimeInMilliseconds();
        if(channels[sendchannelid].iNowRequestTimeStamp > 0)
        {
            if((channels[sendchannelid].iNowRequestTimeStamp - channels[sendchannelid].iRequestIFrameTimeStampLast)<= (unsigned int)iinterval)
            {
                //MBLogInfo("too less time to request i frame, ingore it.last=%ud,now=%ud.",
                //	channels[sendchannelid].iRequestIFrameTimeStampLast,channels[sendchannelid].iNowRequestTimeStamp);
                return;
            }
        }
        channels[sendchannelid].iRequestIFrameTimeStampLast = channels[sendchannelid].iNowRequestTimeStamp;
    }
    MBLogError("SendIFrameRequest id=%d.",sendchannelid);
    m_mediaEngine->SendIFrameRequest(sendchannelid,CMediaEngineSetting::getIFrameReqMethod(channels[sendchannelid].callid));
    if ([[delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
        if ([delegate respondsToSelector:@selector(notify_require_fastupdate:)]) {
            [delegate notify_require_fastupdate:sendchannelid];
        }
    }
}

void CMediaEngineWrapper::RequireSenderChannelToIFrameAsNextForce(int channelid)
{
}

int CMediaEngineWrapper::RequestIFrameEvFromSipInfo(int callid)
{
    if(pConf)
    {
        int sendchannelid = pConf->QueryChannelId(callid,MEDIA_TYPE_VIDEO,MEDIA_CHANNEL_SENDER);
        if(sendchannelid>=0)
        {
            m_mediaEngine->SetIFrameAsNextFrame(sendchannelid);
        }
        MBLogInfo("callid =%d.",callid);
    }
    return 0;
}

void CMediaEngineWrapper::SendRawVideoData()
{
#warning working begin
    //        if(m_camera)
    //        {
    //            //MBLogError("SendRawVideoData,size=%d.",driveRawVideoDataSize);
    //            //pVideoInput->videoInput((unsigned char*)driveRawDataDum/*m_destYUVBuf*/,driveRawVideoDataSize,0,false,i_frameRate,0);//m_pEvParam);
    //        }
#warning working end;
}

char* CMediaEngineWrapper::getDisplayVideoData(int channelId,int& width, int& height,int rgbformat)
{
    //if(channelId>=0)
    //    return m_mediaEngine->getDisplayVideoData(channelId,data,width,height,rgbformat,bDisplayMirror);
    /*if(m_display)
    {
        return m_display->GetDisplayVideoData(width, height, rgbformat);
    }
    */
    return NULL;
}

int CMediaEngineWrapper::getDisplayVideoSize(int& width, int& height)
{
    /*if(m_display)
    {
        return m_display->GetDisplayVideoSize(width, height);
    }
    */
    return 0;
}
#endif
/***********************************************************************************
 * video part control functions end
 ************************************************************************************/

/***********************************************************************************
 * video devices control functions start
 ************************************************************************************/
#ifdef MB_WINDOWS_VIDEO_DEVICE
int CMediaEngineWrapper::displayVideoFromExternal(unsigned char* pData, int size, int width, int height)
{
    if(m_camera)
    {
        //return m_camera->DisplayVideoFromExternal(pData,size,width,height);
    }
    return -1;
}
void CMediaEngineWrapper::SetVideoWindows(int position,HWND hWindow)
{
    if(position == 0)
        hLocalWindow = hWindow;
    else
    {
        hRemoteWindow = hWindow;
        if(m_display)
        {
            m_display->SetDisplayHandle(hRemoteWindow);
        }
    }
}
void CMediaEngineWrapper::ChangeDisplayHandle(HWND hWindow)
{
    if(m_display)
    {
        hRemoteWindow = hWindow;
        m_display->ChangeDisplayHandle(hRemoteWindow);
    }
}
void CMediaEngineWrapper::SetVideoInMode( MediaEngine_Display_Mode mode, int interval)
{
    if(m_camera)
    {
        //		return m_camera->SetVideoInMode(mode,interval);
    }
}

void CMediaEngineWrapper::setCurrentVideo(BOOL pDisplayBG,BOOL bRestart)
{
    if(m_camera)
    {
        //		return m_camera->setCurrentVideo(pDisplayBG,currentVideoParams.iWidth,currentVideoParams.iHeight,bRestart);
    }
}
#endif //MB_WINDOWS_VIDEO_DEVICE
void CMediaEngineWrapper::SetCameraID(int id)
{
#warning working begin;
    //        cameraId = id;
    //        if(m_camera)
    //        {
    //            m_camera->SetCameraID(id);
    //        }
#warning working end;
}

void CMediaEngineWrapper::SendCameraVideoData(char* pData, int size,int width, int height)
{
#warning working begin
    //    if(m_camera)
    //    {
    ////        m_camera->SendCameraVideoData(pData,size,width,height);
    //    }
#warning working end
}
/*void CMediaEngineWrapper::setRemoteRendererSize(int dispWidth, int dispHeight)
 {
 #ifdef MEDIA_ENGINE_VIDEO
 
 #ifdef TARGET_MB_USE_OMX_CODEC
 if(hwManager != NULL)
 hwManager->setRemoteRendererSize(dispWidth,dispHeight);
 #endif
 if(m_display != NULL)
 m_display->SetRemoteSurfaceSize(dispWidth,dispHeight);
 #endif
 
 }*/
/*void CMediaEngineWrapper::setRemoteRenderer(sp<Surface>  &surface)
 {
 #ifdef MEDIA_ENGINE_VIDEO
 
 #ifdef TARGET_MB_USE_OMX_CODEC
 
 if(hwManager != NULL)
 hwManager->setRemoteRenderer(surface);
 #endif
 if(m_display != NULL)
 m_display->SetRemoteSurface(surface);
 #endif
 
 }*/

/*void CMediaEngineWrapper::setRemoteHandle(void* handle)
 {
 #ifdef MEDIA_ENGINE_VIDEO
 
 if(m_display != NULL)
 m_display->setRemoteHandle(handle);
 #endif
 
 }*/

/***********************************************************************************
 * video devices control functions end
 ************************************************************************************/

/***********************************************************************************
 * channel operation functions start
 ************************************************************************************/
int CMediaEngineWrapper::getNativeChannelId(int callid, MediaType type,MediaChannelDirection direction)
{
    if(pConf)
    {
        return pConf->QueryChannelId(callid, type,direction);
    }
    return -1;
}

int CMediaEngineWrapper::MBCreateChannel(int callid, MediaCodecType type,MediaChannelDirection dirt,MediaPacketType packetType)
{
    int channelId = -1;
    if(type != MEDIA_CODEC_H263 && type != MEDIA_CODEC_MPEG4 && type != MEDIA_CODEC_H264)
    {
        channelId = m_mediaEngine->CreateChannel(MEDIA_TYPE_AUDIO,dirt,MEDIA_PACKET_RTP,callid);
        channels[channelId].id = channelId;
        channels[channelId].type = MEDIA_TYPE_AUDIO,
        channels[channelId].direction = dirt;
        if(pConf)
            pConf->AddChannelInfo(callid,channelId,MEDIA_TYPE_AUDIO,dirt);
        
        if(dirt == MEDIA_CHANNEL_RECEIVER) {
            m_mediaEngine->RegisterDTMFEvent(channelId,true,false,(IMediaEngine_dtmf_event*)this);
            m_mediaEngine->SetRFC2833DTMFPayload(channelId,100);
        }
    }
#ifdef MB_MEDIA_ENGINE_VIDEO_SUPPORT
    else
    {
#ifdef TARGET_MB_USE_OMX_CODEC
        if(hwManager == NULL)
            ConstructHWManager();
#endif //NATIVE_CAMERA_SUPPORT
        MBMediaChannelAppConfig appConf;
        memset(&appConf, 0x0, sizeof(MBMediaChannelAppConfig));
        if(bSupportRcvNetChecker)
            appConf.bVideoRcvNetCheckEnable = true;
        else
            appConf.bVideoRcvNetCheckEnable = false;
        MBRTCPCapabilities oRtcpParams;
        oRtcpParams.Init();
        oRtcpParams.bRTCPXR = false;
        appConf.rtcpCap = &oRtcpParams;
        channelId = m_mediaEngine->CreateChannel(MEDIA_TYPE_VIDEO,dirt,packetType,callid,&appConf);
        channels[channelId].id = channelId;
        channels[channelId].type = MEDIA_TYPE_VIDEO,
        channels[channelId].direction = dirt;
		IMediaConf* conf = pMediaManager->QueryConf(callid);
        if(conf)
            conf->AddChannelInfo(callid,channelId,MEDIA_TYPE_VIDEO,dirt);
        if(dirt == MEDIA_CHANNEL_RECEIVER)
        {
            m_mediaEngine->RegisterRTPDataInfoEvent(channelId,true,(IMediaEngine_rtp_data_event*)this);
        }
    }
#endif
    
    if(dirt == MEDIA_CHANNEL_RECEIVER)
    {
        if(type != MEDIA_CODEC_H263 && type != MEDIA_CODEC_MPEG4 && type != MEDIA_CODEC_H264)
        {
            for(int i = AUDIO_CODEC_DYNAMIC_PAYLOAD_START; i < AUDIO_CODEC_NUMBER; i++)
            {
                m_mediaEngine->SetReceiveDynamicPayload(channelId,
                                                            (MediaCodecType)m_AudioCodecTypeAndPayload[i][0],m_AudioCodecTypeAndPayload[i][1]);
            }
        }
#ifdef MB_MEDIA_ENGINE_VIDEO_SUPPORT
        else
        {
            for(int i = VIDEO_CODEC_DYNAMIC_PAYLOAD_START; i < VIDEO_CODEC_NUMBER; i++)
            {
                m_mediaEngine->SetReceiveDynamicPayload(channelId,
                                                            (MediaCodecType)m_VideoCodecTypeAndPayload[i][0],m_VideoCodecTypeAndPayload[i][1]);
            }
        }
#endif
    }
    else
    {
        if(type != MEDIA_CODEC_H263 && type != MEDIA_CODEC_MPEG4 && type != MEDIA_CODEC_H264)
        {
            for(int i = 0; i < AUDIO_CODEC_NUMBER; i ++)
            {
                if(m_AudioCodecTypeAndPayload[i][0] == type)
                {
                    if(i >= AUDIO_CODEC_DYNAMIC_PAYLOAD_START)
                    {
                        // amr-nb, wb, aac, ilbc, pcmwb, silk dynamice codec type
                        m_mediaEngine->SetSendPayload(channelId,
                                                          (MediaCodecType)m_AudioCodecTypeAndPayload[i][0],
                                                          m_AudioCodecTypeAndPayload[i][1]);
                    }
                    else
                    {
                        m_mediaEngine->SetSendPayload(channelId,type);
                    }
                    MBLogInfo("found the codecType, i=%d,list0=%d,list1=%d.",
                              i, m_AudioCodecTypeAndPayload[i][0],m_AudioCodecTypeAndPayload[i][1]);
                    break;
                }
            }
        }
#ifdef MB_MEDIA_ENGINE_VIDEO_SUPPORT
        else
        {
            for(int i = 0; i < VIDEO_CODEC_NUMBER; i++)
            {
                if(m_VideoCodecTypeAndPayload[i][0] == type)
                {
                    if(i >= VIDEO_CODEC_DYNAMIC_PAYLOAD_START)
                    {
                        //h263, h264, mpeg4
                        m_mediaEngine->SetSendPayload(channelId,
                                                          (MediaCodecType)m_VideoCodecTypeAndPayload[i][0],
                                                          m_VideoCodecTypeAndPayload[i][1]);
                    }
                    else
                    {
                        m_mediaEngine->SetSendPayload(channelId,type);
                    }
                    MBLogInfo("found the video codecType, i=%d,list0=%d,list1=%d.",
                              i, m_VideoCodecTypeAndPayload[i][0],m_VideoCodecTypeAndPayload[i][1]);
                    break;
                }
            }
        }
#endif
    }
    return channelId;
}

int CMediaEngineWrapper::MBGetChannelCodecType(int channelid)
{
    MediaCodecType codecType = channels[channelid].codecType;
    return m_mediaWrapperSetting->getCodecTypeValue(codecType);
}


int CMediaEngineWrapper::MBSetChannelLocalPort(int channelid,int port)
{
    int status = -1;
    /*	if(i_externalTransport == 1)
     {
     status = m_network->MediaEngine_SetExternalReceiverTransport(channelid,true);
     }
     else*/
    status  = m_mediaEngine->SetLocalAddress(channelid,(char*)"0.0.0.0",port);
    return status;
}

int CMediaEngineWrapper::MBSetChannelRemoteIPAndPort(int channelid,char* remoteIp,int port)
{
    
    int status = -1;
    /*	if(i_externalTransport == 1)
     {
     MBLogError("i_externalTransport is 1");
     status = m_network->MediaEngine_SetExternalSenderTransport(channelid,true,this);
     }
     else */
    status  = m_mediaEngine->SetRemoteAddress(channelid,remoteIp,port);
    return status;
}


int CMediaEngineWrapper::MBInitializeChannel(int channelid)
{
    MBLogInfo("ENTER channelid=%d.",channelid);
    int status = m_mediaEngine->InitChannel(channelid);
    MBLogInfo("LEFT,status=%d.",status);
    return status;
}

int CMediaEngineWrapper::MBStartChannel(int channelid)
{
    MBLogInfo("ENTER:channelid=%d.",channelid);
    int status = m_mediaEngine->StartChannel(channelid);
    MBLogInfo("LEFT,status=%d.",status);
    return status;
}

int CMediaEngineWrapper::MBStopChannel(int channelid)
{
    MBLogInfo("ENTER channelid=%d.",channelid);
    int status = m_mediaEngine->StopChannel(channelid);
    MBLogInfo("LEFT,status=%d.",status);
    return status;
}

int CMediaEngineWrapper::MBDeleteChannel(int channelid)
{
    MediaType type;
    MediaChannelDirection dirt;
    MediaCodecType codecType;
    m_mediaEngine->getChannelType(channelid,type,dirt,codecType);
#ifdef MB_MEDIA_ENGINE_VIDEO_SUPPORT
    if(type == MEDIA_TYPE_VIDEO || type == MEDIA_TYPE_VIDEO_DATA)
    {
        if(dirt == MEDIA_CHANNEL_RECEIVER)
        {
            m_mediaEngine->RegisterRTPDataInfoEvent(channelid,false,NULL);
            //m_network->MediaEngine_SetExternalReceiverTransport(channelid,false);
            // unregister video rtcp statistic callback for video receiver channel
            m_mediaEngine->RegisterRTCPStatisticsEvent(channelid,false,0,(IMediaEngine_RTCP_Statistic_Envent*)this);
        }
        else
        {
            //m_mediaEngine->RegisterVideoInDevice(channelid,NULL);
            //			m_network->MediaEngine_SetExternalReceiverTransport(channelid,false);
            m_mediaEngine->RegisterRTCPStatisticsEvent(channelid,false,0,(IMediaEngine_RTCP_Statistic_Envent*)this);
        }
    }
    
#endif
    if(type == MEDIA_TYPE_AUDIO)
    {
        m_mediaEngine->RegisterRTCPStatisticsEvent(channelid,false,0,(IMediaEngine_RTCP_Statistic_Envent*)this);
    }
    MBLogInfo("ENTER channelid=%d.",channelid);
    int status = m_mediaEngine->DeleteChannel(channelid);
    MBLogInfo("LEFT,status=%d.",status);
    memset(&channels[channelid],0x0,sizeof(MBMediaChannelAppDefs));
    return status;
}

int CMediaEngineWrapper::MBAttachChannels(int receiveChannelid, int sendChannelid)
{
    int status = m_mediaEngine->AttachChannels(receiveChannelid,sendChannelid);
    channels[receiveChannelid].attachid = sendChannelid;
    channels[sendChannelid].attachid = receiveChannelid;
    return status;
}


/***********************************************************************************
 * channel operation functions end
 ************************************************************************************/

/***********************************************************************************
 * call & channel control functions start
 ************************************************************************************/
int CMediaEngineWrapper::GetAudioSenderChannelID(int callid) {
    IMediaConf* conf = pMediaManager->QueryConf(callid);
    if(conf)
        return conf->QueryChannelId(callid,MEDIA_TYPE_AUDIO,MEDIA_CHANNEL_SENDER);
    return -1;
}
int CMediaEngineWrapper::GetAudioReceiverChannelID(int callid) {
    IMediaConf* conf = pMediaManager->QueryConf(callid);
    if(conf)
        return conf->QueryChannelId(callid,MEDIA_TYPE_AUDIO,MEDIA_CHANNEL_RECEIVER);
    return -1;
}
int CMediaEngineWrapper::MBFECEnable(int channelid, int payload, int enable)
{
    MBLogInfo("channelid=%d,payload=%d,enable=%d.",
              channelid,payload,enable);
    bool fecEnable = true;
    if(enable == 0)
        fecEnable = false;
    //fec for audio receiver channel
    m_mediaEngine->SetFECPayloadType(channelid,payload);
    m_mediaEngine->EnableFec(channelid,fecEnable);
    return 0;
}

int CMediaEngineWrapper::MBSetFECEncoderParams(int channelid, int percent, int endPacketFec)
{
    MBLogInfo("channelid=%d,percent=%d,endPacketFec=%d.",
              channelid,percent,endPacketFec);
    bool fecEndEnable = true;
    if(endPacketFec == 0)
        fecEndEnable = false;
    m_mediaEngine->SetFECEncoderParams(channelid,percent,fecEndEnable);
    return 0;
}
int CMediaEngineWrapper::SetMute(int channelid, bool enable)
{
    return m_mediaEngine->SetMute(channelid,enable);
}

int CMediaEngineWrapper::SendRFC2833DTMF(int callid, char dtmfValue,int duration,int payload)
{
    int channelid = GetAudioSenderChannelID(callid);
    MBLogInfo("channelid=%d,callid=%d..",channelid,callid);
    return m_mediaEngine->SendRFC2833DTMF(channelid,dtmfValue,duration,payload);
}
int CMediaEngineWrapper::SendInbandDTMF(int callid, char dtmfValue)
{
    int channelid = GetAudioSenderChannelID(callid);
    MBLogInfo("channelid=%d,callid=%d..",channelid,callid);
    return m_mediaEngine->SendInbandDTMF(channelid, dtmfValue);
}
int CMediaEngineWrapper::GetRtcpStats(int channelid,MediaRTCPStatisticsInfo& stats)
{
    return m_mediaEngine->GetRTCPStatistics(channelid,stats);
}

int CMediaEngineWrapper::GetMediaStatistic(int channelid, MBMediaStatisticType type,MBMediaStatistic& stats)
{
    return m_mediaEngine->GetMediaStatistic(channelid,type,stats);
}

void CMediaEngineWrapper::EnableExternalReceiver(int channelid,bool enable)
{
    m_mediaEngine->EnableExternalReceiver(channelid,enable);
}
int CMediaEngineWrapper::SetExternalSender(int channelid, bool enable, IMediaEngine_external_transport* transport)
{
    return m_mediaEngine->SetExternalSender(channelid,enable,transport);
}

int CMediaEngineWrapper::SetSenderVideoParams(int channelid, MediaVideoSize videoSize, int framerate, int bitrate, int frameInterval, int profilelevel)
{
    return m_mediaEngine->SetSenderVideoParams(channelid,videoSize,framerate,bitrate,frameInterval,profilelevel,false, false);
}

int CMediaEngineWrapper::SetSenderVideoParams(int channelid, int width, int height, int framerate, int bitrate, int frameInterval, int profilelevel)
{
    return m_mediaEngine->SetSenderVideoParams(channelid,width,height,framerate,bitrate,frameInterval,profilelevel,false, false);
}

void CMediaEngineWrapper::SetVideoChannelFormat(bool bSendChannel,bool bRaw, bool bEncoded)
{
    if(pLocalParty)
        pLocalParty->SetVideoChannelFormat(bSendChannel,bRaw,bEncoded);
}
int CMediaEngineWrapper::GetSenderRemoteAddress(int channelid,char *ip,unsigned short &port)
{
    return m_mediaEngine->GetRemoteAddress(channelid,ip,port);
}
unsigned short CMediaEngineWrapper::getLocalPort(int channelid)
{
    unsigned short port = 0;
    m_mediaEngine->GetLocalPort(channelid,port);
    return port;
    
}

#ifdef MB_SECURE_RTP_SUPPORT
int CMediaEngineWrapper::EnableSRTP(int channelid,
							bool enable,
							MediaEngineSrtpCipherType cipherType,
							int cipherKeyLen,
							MediaEngineSrtpAuthType authType,
							int authKeyLen,
							int authTagLen,
							MediaEngineSrtpSecurityLevel securityLevel,
							char *key)
{
	return m_mediaEngine->EnableSRTP(channelid, enable, cipherType, cipherKeyLen, authType, authKeyLen, authTagLen, securityLevel, key);
}
#endif

/***********************************************************************************
 * call & channel control functions end
 ************************************************************************************/

/***********************************************************************************
 * hardware engine functions start
 ************************************************************************************/
void CMediaEngineWrapper::ConstructHWManager()
{
#ifdef TARGET_MB_USE_OMX_CODEC
    
    if(hwManager == NULL)
        hwManager = new HWCodecManager(m_mediaEngine);
#endif
}
void CMediaEngineWrapper::DestructHWManager()
{
//	MBLogInfo("DestructHWManager.");
#ifdef TARGET_MB_USE_OMX_CODEC
    if(hwManager != NULL)
        delete(hwManager);
    hwManager = NULL;
#endif
}
/*int CMediaEngineWrapper::SetUseJavaAudioDevice(int iJavaAudio)
 {
 return MBAudioDriver::setUseJavaAudioDriverSign(iJavaAudio);
 }*/
/***********************************************************************************
 * hardware engine functions end
 ************************************************************************************/



/***********************************************************************************
 * utils functions start
 ************************************************************************************/

int CMediaEngineWrapper::setCodecPayload(int iType, int payload)
{
    MediaCodecType codecType = m_mediaWrapperSetting->setCodecType(iType);
#ifdef MB_MEDIA_ENGINE_VIDEO_SUPPORT
    if(codecType == MEDIA_CODEC_H263 || codecType == MEDIA_CODEC_MPEG4 || codecType == MEDIA_CODEC_H264)
    {
        for(int i = VIDEO_CODEC_DYNAMIC_PAYLOAD_START; i < VIDEO_CODEC_NUMBER ; i++)
        {
            if(codecType == m_VideoCodecTypeAndPayload[i][0])
            {
                m_VideoCodecTypeAndPayload[i][1] = payload;
                MBLogInfo("set video codec type =%d as payload=%d.",
                          m_VideoCodecTypeAndPayload[i][0],m_VideoCodecTypeAndPayload[i][1]);
                return 0;
            }
        }
        return -1;
    }
#endif
    for(int i = AUDIO_CODEC_DYNAMIC_PAYLOAD_START; i < AUDIO_CODEC_NUMBER ; i++)
    {
        if(codecType == m_AudioCodecTypeAndPayload[i][0])
        {
            m_AudioCodecTypeAndPayload[i][1] = payload;
            MBLogInfo("set codec type =%d as payload=%d.",
                      m_AudioCodecTypeAndPayload[i][0],m_AudioCodecTypeAndPayload[i][1]);
            return 0;
        }
    }
    MBLogInfo("no found the codec type =%d, payload=%d.",iType,payload);
    return -1;
}
/***********************************************************************************
 * utils functions end
 ************************************************************************************/




/***********************************************************************************
 * media engine version functions start
 ************************************************************************************/
int CMediaEngineWrapper::setPhoneInfo(char* venderName, char* product, char* device,char* version)
{
    return CMediaEngineSetting::setProduct(venderName,product,device,version);
}

char* CMediaEngineWrapper::getVersionNumber()
{
    return m_mediaEngine->getVersionNumber();
}

char* CMediaEngineWrapper::getVersionInfo()
{
    return m_mediaEngine->getVersionInfo();
}
/***********************************************************************************
 * media engine version functions end
 ************************************************************************************/


/***********************************************************************************
 * nat/firewall pass functions start
 ************************************************************************************/
#ifdef MEDIA_ENGINE_NATPASS_SUPPORT

int CMediaEngineWrapper::NetPassCreateSocket(char* localIp, char* localPort)
{
    if(m_netpass_manager == NULL)
    {
        m_netpass_manager = CMediaNetwork::getInstance();
    }
    MBLogInfo("Start.");
    if(m_netpass_socket == NULL)
    {
        m_netpass_socket = m_netpass_manager->CreateSocketSession(localIp,localPort,this);
        if(m_netpass_socket == NULL)
        {
            MBLogError("failure:localIp=%s,localPort=%s.",localIp,localPort);
            return -1;
        }
        MBLogInfo("success");
    }
    else
    {
        MBLogError("socket is allocated last time, can't create this time.");
        return -2;
    }
    return 0;
}

int CMediaEngineWrapper::NetPassGetStunPublicAdress(char* stunServer,
                                                    char* stunPort, int sessionId,char* publicIpAndPort, int& publicIpAndPortLen,
                                                    int tryTimeOut,int tryCount)
{
    if(m_netpass_manager == NULL)
    {
        m_netpass_manager = CMediaNetwork::getInstance();
    }
    MBLogInfo("tryTimeOut=%d,tryCount=%d.",tryTimeOut,tryCount);
    
    if(m_netpass_socket == NULL)
    {
        MBLogError("failure:socket is NULL");
        return -1;
    }
    
    m_netpass_manager->SetSessionId(m_netpass_socket,sessionId);
    char pubIP[20]={0},pubPort[20]={0};
    bool ret = m_netpass_manager->GetLocalPublicAddressByStun(m_netpass_socket,
                                                              stunServer,stunPort,pubIP,20,pubPort,20,tryTimeOut,tryCount);
    if(ret)
    {
        MBLogInfo("success");
        memset(publicIpAndPort,0x0,publicIpAndPortLen);
        sprintf(publicIpAndPort,"%s:%s",pubIP,pubPort);
        publicIpAndPortLen = strlen(publicIpAndPort);
        return 0;
    }
    else
    {
        MBLogError("failure :stunServer=%s,stunPort=%d.",stunServer,stunPort);
        return -1;
    }
}

int CMediaEngineWrapper::NetPassSetLocalPublicAddress(char* loPublicIp,char* loPublicPort)
{
    MBLogInfo("%s:%s.",loPublicIp,loPublicPort);
    if(m_netpass_manager == NULL)
    {
        m_netpass_manager = CMediaNetwork::getInstance();
    }
    if(m_netpass_socket == NULL)
    {
        MBLogError("failure:socket is NULL");
        return -1;
    }
    MBLogInfo("enter.");
    if(m_netpass_manager->SetLocalPublicAddress(m_netpass_socket,loPublicIp,loPublicPort)==false)
    {
        return -1;
    }
    else
    {
        return 0;
    }
}

int CMediaEngineWrapper::NetPassSetRemoteAddress(char* rePrivateIp,char* rePrivatePort, char* rePublicIp, char* rePublicPort, char* mrsIp, char* mrsPort)
{
    MBLogInfo("%s:%s;%s:%s;%s:%s.",rePrivateIp,rePrivatePort,rePublicIp,rePublicPort,mrsIp,mrsPort);
    if(m_netpass_manager == NULL)
    {
        m_netpass_manager = CMediaNetwork::getInstance();
    }
    if(m_netpass_socket == NULL)
    {
        MBLogError("failure:socket is NULL");
        return -1;
    }
    MBLogInfo("enter.");
    if(m_netpass_manager->SetRemoteAddress(m_netpass_socket,rePrivateIp,rePrivatePort,rePublicIp,rePublicPort,mrsIp,mrsPort)==false)
    {
        return -1;
    }
    else
    {
        return 0;
    }
}

int CMediaEngineWrapper::NetPassGetNATType(int tryTimeOut, int tryCount)
{
    if(m_netpass_manager == NULL)
    {
        m_netpass_manager = CMediaNetwork::getInstance();
    }
    if(m_netpass_socket == NULL)
    {
        MBLogError("failure:socket is NULL");
        return -1;
    }
    MediaNetworkType type = m_netpass_manager->GetConnType(m_netpass_socket,tryTimeOut, tryCount);
    
    MBLogInfo("NetPassGetNATType:%d,tryTimeOut=%d, tryCount=%d.",(int)type,tryTimeOut, tryCount);
    switch(type)
    {
        case eMediaNetworkDirect:
            return 0;
        case eMediaNetworkStun:
            return 1;
        case eMediaNetworkRelay:
            return 2;
        default:
            return -1;
    }
}

int CMediaEngineWrapper::NetPassCheckPrivateAddress(int tryTimeOut, int tryCount)
{
    if(m_netpass_manager == NULL)
    {
        m_netpass_manager = CMediaNetwork::getInstance();
    }
    if(m_netpass_socket == NULL)
    {
        MBLogError("failure:socket is NULL");
        return -1;
    }
    
    if(m_netpass_manager->CheckPrivateAddress(m_netpass_socket,tryTimeOut, tryCount) == true)
    {
        MBLogInfo("OK,tryTimeOut=%d, tryCount=%d.",tryTimeOut, tryCount);
        return 0;
    }
    else
    {
        MBLogError("Failed,tryTimeOut=%d, tryCount=%d.",tryTimeOut, tryCount);
        return -1;
    }
}

int CMediaEngineWrapper::NetPassCheckPublicAddress(int tryTimeOut, int tryCount)
{
    if(m_netpass_manager == NULL)
    {
        m_netpass_manager = CMediaNetwork::getInstance();
    }
    if(m_netpass_socket == NULL)
    {
        MBLogError("failure:socket is NULL");
        return -1;
    }
    
    if(m_netpass_manager->CheckPublicAddress(m_netpass_socket,tryTimeOut, tryCount)==true)
    {
        MBLogInfo("OK, tryTimeOut=%d, tryCount=%d.",tryTimeOut, tryCount);
        return 0;
    }
    else
    {
        MBLogError("Failed,tryTimeOut=%d, tryCount=%d.",tryTimeOut, tryCount);
        return -1;
    }
}

int CMediaEngineWrapper::NetPassKeepAlive(int stunKeep,int stunTimeout,
                                          int remoteKeep,int remoteTimeout,
                                          int relayServerKeep,int relayTimeout)
{
    bool status = false;
    if(m_netpass_manager == NULL)
    {
        m_netpass_manager = CMediaNetwork::getInstance();
    }
    if(m_netpass_socket == NULL)
    {
        MBLogError("failure:socket is NULL");
        return -1;
    }
    MBLogInfo("stunKeep=%d, remoteKeep=%d, relayServerKeep=%d",
               stunKeep, remoteKeep, relayServerKeep);
    if(stunKeep == 1)
    {
        status = m_netpass_manager->StartSendKeepAliveToSTUNServer(m_netpass_socket,stunTimeout);
        if(!status)
            return -1;
    }
    
    if(remoteKeep == 1)
    {
        status = m_netpass_manager->StartSendKeepAliveToRemote(m_netpass_socket,remoteTimeout);
        if(!status)
            return -2;
        
    }
    if(relayServerKeep == 1)
    {
        status = m_netpass_manager->StartSendKeepAliveToMRS(m_netpass_socket,relayTimeout);
        if(!status)
            return -3;
    }
    return 0;
}

int CMediaEngineWrapper::NetPassStopKeepAlive(int stunKeep, int remoteKeep, int relayServerKeep)
{
    bool status = false;
    if(m_netpass_manager == NULL)
    {
        m_netpass_manager = CMediaNetwork::getInstance();
    }
    if(m_netpass_socket == NULL)
    {
        MBLogError("failure:socket is NULL");
        return -1;
    }
    MBLogInfo("stunKeep=%d, remoteKeep=%d, relayServerKeep=%d",
               stunKeep, remoteKeep, relayServerKeep);
    if(stunKeep == 1)
    {
        m_netpass_manager->StopSendKeepAliveToSTUNServer(m_netpass_socket);
        
    }
    
    if(remoteKeep == 1)
    {
        m_netpass_manager->StopSendKeepAliveToRemote(m_netpass_socket);
    }
    
    if(relayServerKeep == 1)
    {
        m_netpass_manager->StopSendKeepAliveToMRS(m_netpass_socket);
    }
    return 0;
}

int CMediaEngineWrapper::NetPassDeleteSocket()
{
    if(m_netpass_manager == NULL)
    {
        m_netpass_manager = CMediaNetwork::getInstance();
    }
    if(m_netpass_socket == NULL)
    {
        MBLogError("failure:socket is NULL");
        return -1;
    }
    MBLogInfo("success.");
    m_netpass_manager->DeleteSocketSession(m_netpass_socket);
    m_netpass_socket = NULL;
    return 0;
}

int CMediaEngineWrapper::NetPassGetRelaySession(char* mrmsIp, char* mrmsPort,
                                                char* callid1,char* callid2,
                                                char* relayInfo, int& relayInfoLen,
                                                int tryTimeOut,int tryCount)
{
    if(m_netpass_manager == NULL)
    {
        m_netpass_manager = CMediaNetwork::getInstance();
    }
    if(m_netpass_socket == NULL)
    {
        MBLogError("failure:socket is NULL");
        return -1;
    }
    MBLogInfo("mrmsIp=%s,mrmsPort=%s,callid1=%s,callid2=%s.",
               mrmsIp,mrmsPort,callid1,callid2);
    
    bool ret = m_netpass_manager->CreateMediaRelaySession(m_netpass_socket,
                                                          mrmsIp,mrmsPort,callid1,callid2,tryTimeOut,tryCount);
    if(ret)
    {
        MBLogInfo("success.");
        char sessionId[NAT_INFO_MAX_ID_LEN]={0};
        char mrsIP[NAT_INFO_MAX_ID_LEN]={0};
        char port1[NAT_INFO_MAX_ID_LEN]={0};
        char port2[NAT_INFO_MAX_ID_LEN]={0};
        ret = m_netpass_manager->GetMediaRelayInfo(m_netpass_socket,sessionId,
                                                   NAT_INFO_MAX_ID_LEN,
                                                   mrsIP,
                                                   NAT_INFO_MAX_ID_LEN,
                                                   port1,
                                                   NAT_INFO_MAX_ID_LEN,
                                                   port2,
                                                   NAT_INFO_MAX_ID_LEN);
        
        if(ret)
        {
            memset(relayInfo,0x0,relayInfoLen);
            sprintf(relayInfo,"%s:%s:%s:%s",sessionId,mrsIP,port1,port2);
            relayInfoLen = strlen(relayInfo);
            
            return 0;
        }
        else
        {
            MBLogError("GetMediaRelayInfo failure.");
            return -1;
        }
    }
    else
    {
        MBLogError("CreateMediaRelaySession failure");
        return -1;
    }
    
}

int CMediaEngineWrapper::NetPassCheckRelayInfo(char *sessionId,
                                               char *mrsIP,char *mrsPort,char *callId,int tryTimeOut, int tryCount)
{
    if(m_netpass_manager == NULL)
    {
        m_netpass_manager = CMediaNetwork::getInstance();
    }
    if(m_netpass_socket == NULL)
    {
        MBLogError("failure:socket is NULL");
        return -1;
    }
    MBLogInfo("sessionId=%s,mrsIp=%s,mrsPort=%s,callId=%s.",
               sessionId,mrsIP,mrsPort,callId);
    
    bool ret = m_netpass_manager->CheckMediaRelay(m_netpass_socket,
                                                  sessionId,mrsIP,mrsPort,callId,tryTimeOut,tryCount);
    if(ret)
    {
        MBLogInfo("success.");
        return 0;
    }
    else
    {
        MBLogError("failure.");
        return -1;
    }
}

int CMediaEngineWrapper::NetPassDeleteRelaySession(char *sessionId)
{
    if(m_netpass_manager == NULL)
    {
        m_netpass_manager = CMediaNetwork::getInstance();
    }
    if(m_netpass_socket == NULL)
    {
        MBLogError("failure:socket is NULL");
        return -1;
    }
    MBLogInfo("sessionId=%s.",sessionId);
    
    bool ret = m_netpass_manager->DeleteMediaRelaySession(m_netpass_socket,
                                                          sessionId);
    if(ret)
    {
        MBLogInfo("success.");
        return 0;
    }
    else
    {
        MBLogError("failure.");
        return -1;
    }
}
#endif


/***********************************************************************************
 * nat/firewall pass functions end
 ************************************************************************************/

void CMediaEngineWrapper::setOnlyLandscape(bool bLandscape)
{
    m_bOnlyLandscape = bLandscape;
}

bool CMediaEngineWrapper::getOnlyLandscape()
{
    return m_bOnlyLandscape;
}