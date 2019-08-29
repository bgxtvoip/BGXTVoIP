#ifndef _CMediaEngineWrapperSetting_H

#define _CMediaEngineWrapperSetting_H

#include <string.h>
#include <stdlib.h>

#import <MBVoIP/MBVoIP.h>

//#include "MediaEngine.h"
//#include "MediaEngineSetting.h"
//#include "MediaEngineEvent.h"
//#include "MediaEngineVideoDB.h"
//#include "MediaEngineUtils.h"
//#include "MBMediaConfManager.h"
//#include "MediaEngineStatistic.h"

#define MB_SET_USE_AUDIO_FEC "use_audio_fec"

#define MB_SET_SUPPORT_G711A "use_audio_g711a"
#define MB_SET_SUPPORT_G711U "use_audio_g711u"
#define MB_SET_SUPPORT_G723 "use_audio_g723"
#define MB_SET_SUPPORT_G729 "use_audio_g729"
#define MB_SET_SUPPORT_G722 "use_audio_g722"
#define MB_SET_SUPPORT_GSM "use_audio_gsm"
#define MB_SET_SUPPORT_ILBC "use_audio_ilbc"
#define MB_SET_SUPPORT_SILK "use_audio_silk"
#define MB_SET_SUPPORT_AMRNB "use_audio_amrnb"
#define MB_SET_SUPPORT_AMRWB "use_audio_amrwb"
#define MB_SET_SUPPORT_AEC  "use_audio_aec"

#define MB_SET_USE_VIDEO_FEC "use_video_fec"
#define MB_SET_USE_VIDEO_H263 "use_video_h263"
#define MB_SET_USE_VIDEO_MPEG4 "use_video_mpeg4"
#define MB_SET_USE_VIDEO_H264 "use_video_h264"
#define MB_SET_IFRAME_REQ_INTERVAL "use_video_minimum_iframe_interval"
#define MB_SET_LOCAL_VIDEO_PROFILE "use_video_local_profile_level"
#define MB_SET_IFRAME_INTERVAL	"use_video_iframe_interval"
#define MB_SET_VIDEO_PACKET		"use_video_packet"
#define MB_SET_VIDEO_QUALITY    "use_video_quality"
#define MB_SET_VIDEO_WIDTH_SCREEN  "use_video_width_screen"
#define MB_SET_VIDEO_FIX_BITRATE	"use_video_fix_video_bitrate"
#define MB_SET_VIDEO_MOTION_DETECT  "use_video_motion_detect"
#define MB_SET_VIDEO_COLOR_ENHANCE	"use_video_color_enhance"
#define MB_SET_VIDEO_SVC			"use_video_svc"
#define MB_SET_VIDEO_MAX_TARGET_BIT		"use_video_max_target_bitrate"
#define	MB_SET_VIDEO_MAX_RESOLUTION	    "use_video_max_resolution"
#define MB_SET_VIDEO_FRAMERATE		"use_video_frame_rate"

#define MB_SET_NETCHECKER		"use_ray_netchecker"
#define MB_SET_SUPPORT_P2P		"use_ray_support_p2p"
#define MB_SET_TRANSPORT_TYPE	"use_ray_transport_type"

#define MB_SET_DATA_PRESENT_TYPE	"use_data_presentation_type"
#define MB_SET_DATA_PRESENT_ENABLE	"use_data_presentation_enable"

typedef enum
{
	ME_DISPLAY_NONE = -1,
	ME_DISPLAY_CAMERA_MODE = 0,    // real camera mode
	ME_DISPLAY_BACKGROUND_MODE = 1, 
	ME_DISPLAY_P_IN_P = 2,
	ME_DISPLAY_EXTERNAL_SHOW = 3
}MediaEngine_Display_Mode;

#define MAX_LOCAL_RESOLUTION_CAPS 1280*720*3
typedef struct {
	int width;
	int height;
	int left;
	int top;
	int smallWidth;
	int smallHeight;
	int smallLeft;
	int smallTop;
	bool bFront;
}MBLayoutPosition;

typedef struct {
	int width;
	int height;
	int iframeinterval;
	int framerate;
	int bitrate;
	MediaVideoSize size;
	MediaVideoCodecPriorityType codecPriority;
	float datapercent;
}MBMediaWrapperSet;

typedef enum
{
	MB_LOCAL_REAL_TIME_VIDEO = 0,
	MB_LOCAL_DATA_PRESENTATION,
	MB_ALTERNATIVE_VIDEO_CLIP,
	MB_RECORDED_VIDEO_DATA,
	MB_REMOTE_REAL_TIME_VIDEO
}MBVideoMediaType;

typedef struct
{
	int		id;
	int		attachid;
	int		callid;
	MediaType type;
	MediaChannelDirection direction;
	MediaCodecType codecType;
	MBMediaTransportType transport;
	int		payload;
	int		iReceivedVideoSliceNum;
	bool	bHadReceivedIFrame;
	int		iReceivedVideoWidth;
	int		iReceivedVideoHeight;
	int		sendRTCPLostAccount;
	unsigned int iRequestIFrameTimeStampLast;
	unsigned int iNowRequestTimeStamp;
	unsigned int iReceivedTMMTimeStamp;
	int		streamtype;
	char	ip[20];
	unsigned short port;
	MBRTPTimeStampInfo info;
	int		lipsyncgap;
	MediaEngine_IFrameReqMethod iframetype;
}MBMediaChannelAppDefs;

namespace ios {


class CMediaEngineWrapperSetting
{
public:
    CMediaEngineWrapperSetting();
    ~CMediaEngineWrapperSetting();
	static CMediaEngineWrapperSetting* getInstance();
	static void deleteInstance();

	CMediaEngineSetting *m_mediaSetting;
	CMediaEngineVideoDB *m_mediaVideoDB;
	CMediaEngineStatistic *m_mediaStat;
	void setAECMode(int aecMode);
 	void setPlayDevice(int playMode);
	int setNSValue(int mode, int nsValue);
	int  getNSValue();
	int setAGCMode(int agcMode, int agcValue);
	int getAGCMode();
	void setSpeakerOn(int speakerOn);
	void setSpeakerSampleRate(int rate, int confrate);
	void setVad(int mode, int vadValue);
	int  getVad();
	int setCNGMode(int cngMode, int cngVadMode);
	void getCNGMode(int &cngMode, int &cngVadMode);
	float setAudioVolume(float value);
	float getAudioVolume();
	float SetMicGainAfterAECVolume(float volume);
	float GetMicGainAfterAECVolume();
	void setAudioDelayTime(int nTime);
	void SetSaveAudioDumpData(MediaEngineDumpDataType type, bool enable);
	void setOpenDumpRawData(int enable, char* path);
	float setMicrophoneGainBeforeAECVolume(float volume);
	float getMicrophoneGainBeforeAECVolume();
	void setAudioDelayTest(int bTest);
	int setAudioDelayDetectGain(int gain);
    int setAudioRecordAndTrackBufferSize(int nRecordSize, int nTrackSize);
    int setRecordDevice(int deviceId);
	int GetAudioCodecSampleRateAndTargetBit(int type,int& sample,int& bitrate);
	int SetAudioCodecSampleRateAndTargetBit(int type,int sample,int bitrate);
	int GetRestartRecordTime();
	void SetRestartRecordTime(int nSeconds);
	void SetResetPlayBufferTimeSize(int nSeconds,int nSize);
    int SetSpecVideoResolution(int width, int height);
	void setNoAudioTimeForReport(int ms);
	int getStatSpeakerVolumeGain();
	void setParamsKeyInt(int key, int value);
	int getParamsKeyInt(int key);
    int LogEnable( int enable ); 
    void SetAudioJitterBuffer(int minValue,
    		int maxValue, int maxpackets);
    void SetPlayBufferAndPLC(int firstPlayBuffSize,
    		bool bAudioEncodedThread, bool bDecoderPLC);
    void SetVideoJitterBuffer(int minValue,
    		int maxValue, int maxpackets);
    void SetVideoRTPSendInterval(int interval);
    void SetVideoNALSize(int size);
    void SetNoSendVideoUtilReceiveSPS(bool bSent);
    void SetH264ProfileLevelAndQuality(int profile, int quality);
	void setVideoParameters(char* name, char* value);
	void setVideoParametersInt(char* name, int value);
	void setAudioParameters(char* name, char* value);
	void setParamsKeyInt(int group, int key, int value);
	int getParamsKeyInt(int group, int key);

	int GetAGCPlay();
	int SetAGCPlay(int agcValue);
	int GetNSPlay();
	int SetNSPlay(int mode, int nsValue);
	int GetVADPlay();
	int SetVADPlay(int vadValue);

	MBLayoutPosition* getBigSmallViewsPos(int iScreenWidth,int iScreenHeight,
		int bigWidth, int bigHeight, int smallWidth, int smallHeight);
	MBLayoutPosition* getBigViewsPos(int iScreenWidth,int iScreenHeight,
		int bigWidth, int bigHeight);
	MBLayoutPosition* getSmallViewsPos(int iScreenWidth,int iScreenHeight,
		int smallWidth, int smallHeight);
	int currentDelayGap;
	
	/***********************************************************************************
	* utils functions start
	************************************************************************************/
	MediaChannelDirection getChannelDirection(int direction);
	MediaType getChannelMediaType(int type);
	int getCodecTypeValue(MediaCodecType type);
	MediaCodecType getMediaCodecType(int iType);
	MediaCodecType setCodecType(int iType);
	MediaCodecType m_codecType;
	MediaCodecType m_videoCodecType;
	/***********************************************************************************
	* utils functions start
	************************************************************************************/

	int getIFrameRequestInterval() {return iFrameRequestInterval;}
	int iFrameRequestInterval;
	bool bDisplayMirror;
	int i_profileLevel;
    
    int                 width;
    int                 height;
    int                 frameRate;
    MediaVideoSize      resolution;
    int                 targetBitrate;
};

}
#endif  //_CMediaEngineWrapperSetting_H

