#ifndef MBVoIPDelegate_h
#define MBVoIPDelegate_h

#import <MBVoIP/MBVoIP.h>

typedef enum {
    MBVoIPCallStateUndefined = 0,
    MBVoIPCallStateInitialize,
    MBVoIPCallStateInvite,
    MBVoIPCallStateIncoming,
    MBVoIPCallStateProceeding,
    MBVoIPCallStateConnected,
    MBVoIPCallStateDisconnected,
    MBVoIPCallStateVideo,
}MBVoIPCallState;

typedef enum {
    MBVoIPCallTypeNone = 0,
    MBVoIPCallTypeAudio,
    MBVoIPCallTypeVideo,
}MBVoIPCallType;

@protocol MBVoIPDelegate <NSObject>

@optional

- (void)registered:(BOOL)success;
- (void)unregistered;
- (void)changedCallState:(int)callId localName:(NSString *)localName remoteDisplayName:(NSString *)remoteDisplayName remoteUserName:(NSString *)remoteUserName state:(MBVoIPCallState)state responseCode:(int)responseCode;
- (void)holded:(int)callId;
- (void)unholded:(int)callId;
// Pager Message
- (void)hasSentMessage:(BOOL)isSuccess callId:(int)callId;
- (void)hasReceivedMessage:(NSString *)message callId:(int)callId from:(NSString *)from;
- (void)hasReceivedMessage:(NSString *)message time:(NSString *)time type:(NSString *)type sender:(NSString *)sender senderId:(int)senderId receiverId:(int)receiverId messageId:(int)messageId;

@end

#endif
