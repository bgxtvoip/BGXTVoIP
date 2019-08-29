#include "MBClientAppEvent.h"
#include "MBVoIPDelegate.h"

static MBClientAppEvent *s_instance = NULL;
MBClientAppEvent* MBClientAppEvent::GetInstance()
{
    if (s_instance == NULL) {
        s_instance = new MBClientAppEvent;
    }
    return s_instance;
}

void MBClientAppEvent::DeleteInstance()
{
    if (s_instance != NULL) {
        delete s_instance;
        s_instance = NULL;
    }
    return;
}

//IMBClientAppEvent

MBClientAppEvent::MBClientAppEvent(void)
{
    return;
}

MBClientAppEvent::~MBClientAppEvent(void)
{
    return;
}

void MBClientAppEvent::Registered(IN bool bIsSuccess)
{
    if ([[delegate class] conformsToProtocol:@protocol(MBVoIPDelegate)]) {
        if ([delegate respondsToSelector:@selector(registered:)]) {
            [delegate registered:bIsSuccess];
        }
    }
    
    return;
}

void MBClientAppEvent::Unregistered()
{
    if ([[delegate class] conformsToProtocol:@protocol(MBVoIPDelegate)]) {
        if ([delegate respondsToSelector:@selector(unregistered)]) {
            [delegate unregistered];
        }
    }
    
    return;
}

MB_Status MBClientAppEvent::CallStateChanged(IN int callId, IN string localName, IN string remoteDisplayName, IN string remoteUserName, IN MBClientAppCallState state, IN int resCode)
{
    if ([[delegate class] conformsToProtocol:@protocol(MBVoIPDelegate)]) {
        if ([delegate respondsToSelector:@selector(changedCallState:localName:remoteDisplayName:remoteUserName:state:responseCode:)]) {
            MBVoIPCallState callState = MBVoIPCallStateUndefined;
            switch (state) {
                case MBClientAppCallStateInitialize:
                    callState = MBVoIPCallStateInitialize;
                    break;
                    
                case MBClientAppCallStateInvite:
                    callState = MBVoIPCallStateInvite;
                    break;
                    
                case MBClientAppCallStateIncoming:
                    callState = MBVoIPCallStateIncoming;
                    break;
                    
                case MBClientAppCallStateProceeding:
                    callState = MBVoIPCallStateProceeding;
                    break;
                    
                case MBClientAppCallStateConnected:
                    callState = MBVoIPCallStateConnected;
                    break;
                case MBClientAppCallStateDisconnected:
                    callState = MBVoIPCallStateDisconnected;
                    break;
                case MBClientAppCallStateVideo:
                    callState = MBVoIPCallStateVideo;
                    break;
                case MBClientAppCallStateUndefined:
                default:
                    callState = MBVoIPCallStateUndefined;
                    break;
            }
            [delegate changedCallState:callId localName:[NSString stringWithUTF8String:localName.c_str()] remoteDisplayName:[NSString stringWithUTF8String:remoteDisplayName.c_str()] remoteUserName:[NSString stringWithUTF8String:remoteUserName.c_str()] state:callState responseCode:resCode];
        }
    }
    
    return MB_STATUS_OK;
}

void MBClientAppEvent::CallRemoteHold(IN int callId)
{
    if ([[delegate class] conformsToProtocol:@protocol(MBVoIPDelegate)]) {
        if ([delegate respondsToSelector:@selector(holded:)]) {
            [delegate holded:callId];
        }
    }
    
    return;
}

void MBClientAppEvent::CallRemoteUnhold(IN int callId)
{
    if ([[delegate class] conformsToProtocol:@protocol(MBVoIPDelegate)]) {
        if ([delegate respondsToSelector:@selector(unholded:)]) {
            [delegate unholded:callId];
        }
    }
    
    return;
}

void MBClientAppEvent::GetPictureInPictureMsg()
{
    return;
}

void MBClientAppEvent::GetPictureOnlyOneMsg()
{
    return;
}

//dtmf event

void MBClientAppEvent::DtmfReceived(IN int callId,IN int dtmf,IN int duration,IN MBClientCallDTMFType type)
{
    return;
}

void MBClientAppEvent::InfoReceived(IN int callId,IN string from,IN string message)
{
    return;
}

void MBClientAppEvent::FastUpdateReceived(IN int callId)
{
    return;
}

//void MBClientAppEvent::InfoCommandReceived(IN int callId, MBRayInfoCommand command, string msg)
//{
//    return;
//}

//pager message event

void MBClientAppEvent::MessageSent(IN int callId,IN bool bIsSuccess)
{
    if ([[delegate class] conformsToProtocol:@protocol(MBVoIPDelegate)]) {
        if ([delegate respondsToSelector:@selector(hasSentMessage:callId:)]) {
            [delegate hasSentMessage:bIsSuccess callId:callId];
        }
    }
    return;
}

void MBClientAppEvent::MessageReceived(IN int callId,IN string from,IN string message)
{
    if ([[delegate class] conformsToProtocol:@protocol(MBVoIPDelegate)]) {
        if ([delegate respondsToSelector:@selector(hasReceivedMessage:callId:from:)]) {
            [delegate hasReceivedMessage:[NSString stringWithUTF8String:message.c_str()] callId:callId from:[NSString stringWithUTF8String:from.c_str()]];
        }
    }
    return;
}

void MBClientAppEvent::MessageReceived(MBMessageReceive msgData)
{
    if ([[delegate class] conformsToProtocol:@protocol(MBVoIPDelegate)]) {
        if ([delegate respondsToSelector:@selector(hasReceivedMessage:time:type:sender:senderId:receiverId:messageId:)]) {
            @try {
                NSString *message = [NSString stringWithUTF8String:msgData.content.c_str()];
                NSString *time = [NSString stringWithUTF8String:msgData.createtime.c_str()];
                NSString *type = nil;
                if (msgData.type == MSG_TEXT) {
                    type = [NSString stringWithFormat:@"message"];
                }
                NSString *sender = [NSString stringWithUTF8String:msgData.sender.c_str()];
                int senderId = msgData.senderid;
                int receiverId = msgData.receiverid;
                int messageId = msgData.messageid;
                
                [delegate hasReceivedMessage:message time:time type:type sender:sender senderId:senderId receiverId:receiverId messageId:messageId];
            }
            @catch (NSException *exception) {
                NSLog(@"exception : %@", exception.reason);
            }
            @finally {
            }
        }
    }
    return;
}

//presence

void MBClientAppEvent::NotificationReceived(MBNotifyData ntyData)
{
    return;
}

//download/upload progress

void MBClientAppEvent::UploadProgress(MBTransferProgress progress)
{
    return;
}

void MBClientAppEvent::DownloadProgress(MBTransferProgress progress)
{
    return;
}

//tcp data received
//void MBClientAppEvent::TcpDataReceived(MBTcpData data)
//{
//    return;
//}


//IMediaEngine_require_to_app_Event
void MBClientAppEvent::require_fastupdate(int channelid)
{
    return;
}

void MBClientAppEvent::change_display_resolution(int id, int width, int height)
{
    return;
}

void MBClientAppEvent::change_video_info(int id, int bitrate, int framerate, int iframeinterval)
{
    return;
}

void MBClientAppEvent::packetlost(int id, int jitter, int packetloss, int lency)
{
    return;
}

void MBClientAppEvent::noAudioData(int id)
{
    return;
}

void MBClientAppEvent::no_media_data_callback(int callid, int channelid, MediaType type, int nodatainterval)
{
    return;
}