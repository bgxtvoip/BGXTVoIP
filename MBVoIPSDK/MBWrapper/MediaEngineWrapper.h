#ifndef _CMediaEngineWrapper_H
#define _CMediaEngineWrapper_H

#include <string.h>
#include <stdlib.h>
#include "MediaEngineWrapperSetting.h"
#include "MBAudioDriver.h"
#include "MBVideoInDevice.h"
#include "MBVideoOutDevice.h"
// iOS
#import <MBVoIP/MBVoIP.h>
@protocol MBMediaEngineDelegate;

using namespace voipclient;
using namespace ios;

// CMediaEngineWrapper for media engine
class CMediaEngineWrapper : public IMediaEngineEvent
,public IMediaEngine_Media_Event
,public IMediaEngine_rtp_data_event
,public IMediaEngine_RTCP_Statistic_Envent
,public IMediaEngine_dtmf_event
,public IMediaEngine_external_transport
{
    // Construction
public:
    CMediaEngineWrapper();
    ~CMediaEngineWrapper();
    
    static CMediaEngineWrapper* getEngineWrapperInstance();
    static void deleteEngineWrapperInstance();
    
    /***********************************************************************************
     * media engine start
     ************************************************************************************/
    void CreateEngine();   // it should be called in initialization phase of application
    void DeleteEngine();   // it should be called in release application
    void setDefaultSenderParam();
    void MBSetDefaultIntoCurrentVideoParams();
    void MBSetMediaInfo(MBVideoMediaType type,MBMediaWrapperSet* value);
    void GetCurrentResolution(int &w, int &h);
    void GetCurrentRemoteResolution(int &w, int &h);
#warning working;
    //        int SetOutputChangeCB(IMB_Display_Changed_event* pOutputEv);
#warning working;
    void setCurrentLocalVideoParam(IMediaEngine_VideoParams* currentParam);
	void SetLocalVideoParameters(int bitrate,int framerate,int frameinterval,
			MediaVideoSize size,int h264profile=0x64E01E);
	void SetLocalVideoParameters(MBVideoCapableParams* param);
    void ReleaseVideoDevices();
    void ConstructDevices();
    void DestructDevices();
#warning working;
    //        void SetVideoInputDevice(MBCamera* pInput);
    //        void SetVideoOutputDevice(MBDisplay* pOutput);
#warning working;
    /***********************************************************************************
     * media engine end
     ************************************************************************************/
    
    /***********************************************************************************
     * inherited interface functions below block includes the implementation of interface
     * start
     ************************************************************************************/
    // IMediaEngineEvent
    virtual void ChannelAttach(int channelreceiveId, int channelsendId);
    virtual void ChannelCreate(int callid, int channelId, MediaType type, MediaChannelDirection direction);
	virtual void ChannelSetLocalAddress(int callid,int channelId,char *ip, unsigned short port, MediaType type);
	virtual void ChannelSetRemoteAddress(int callid,int channelId,char *ip, unsigned short port, MediaType type);
    virtual void ChannelSetPayload(int channelId,MediaType type, MediaChannelDirection direction,MediaCodecType codecType, int payload);
    virtual void ChannelRelease(int channelId, MediaType type, MediaChannelDirection direction);
    virtual void ChannelReleaseLeft(int channelId,MediaType type, MediaChannelDirection direction);
    virtual void ChannelStateChanged(int channelId, MediaEngine_Channel_State state);
	virtual void ChannelPlayFirstAudio(int channelId, int len, int sample);
    virtual void MicrophoneDataCb(char* pData, int size);
    virtual void SpeakerDataCb(char* pData,int size);
    virtual void nInfoCb(MediaEngine_InfoCodes infoCodes, int value, char* infoReason);
    virtual void nErrorCb(MediaEngine_ErrorCodes errorCodes, int value, char* errorReason, int channelId);
    virtual void nNoMediaDataCb(int callId, int channelId, MediaType type, int iNoDataInterval);
    virtual void notifyReceiveVideoFrame(int id, MediaEngine_VIDEO_FORMAT type, int width, int height,MBRTPTimeStampInfo* rtpTimeInfo);
    virtual void notifyVideoReceivePacketLost(int id, MediaEngine_VIDEO_FORMAT type, int gap);
    virtual void notifyVideoRequireFastUpdate(int id, MediaEngine_VIDEO_FORMAT type, int param, int value);
    // IMediaEngine_Media_Event
    virtual MbStatus SetMaximumBandwidth(int channelid, unsigned int bitrate);
    // require remote side to change bitrate
    virtual MbStatus RequestRemoteBitrateChanged(int channelid, unsigned int bitrate);
    virtual MbStatus RequestIFrameEv(int channelid, MediaEngine_IFrameReqMethod method);
	virtual MbStatus RequestRPSIEv(int channelid, 
							MediaEngine_IFrameReqMethod method,
							unsigned int senderssrc,			/* addressee ssrc */
							unsigned int payload,		/* payload		  */
							unsigned char* bitStr,		/* bitStr		  */
							unsigned int bitNum);
    virtual MbStatus ReceivedRTCP_TMMBR(int channelid, unsigned int maxbr,unsigned int overhead);
    virtual MbStatus ReceivedRTCP_TMMBN(int channelid, unsigned int maxbr,unsigned int overhead);
    virtual MbStatus ReceivedRTCP_XR_LossRLE(MBRTCPXRPacketParams *params);
    virtual MbStatus ReceivedRTCP_XR_DuplicatedRLE(MBRTCPXRPacketParams *params);
    virtual MbStatus ReceivedRTCP_XR_ReceiptTimes(MBRTCPXRPacketParams *params);
    virtual MbStatus ReceivedRTCP_XR_StatisticsSummary(MBRTCPXRStatisticSummaryParams *params);
    virtual MbStatus ReceivedRTCP_XR_VoipMetricsReport(MBRTCPXRVoipMetricsReportParams *params);
    
    virtual void ReceivedRTPPacket(int channelid, const char *ip, unsigned short port, char *data, int len, bool *bDiscard);
    virtual void ReceivedRTCPPacket(int channelid, const char *ip, unsigned short port, char *data, int len, bool *bDiscard);
    virtual void FinishedEv(int channelid,char* deviceid);
	virtual int RestartVideoInDevNetChecker(int channelid, int width, int height, int rate, IMediaEngine_ChannelParams* vpara);
    // IMediaEngine_rtp_data_event
    virtual void rtp_data_lost_event(int channelid, int curSeqId, int iLostNum);
    virtual void rtp_data_info(int channelid, unsigned short timestamp);
    // IMediaEngine_RTCP_Statistic_Envent
    virtual int RTCPReportEv(int channelid, MediaRTCPStatisticsInfo rtcpInfo);
	virtual int CaculateLipSync(MBRTPTimeStampInfo* audioInfo, MBRTPTimeStampInfo* videoInfo);
	virtual int FindChannel(int callid, MediaType type, MediaChannelDirection dirt);
    // IMediaEngine_dtmf_event
    virtual void rtp_rfc2833_dtmf_received(int channelid, MediaEngineRFC2833DTMF *pDTMFEvent);
    virtual void rtp_inband_dtmf_received(int channelid, MediaEngineDTMFEvent event);
    // IMediaEngine_external_transport
    //#ifdef EXTERNAL_TRANSPORT_DEMO
    virtual int SendRTPPacket(int channelid, const void *data, int len);	//success, return 0, else return negative
    virtual int SendRTCPPacket(int channelid, const void *data, int len);	//success, return 0, else return negative
	int enableLipSync;
    //#endif
    /***********************************************************************************
     * interface implementation end
     ************************************************************************************/
    
    
    /***********************************************************************************
     * register callback class into media engine functions start
     ************************************************************************************/
    void RegisterRTCPReportStatistic(int channelid,bool enable,int interval);
    void RegisterRTPDataReport(int channelid,bool enable);
    /***********************************************************************************
     * register callback class into media engine functions end
     ************************************************************************************/
    
    
    /***********************************************************************************
     * video part control functions start
     ************************************************************************************/
#ifdef MB_MEDIA_ENGINE_VIDEO_SUPPORT
    void registerAppCallback(IMediaEngine_require_to_app_Event* callback);
    void RequireSenderChannelToIFrameAsNext(int channelid);
	void RequireSenderChannelToIFrameAsNextForce(int channelid);
    int RequestIFrameEvFromSipInfo(int callid);
    void SendRawVideoData();
	char* getDisplayVideoData(int channelId,int& width, int& height,int rgbformat);
	int getDisplayVideoSize(int& width, int& height);
    void EnableRcvNetChecker(bool enable)
    {
        bSupportRcvNetChecker = enable;
        MBMediaNetCheckConfig* config = NULL;
        m_mediaSetting->GetMediaNetCheck(&config);
        config->bVideoReceiveEnable = enable;
    }
    void EnableSendNetChecker(bool enable) {bSupportSendNetChecker = enable;}
    bool bDisplayMirror;
    bool bSupportRcvNetChecker;
    bool bSupportSendNetChecker;
#endif
    /***********************************************************************************
     * video part control functions end
     ************************************************************************************/
    
    /***********************************************************************************
     * video devices control functions start
     ************************************************************************************/
#ifdef MB_WINDOWS_VIDEO_DEVICE
    int displayVideoFromExternal(unsigned char* pData, int size, int width, int height);
    void SetVideoWindows(int position,HWND hWindow);
    void ChangeDisplayHandle(HWND hWindow);
    void SetVideoInMode( MediaEngine_Display_Mode mode, int interval);
    void setCurrentVideo(BOOL pDisplayBG,BOOL bRestart);
    HWND hRemoteWindow;
    HWND hLocalWindow;
#endif
    void SetCameraID(int id);
    void SendCameraVideoData(char* pData, int size,int width, int height);
    //void setRemoteRendererSize(int dispWidth, int dispHeight);
    //void setRemoteRenderer(sp<Surface>  &surface);
    //void setRemoteHandle(void* handle);
    
    /***********************************************************************************
     * video devices control functions end
     ************************************************************************************/
    
    /***********************************************************************************
     * channel operation functions start
     ************************************************************************************/
    int getNativeChannelId(int callid, MediaType type,MediaChannelDirection direction);
    int MBCreateChannel(int callid, MediaCodecType type,MediaChannelDirection dirt,MediaPacketType packetType = MEDIA_PACKET_RTP);
    int MBGetChannelCodecType(int channelid);
    int MBSetChannelLocalPort(int channelid,int port);
    int MBSetChannelRemoteIPAndPort(int channelid,char* remoteIp,int port);
    int MBInitializeChannel(int channelid);
    int MBStartChannel(int channelid);
    int MBStopChannel(int channelid);
    int MBDeleteChannel(int channelid);
    int MBAttachChannels(int receiveChannelid, int sendChannelid);
    /***********************************************************************************
     * channel operation functions end
     ************************************************************************************/
    
    /***********************************************************************************
     * call & channel control functions start
     ************************************************************************************/
    int GetAudioSenderChannelID(int callid);
    int GetAudioReceiverChannelID(int callid);
    int MBFECEnable(int channelid, int payload, int enable);
    int MBSetFECEncoderParams(int channelid, int percent, int endPacketFec);
    int SetMute(int channelid, bool enable);
    int SendRFC2833DTMF(int callid, char dtmfValue,int duration,int payload);
    int SendInbandDTMF(int callid, char dtmfValue);
    int GetRtcpStats(int channelid,MediaRTCPStatisticsInfo& stats);
    int GetMediaStatistic(int channelid, MBMediaStatisticType type,MBMediaStatistic& stats);
    void EnableExternalReceiver(int channelid,bool enable);
    int SetExternalSender(int channelid, bool enable, IMediaEngine_external_transport* transport);
    int SetSenderVideoParams(int channelid, MediaVideoSize videoSize, int framerate, int bitrate, int frameInterval, int profilelevel);
    int SetSenderVideoParams(int channelid, int width, int height, int framerate, int bitrate, int frameInterval, int profilelevel);
    void SetVideoChannelFormat(bool bSendChannel,bool bRaw, bool bEncoded);
    int GetSenderRemoteAddress(int channelid,char *ip,unsigned short &port);
    unsigned short getLocalPort(int channelid);
#ifdef MB_SECURE_RTP_SUPPORT
	int EnableSRTP(int channelid,
							bool enable,
							MediaEngineSrtpCipherType cipherType,
							int cipherKeyLen,
							MediaEngineSrtpAuthType authType,
							int authKeyLen,
							int authTagLen,
							MediaEngineSrtpSecurityLevel securityLevel,
							char *key);
#endif
    /***********************************************************************************
     * call & channel control functions end
     ************************************************************************************/
    
    /***********************************************************************************
     * hardware engine functions start
     ************************************************************************************/
    void ConstructHWManager();
    void DestructHWManager();
    
    // int SetUseJavaAudioDevice(int iJavaAudio);
    bool bH264;
    bool bHardware;
    bool bHardwareDisplay;
	bool bExternalTransport;
    /***********************************************************************************
     * hardware engine functions end
     ************************************************************************************/
    
    /***********************************************************************************
     * utils functions start
     ************************************************************************************/
    int setCodecPayload(int iType, int payload);
    /***********************************************************************************
     * utils functions end
     ************************************************************************************/
    
    /***********************************************************************************
     * media engine version functions start
     ************************************************************************************/
    int setPhoneInfo(char* venderName, char* product, char* device,char* version);
    char* getVersionNumber();
    char* getVersionInfo();
    /***********************************************************************************
     * media engine version functions end
     ************************************************************************************/
    
    /***********************************************************************************
     * nat/firewall pass functions start
     ************************************************************************************/
    
#ifdef MEDIA_ENGINE_NATPASS_SUPPORT
    void OnDataReceived(char *buffer,int len);
    int NetPassCreateSocket(char* localIp, char* localPort);
    int NetPassGetStunPublicAdress(char* stunServer,
                                   char* stunPort, int sessionId,char* publicIpAndPort, int& publicIpAndPortLen,
                                   int tryTimeOut,int tryCount);
    int NetPassSetLocalPublicAddress(char* loPublicIp,char* loPublicPort);
    int NetPassSetRemoteAddress(char* rePrivateIp,char* rePrivatePort, char* rePublicIp, char* rePublicPort
                                ,char* mrsIp, char* mrsPort);
    int NetPassGetNATType(int tryTimeOut, int tryCount);
    int NetPassCheckPrivateAddress(int tryTimeOut, int tryCount);
    int NetPassCheckPublicAddress(int tryTimeOut, int tryCount);
    int NetPassKeepAlive(int stunKeep,int stunTimeout,
                         int remoteKeep,int remoteTimeout,
                         int relayServerKeep,int relayTimeout);
    int NetPassStopKeepAlive(int stunKeep, int remoteKeep, int relayServerKeep);
    int NetPassDeleteSocket();
    int NetPassGetRelaySession(char* mrmsIp, char* mrmsPort,
                               char* callid1,char* callid2,
                               char* relayInfo, int& relayInfoLen,
                               int tryTimeOut,int tryCount);
    int NetPassCheckRelayInfo(char *sessionId,char *mrsIP,char *mrsPort,char *callId,
                              int tryTimeOut, int tryCount);
    int NetPassDeleteRelaySession(char *sessionId);
#endif
    
    /***********************************************************************************
     * nat/firewall pass functions end
     ************************************************************************************/
    
    
    
    CMediaEngineWrapperSetting *m_mediaWrapperSetting;
    CMediaEngine *m_mediaEngine;
    CMediaEngineSetting *m_mediaSetting;
    CMediaEngineVideoDB *m_mediaVideoDB;
    CMediaEngineStatistic *m_mediaStat;
    CMediaEngineUtils *m_mediaUtils;
    CMBMediaConfManager* pMediaManager;
    IMediaConf* pConf;
    IHostParticipant* pLocalParty;
    MBAudioDriver m_audioDriver;
#warning working;
    //        MBDisplay *m_display;
    //        MBCamera *m_camera;
#warning working;
    int cameraId;
    
    IMediaEngine_require_to_app_Event* appCallbackCB;
#warning working;
    //        IMB_Display_Changed_event* pfnRemoteVideoChangeCB;
#warning working;
    IMediaEngine_VideoParams localVideoParams;
    IMediaEngine_VideoParams localDataParams;
    IMediaEngine_VideoParams currentVideoParams;
    
    MBMediaChannelAppDefs channels[MB_TOTAL_CHANNEL_NUM];
    
    int bStart;
    int bVideoChannelRun;
    
#warning working;
    // renewal
    MBVideoInDevice *m_pVideoInDevice;
    MBVideoOutDevice *m_pVideoOutDevice;
    id <MBMediaEngineDelegate> delegate;
#warning working;

    void setOnlyLandscape(bool bLandscape);
    bool getOnlyLandscape();

    bool m_bOnlyLandscape;
};



#endif //_CMediaEngineWrapper_H
