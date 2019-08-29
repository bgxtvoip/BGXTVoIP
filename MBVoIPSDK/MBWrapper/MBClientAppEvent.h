#ifndef MBClientAppEvent_h
#define MBClientAppEvent_h

#import <MBVoIP/MBVoIP.h>
@protocol MBVoIPDelegate;

using namespace voipclient;

class MBClientAppEvent : public IMBClientAppEvent, public IMediaEngine_require_to_app_Event
{
public:
    MBClientAppEvent(void);
    ~MBClientAppEvent(void);
    
    static MBClientAppEvent *GetInstance();
    static void DeleteInstance();
    
    //IMBClientAppEvent
    virtual void Registered(IN bool bIsSuccess);
    virtual void Unregistered();
    
    virtual MB_Status CallStateChanged(IN int callId, IN string localName, IN string remoteDisplayName, IN string remoteUserName, IN MBClientAppCallState state, IN int resCode);
    virtual void CallRemoteHold(IN int callId);
    virtual void CallRemoteUnhold(IN int callId);
    
    virtual void GetPictureInPictureMsg();
    virtual void GetPictureOnlyOneMsg();
    
    //dtmf event
    virtual void DtmfReceived(IN int callId,IN int dtmf,IN int duration,IN MBClientCallDTMFType type);
    virtual void InfoReceived(IN int callId,IN string from,IN string message);
    virtual void FastUpdateReceived(IN int callId);
    //pager message event
    virtual void MessageSent(IN int callId,IN bool bIsSuccess);
    virtual void MessageReceived(IN int callId,IN string from,IN string message);
    virtual void MessageReceived(MBMessageReceive msgData);
    //presence
    virtual void NotificationReceived(MBNotifyData ntyData);
    
    //download/upload progress
    virtual void UploadProgress(MBTransferProgress progress);
    virtual void DownloadProgress(MBTransferProgress progress);
    
    //tcp data received
    //    virtual void TcpDataReceived(MBTcpData data);
    
    //IMediaEngine_require_to_app_Event
    virtual void require_fastupdate(int channelid);
    virtual void change_display_resolution(int id, int width, int height);
    virtual void change_video_info(int id, int bitrate, int framerate, int iframeinterval);
    virtual void packetlost(int id, int jitter, int packetloss, int lency);
    virtual void noAudioData(int id);
    virtual void no_media_data_callback(int callid, int channelid, MediaType type, int nodatainterval);
    
    // objective - c
    id<MBVoIPDelegate> delegate;
};

#endif
