#include <stdio.h>
#include "MediaEngineWrapperSetting.h"
//#include "MediaEngineEvent.h"
#include "MediaEngineWrapperLog.h"
#define MBLOGGER MediaEngineWrapperLog::MEDIAENGINEDEVICE

namespace ios {


static CMediaEngineWrapperSetting* instance = NULL;

CMediaEngineWrapperSetting::CMediaEngineWrapperSetting()
{
	iFrameRequestInterval = 1000;
	m_mediaSetting = CMediaEngineSetting::getInstance();
	m_mediaVideoDB = CMediaEngineVideoDB::getInstance();
	m_mediaStat = CMediaEngineStatistic::getInstance();
	setAudioParameters(MB_SET_USE_AUDIO_FEC,"false");
	setAudioParameters(MB_SET_SUPPORT_SILK,"true");
	setAudioParameters(MB_SET_SUPPORT_G711A,"true");
	setAudioParameters(MB_SET_SUPPORT_G723,"true");
	setAudioParameters(MB_SET_SUPPORT_G729,"true");
	setAudioParameters(MB_SET_SUPPORT_AMRNB,"true");

	setVideoParameters(MB_SET_USE_VIDEO_FEC,"false");
	setVideoParametersInt(MB_SET_IFRAME_REQ_INTERVAL,500);

	m_codecType = MEDIA_CODEC_G711_PCMU;
	bDisplayMirror = false;
	m_videoCodecType = MEDIA_CODEC_H264;



	
}
CMediaEngineWrapperSetting::~CMediaEngineWrapperSetting()
{
	m_mediaSetting = NULL;
}

CMediaEngineWrapperSetting* CMediaEngineWrapperSetting::getInstance()
{
	if(instance == NULL)
		instance = new CMediaEngineWrapperSetting();
	return instance;
}

void CMediaEngineWrapperSetting::deleteInstance()
{
	if(instance != NULL)
	{
		delete(instance);
	}
	instance = NULL;
}

void CMediaEngineWrapperSetting::setAECMode(int aecMode)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));

	switch(aecMode)
	{
		case 0:
			paramImmData->immParams.aecMode = MEDIA_ALGO_DISABLE;
			break;
		case 1:
			paramImmData->immParams.aecMode = MEDIA_AEC_DEFAULT;
			paramImmData->immParams.aesMode = MEDIA_ALGO_DISABLE;
			break;
		case 2:
			paramImmData->immParams.aecMode = MEDIA_AEC_GOOD;
			paramImmData->immParams.aesMode = MEDIA_ALGO_DISABLE;
			break;
		case 3:
			paramImmData->immParams.aecMode = MEDIA_AEC_EXTRA;
			paramImmData->immParams.aesMode = MEDIA_ALGO_DISABLE;
			break;
		case 4:
			paramImmData->immParams.aecMode = MEDIA_AEC_EX_MOBILE;
			paramImmData->immParams.aesMode = MEDIA_ALGO_DISABLE;
			break;
		case 5:
			paramImmData->immParams.aecMode = MEDIA_ALGO_DISABLE;
			paramImmData->immParams.aesMode = MEDIA_AES_DEFAULT;
			break;
		case 6:
			paramImmData->immParams.aecMode = MEDIA_ALGO_DISABLE;
			paramImmData->immParams.aesMode = MEDIA_AES_GOOD;
			break;
		default:
			break;
			
	}
	m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS, *paramImmData);
}



int CMediaEngineWrapperSetting::setNSValue(int mode, int nsValue)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	paramImmData->immParams.iNsMode = mode;
	paramImmData->immParams.iNsValue = nsValue;
	m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS, *paramImmData);
	return 0;
}

int CMediaEngineWrapperSetting::getNSValue()
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	return paramImmData->immParams.iNsValue;
//	return m_mediaSetting->getNSMode();
}

int CMediaEngineWrapperSetting::setAGCMode(int agcMode, int agcValue)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	
	
	if(agcValue == 0)
	{
		paramImmData->immParams.iAgcMode = 0;
		paramImmData->immParams.iAgcValue = 0;
	}
	else
	{
		paramImmData->immParams.iAgcMode = agcMode;
		paramImmData->immParams.iAgcValue = agcValue;
	}
	m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS, *paramImmData);
	return 0;
}

int CMediaEngineWrapperSetting::getAGCMode()
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	return paramImmData->immParams.iAgcValue;
//	return m_mediaSetting->getAGCValue();
}

int CMediaEngineWrapperSetting::setCNGMode(int cngMode, int cngVadMode)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	paramImmData->immParams.bCngMode = cngMode == 0? false: true;
	paramImmData->immParams.bVadCngMode = cngVadMode == 0? false: true;
	m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS, *paramImmData);
	return 0;
}

void CMediaEngineWrapperSetting::getCNGMode(int &cngMode, int &cngVadMode)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	cngMode = paramImmData->immParams.bCngMode? 1: 0;
	cngVadMode = paramImmData->immParams.bVadCngMode? 1: 0;
}

void CMediaEngineWrapperSetting::setPlayDevice(int playMode)
{
	SET_PARAMS_DATA *paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
	//m_mediaSetting->setPlayDevice(playMode);
	paramPreData->preParams.iPlayDevId = playMode;
	m_mediaSetting->setParamsKey(ME_PRECONDITION_PARAMS,*paramPreData);
}

void CMediaEngineWrapperSetting::setVad(int mode, int vadValue)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	paramImmData->immParams.iVadMode = mode;
	paramImmData->immParams.iVadValue = vadValue;
//	m_mediaSetting->setVad(vadValue);
	m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS, *paramImmData);
}

int CMediaEngineWrapperSetting::getVad()
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	return paramImmData->immParams.iVadValue;
	//return m_mediaSetting->getVad();
}


void CMediaEngineWrapperSetting::setAudioDelayTime(int nTime)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	paramImmData->immParams.iDelayTime = nTime;
	m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS, *paramImmData);
	//m_mediaSetting->setAudioDelayTime(nTime);
}

void CMediaEngineWrapperSetting::setAudioDelayTest(int bTest)
{
	m_mediaSetting->setAudioDelayTest(bTest,false,'0');
}

int CMediaEngineWrapperSetting::setAudioDelayDetectGain(int gain)
{
	return m_mediaSetting->setAudioDelayDetectGain(gain);
}


void CMediaEngineWrapperSetting::setSpeakerOn(int speakerOn)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_RUNTIME_PARAMS));
	paramImmData->runParams.iSpeakerOn = speakerOn;
	paramImmData->runParams.nSpeakerSwitchSet = 1;
	m_mediaSetting->setParamsKey(ME_RUNTIME_PARAMS, *paramImmData);
	
//	m_mediaSetting->setSpeakerOn(speakerOn);
}

void CMediaEngineWrapperSetting::setSpeakerSampleRate(int rate, int confrate)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	paramImmData->immParams.iSampleRate = rate;
    paramImmData->immParams.iAudioSampleInConf = confrate;
	m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS, *paramImmData);
	
//	m_mediaSetting->setSpeakerSampleRate(rate);
}

int CMediaEngineWrapperSetting::setAudioRecordAndTrackBufferSize(int nRecordSize, int nTrackSize)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	paramImmData->immParams.iRecordSize = nRecordSize;
	paramImmData->immParams.iTrackSize = nTrackSize;
	m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS, *paramImmData);
	return 0;
//	return m_mediaSetting->setAudioRecordAndTrackBufferSize(nRecordSize, nTrackSize);
}

int CMediaEngineWrapperSetting::setRecordDevice(int deviceId)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
	paramImmData->preParams.iRecordDevId = deviceId;
	m_mediaSetting->setParamsKey(ME_PRECONDITION_PARAMS, *paramImmData);
	return 0;
//	return m_mediaSetting->setRecordDevice(deviceId);
}

float CMediaEngineWrapperSetting::setAudioVolume(float value)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_RUNTIME_PARAMS));
	paramImmData->runParams.fAudioVolume = value;
	m_mediaSetting->setParamsKey(ME_RUNTIME_PARAMS, *paramImmData);
	return value;
	//return m_mediaSetting->setAudioVolume(value);
}
float CMediaEngineWrapperSetting::getAudioVolume()
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_RUNTIME_PARAMS));
	return paramImmData->runParams.fAudioVolume;
//	return m_mediaSetting->getAudioVolume();
}


float CMediaEngineWrapperSetting::SetMicGainAfterAECVolume(float volume)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_RUNTIME_PARAMS));
	paramImmData->runParams.fMicAftAecVolume = volume;
	m_mediaSetting->setParamsKey(ME_RUNTIME_PARAMS, *paramImmData);
	return paramImmData->runParams.fMicAftAecVolume;
	//return m_mediaSetting->setMicrophoneGainAfterAEC(volume);
}

float CMediaEngineWrapperSetting::GetMicGainAfterAECVolume()
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_RUNTIME_PARAMS));
	return paramImmData->runParams.fMicAftAecVolume;
//	return m_mediaSetting->getMicrophoneGainAfterAEC();
}

void CMediaEngineWrapperSetting::SetSaveAudioDumpData(MediaEngineDumpDataType type, bool enable)
{
	m_mediaSetting->SetSaveAudioDumpData(type,enable);
}

void CMediaEngineWrapperSetting::setOpenDumpRawData(int enable, char* path)
{
	if(enable == 1)
	{
		if(path == NULL)
			m_mediaSetting->setAudioRawDataDump(true,(char*)"/mnt/sdcard/raw",11);
		else
			m_mediaSetting->setAudioRawDataDump(true,(char*)path,11);
	}
	else
	{
		if(path == NULL)
			m_mediaSetting->setAudioRawDataDump(false,(char*)"/mnt/sdcard/raw",11);
		else
			m_mediaSetting->setAudioRawDataDump(false,(char*)path,11);
	}
}

float CMediaEngineWrapperSetting::setMicrophoneGainBeforeAECVolume(float volume)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_RUNTIME_PARAMS));
	paramImmData->runParams.fMicBefAecVolume = volume;
	m_mediaSetting->setParamsKey(ME_RUNTIME_PARAMS, *paramImmData);
	return paramImmData->runParams.fMicBefAecVolume;
	
	//return m_mediaSetting->setMicrophoneGainBeforeAECVolume(volume);
}

float CMediaEngineWrapperSetting::getMicrophoneGainBeforeAECVolume()
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_RUNTIME_PARAMS));
	return paramImmData->runParams.fMicBefAecVolume;
	//return m_mediaSetting->getMicrophoneGainBeforeAECVolume();
}

int CMediaEngineWrapperSetting::GetAudioCodecSampleRateAndTargetBit(int type,int& sample,int& bitrate)
{
	MediaCodecType codecT = getMediaCodecType(type);
	return m_mediaSetting->getAudioCodecParameters(codecT,sample,bitrate);
}

int CMediaEngineWrapperSetting::SetAudioCodecSampleRateAndTargetBit(int type,int sample,int bitrate)
{
	MediaCodecType codecT = getMediaCodecType(type);
	return m_mediaSetting->setAudioCodecParameters(codecT,sample,bitrate);
}


int CMediaEngineWrapperSetting::GetRestartRecordTime()
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	return paramImmData->immParams.iRestartRecTime;
	//return m_mediaSetting->getRestartRecordTime();
}

void CMediaEngineWrapperSetting::SetRestartRecordTime(int nSeconds)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	paramImmData->immParams.iRestartRecTime = nSeconds;
	m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS, *paramImmData);
	//m_mediaSetting->setRestartRecordTime(nSeconds);
}

void CMediaEngineWrapperSetting::SetResetPlayBufferTimeSize(int nSeconds,int nSize)
{

	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	paramImmData->immParams.iRestartPlayTime = nSeconds;
	paramImmData->immParams.iRestartPlayLimitSize = nSize;
	m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS, *paramImmData);
	//m_mediaSetting->setResetPlayBufferTimeSize(nSeconds,nSize);
}

int CMediaEngineWrapperSetting::SetSpecVideoResolution(int width, int height) {
    return m_mediaSetting->setSpecVideoResolution(width, height);
}

void CMediaEngineWrapperSetting::setNoAudioTimeForReport(int ms)
{
	//m_mediaSetting->setNoAudioTimeForReport(ms);
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	paramImmData->immParams.iNoMediaNotifyTime = ms;
	m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS,*paramImmData);
}
int CMediaEngineWrapperSetting::getStatSpeakerVolumeGain()
{
	return m_mediaStat->getSpeakerVolumeGain();
}

int CMediaEngineWrapperSetting::LogEnable( int enable ) {
    if (m_mediaSetting == NULL) return -1;
    return m_mediaSetting->setLogEnable(enable==1?true:false);        
}

void CMediaEngineWrapperSetting::SetAudioJitterBuffer(int minValue,
		int maxValue, int maxpackets)
{
	SET_PARAMS_DATA *paramPreData = NULL;
	paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
	paramPreData->preParams.iAMinAJBSize = minValue;  // minum video jitter buffer size (unit: ms time)
	paramPreData->preParams.iAMaxAJBSize = maxValue;  // maximum video jitter buffer size(unit: ms time)
	if(maxpackets > 0)
	paramPreData->preParams.iAMaxCirclePackets = maxpackets; // maximum video rtp number (unit: number)
	m_mediaSetting->setParamsKey(ME_PRECONDITION_PARAMS,*paramPreData);
}

void CMediaEngineWrapperSetting::SetPlayBufferAndPLC(int firstPlayBuffSize,
		bool bAudioEncodedThread, bool bDecoderPLC)
{
	SET_PARAMS_DATA *paramPreData = NULL;
	paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
	paramPreData->preParams.iFirstBuffSize = firstPlayBuffSize; // wave play buffer size(unit: bytes)
	m_mediaSetting->setParamsKey(ME_PRECONDITION_PARAMS,*paramPreData);

	SET_PARAMS_DATA *paramImmData = NULL;
	paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	paramImmData->immParams.bDecPLC = bDecoderPLC;
	paramImmData->immParams.bUseAudioEncThread = bAudioEncodedThread;
	m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS,*paramImmData);
}

void CMediaEngineWrapperSetting::SetVideoJitterBuffer(int minValue,
		int maxValue, int maxpackets)
{
	SET_PARAMS_DATA *paramPreData = NULL;
	paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
	paramPreData->preParams.iVMinAJBSize = minValue;  // minum video jitter buffer size (unit: ms time)
	paramPreData->preParams.iVMaxAJBSize = maxValue;  // maximum video jitter buffer size(unit: ms time)
	if(maxpackets > 0)
		paramPreData->preParams.iVMaxCirclePackets = maxpackets; // maximum video rtp number (unit: number)
	m_mediaSetting->setParamsKey(ME_PRECONDITION_PARAMS,*paramPreData);
}

void CMediaEngineWrapperSetting::SetVideoRTPSendInterval(int interval)
{
	SET_PARAMS_DATA *paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
	paramPreData->preParams.iRtpInterval =	interval;
	m_mediaSetting->setParamsKey(ME_PRECONDITION_PARAMS,*paramPreData);
}

void CMediaEngineWrapperSetting::SetVideoNALSize(int size)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	paramImmData->immParams.iH264NalSize = size;
	m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS,*paramImmData);
}

void CMediaEngineWrapperSetting::SetNoSendVideoUtilReceiveSPS(bool bSent)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	paramImmData->immParams.bNoSendRtpBeforeRecvSps = bSent;
	m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS,*paramImmData);
}

void CMediaEngineWrapperSetting::SetH264ProfileLevelAndQuality(int profile, int quality)
{
	if(profile > 0)
		i_profileLevel = profile;
	if(quality >= 0)
	{
		SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
		paramImmData->immParams.iVideoQuality = quality;
		m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS,*paramImmData);
	}
}

// set int key parameters, value will be for int or bool;
void CMediaEngineWrapperSetting::setParamsKeyInt(int key, int value)
{
	bool	boolValue = true;
	if(value == 0)
	{
		boolValue = false;
	}
	SET_PARAMS_DATA *paramImmData = NULL;
	SET_PARAMS_DATA *paramPreData = NULL;
	switch(key)
	{
		case ME_Params_Voice_AJB_MIN_BUFF:
			paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
			paramPreData->preParams.iAMinAJBSize = value;  // minum video jitter buffer size (unit: ms time)
			m_mediaSetting->setParamsKey(ME_PRECONDITION_PARAMS,*paramPreData);
			break;
		case ME_Params_Voice_AJB_MAX_BUFF:
			paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
			paramPreData->preParams.iAMaxAJBSize = value;		// maximum video jitter buffer size(unit: ms time)
			m_mediaSetting->setParamsKey(ME_PRECONDITION_PARAMS,*paramPreData);
			break;
		case ME_Params_Voice_AJB_MAX_PACKETS:
			paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
			paramPreData->preParams.iAMaxCirclePackets = value; // maximum video rtp number (unit: number)
			m_mediaSetting->setParamsKey(ME_PRECONDITION_PARAMS,*paramPreData);
			break;
		case ME_Params_Voice_WAVE_PLAY_FIRST_BUFF_SIZE:
			paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
			paramPreData->preParams.iFirstBuffSize = value; // wave play buffer size(unit: bytes)
			m_mediaSetting->setParamsKey(ME_PRECONDITION_PARAMS,*paramPreData);
			break;
		case ME_Params_Voice_Generic_Decode_PLC:
			paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
			paramImmData->immParams.bDecPLC = boolValue;
			m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS,*paramImmData);
			break;
		case ME_Params_No_Run_Audio_Resource:
		//	term->cfg.iNonAudio = bValue;
			break;
		case ME_Params_Voice_Use_Encode_Thread:
			paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
			paramImmData->immParams.bUseAudioEncThread = boolValue;
			m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS,*paramImmData);
			break;
#ifdef MEDIA_ENGINE_VIDEO			
		case ME_Params_Video_AJB_MIN_BUFF:
			// video buffer
			paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
			paramPreData->preParams.iVMinAJBSize = value;		// minum video jitter buffer size (unit: ms time)
			m_mediaSetting->setParamsKey(ME_PRECONDITION_PARAMS,*paramPreData);
			break;
		case ME_Params_Video_AJB_MAX_BUFF:
			paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
			paramPreData->preParams.iVMaxAJBSize = value;		// maximum video jitter buffer size(unit: ms time)
			m_mediaSetting->setParamsKey(ME_PRECONDITION_PARAMS,*paramPreData);
			break;
		case ME_Params_Video_AJB_MAX_PACKETS:
			paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
			paramPreData->preParams.iVMaxCirclePackets = value; // maximum video rtp number (unit: number)
			m_mediaSetting->setParamsKey(ME_PRECONDITION_PARAMS,*paramPreData);
			break;	
		case ME_Params_Video_NAL_SIZE:
			paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
			paramImmData->immParams.iH264NalSize = value;
			m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS,*paramImmData);
			break;
		case ME_Params_Video_SEND_SLEEP:
			paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
			paramPreData->preParams.iRtpInterval =	value;
			m_mediaSetting->setParamsKey(ME_PRECONDITION_PARAMS,*paramPreData);
			break;
		case ME_Params_Video_NO_SEND_VIDEO_DATA_UTILS_RECEIVE_SPS:
			paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
			paramImmData->immParams.bNoSendRtpBeforeRecvSps = boolValue;
			m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS,*paramImmData);
			break;
		case ME_Params_Local_Video_Profile_Level:
			i_profileLevel = value;
			break;
		case ME_Params_Local_Video_Quality:
			paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
			paramImmData->immParams.iVideoQuality = value;
			m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS,*paramImmData);
			break;
#endif
		default:
			break;
	}
	
	
/*	{
		m_mediaSetting->setParamsKeyInt(key,value);
	} */
}

int CMediaEngineWrapperSetting::getParamsKeyInt(int key)
{
	SET_PARAMS_DATA *paramImmData = NULL;
	SET_PARAMS_DATA *paramPreData = NULL;
	switch(key)
	{
		case ME_Params_Voice_AJB_MIN_BUFF:
			// audio buffer
			paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
			return paramPreData->preParams.iAMinAJBSize;		// minum video jitter buffer size (unit: ms time)
		case ME_Params_Voice_AJB_MAX_BUFF:
			paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
			return paramPreData->preParams.iAMaxAJBSize;		// maximum video jitter buffer size(unit: ms time)
		case ME_Params_Voice_AJB_MAX_PACKETS:
			paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
			return paramPreData->preParams.iAMaxCirclePackets ; // maximum video rtp number (unit: number)
		case ME_Params_Voice_WAVE_PLAY_FIRST_BUFF_SIZE:
			paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
			return paramPreData->preParams.iFirstBuffSize; // wave play buffer size(unit: bytes)
		case ME_Params_Voice_Generic_Decode_PLC:
			paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
			return paramImmData->immParams.bDecPLC;
		case ME_Params_Voice_Use_Encode_Thread:
			paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
			return paramImmData->immParams.bUseAudioEncThread?1:0;
#ifdef MEDIA_ENGINE_VIDEO			
		case ME_Params_Video_AJB_MIN_BUFF:
			// video buffer
			paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
			return paramPreData->preParams.iVMinAJBSize;		// minum video jitter buffer size (unit: ms time)
		case ME_Params_Video_AJB_MAX_BUFF:
			paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
			return paramPreData->preParams.iVMaxAJBSize;		// maximum video jitter buffer size(unit: ms time)
		case ME_Params_Video_AJB_MAX_PACKETS:
			paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
			return paramPreData->preParams.iVMaxCirclePackets; // maximum video rtp number (unit: number)	
		case ME_Params_Video_NAL_SIZE:
			paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
			return paramImmData->immParams.iH264NalSize ;
		case ME_Params_Video_SEND_SLEEP:
			paramPreData = &(m_mediaSetting->getParamsKey(ME_PRECONDITION_PARAMS));
			return paramPreData->preParams.iRtpInterval;
		case ME_Params_Video_NO_SEND_VIDEO_DATA_UTILS_RECEIVE_SPS:
			paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
			return paramImmData->immParams.bNoSendRtpBeforeRecvSps;
		case ME_Params_Local_Video_Profile_Level:
			return i_profileLevel;
		case ME_Params_Local_Video_Quality:
			paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
			return paramImmData->immParams.iVideoQuality;
#endif
		default:
			break;
	}
	return -1;
/*	{
		return m_mediaSetting->getParamsKeyInt(key);
	}
	return -1; */
}

void CMediaEngineWrapperSetting::setVideoParameters(char* name, char* value)
{
	if(strcmp(name,MB_SET_USE_VIDEO_FEC) == 0)
	{
		bool bFec = CMediaEngineUtils::GetBoolType(value);
		SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
		paramImmData->immParams.bVideoFEC = bFec;
		paramImmData->immParams.iVideoFECPayload = 111;
		m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS, *paramImmData);
		//m_mediaSetting->setVideoFEC(bFec,111);
	}
	else
	{
		m_mediaVideoDB->setParameters(name,value);
	}
	//m_mediaSetting->setAudioFEC(false,111);
	
	
}

void CMediaEngineWrapperSetting::setVideoParametersInt(char* name, int value)
{
	if(strcmp(name,MB_SET_IFRAME_REQ_INTERVAL) == 0)
	{
		iFrameRequestInterval = value;
		MBLogInfo("use_video_minimum_iframe_interval=%d.",value);
	}
	else
		m_mediaVideoDB->setParametersInt(name,value);
}

int CMediaEngineWrapperSetting::GetAGCPlay()
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	return paramImmData->immParams.iAgcValueInPlay;
}

int CMediaEngineWrapperSetting::SetAGCPlay(int agcValue)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	paramImmData->immParams.iAgcValueInPlay = agcValue;
	m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS, *paramImmData);
	return 0;
}
int CMediaEngineWrapperSetting::GetNSPlay()
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	return paramImmData->immParams.iNsValueInPlay;
}
int CMediaEngineWrapperSetting::SetNSPlay(int mode, int nsValue)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	paramImmData->immParams.iNsModeInPlay = mode;
	paramImmData->immParams.iNsValueInPlay = nsValue;
	m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS, *paramImmData);
	return 0;
}
int CMediaEngineWrapperSetting::GetVADPlay()
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	return paramImmData->immParams.iVadValueInPlay;
}
int CMediaEngineWrapperSetting::SetVADPlay(int vadValue)
{
	SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
	paramImmData->immParams.iVadValueInPlay = vadValue;
	m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS, *paramImmData);
	return 0;
}

void CMediaEngineWrapperSetting::setAudioParameters(char* name, char* value)
{
	if(strcmp(name,"use_audio_fec") == 0)
	{
		bool bFec = CMediaEngineUtils::GetBoolType(value);
		SET_PARAMS_DATA *paramImmData = &(m_mediaSetting->getParamsKey(ME_IMMEDIATE_PARAMS));
		paramImmData->immParams.bAudioFEC = bFec;
		paramImmData->immParams.iAudioFECPayload = 111;
		m_mediaSetting->setParamsKey(ME_IMMEDIATE_PARAMS, *paramImmData);
		//m_mediaSetting->setAudioFEC(bFec,111);
	}
/*	else if(strcmp(name,MB_SET_SUPPORT_SILK) == 0)
	{
		bool bCodec = CMediaEngineUtils::GetBoolType(value);
		if(bCodec)
			m_mediaSetting->addAudioCodecAndPayloadList(MEDIA_CODEC_SILK,
					m_AudioCodecTypeAndPayload[10][1]);
	}
	else if(strcmp(name,MB_SET_SUPPORT_G711A) == 0)
	{
		bool bCodec = CMediaEngineUtils::GetBoolType(value);
		if(bCodec)
		{
			m_mediaSetting->addAudioCodecAndPayloadList(MEDIA_CODEC_G711_PCMU,
					m_AudioCodecTypeAndPayload[0][1]);
			m_mediaSetting->addAudioCodecAndPayloadList(MEDIA_CODEC_G711_PCMA,
					m_AudioCodecTypeAndPayload[1][1]);
		}
	}
	else if(strcmp(name,MB_SET_SUPPORT_G723) == 0)
	{
		bool bCodec = CMediaEngineUtils::GetBoolType(value);
		if(bCodec)
			m_mediaSetting->addAudioCodecAndPayloadList(MEDIA_CODEC_G7231,
					m_AudioCodecTypeAndPayload[3][1]);
	}
	else if(strcmp(name,MB_SET_SUPPORT_G729) == 0)
	{
		bool bCodec = CMediaEngineUtils::GetBoolType(value);
		if(bCodec)
			m_mediaSetting->addAudioCodecAndPayloadList(MEDIA_CODEC_G729,
					m_AudioCodecTypeAndPayload[2][1]);
	}
	else if(strcmp(name,MB_SET_SUPPORT_AMRNB) == 0)
	{
		bool bCodec = CMediaEngineUtils::GetBoolType(value);
		if(bCodec)
			m_mediaSetting->addAudioCodecAndPayloadList(MEDIA_CODEC_AMR_NB,
					m_AudioCodecTypeAndPayload[5][1]);
	}
*/
}

// set int key parameters, value will be for int or bool;
	void CMediaEngineWrapperSetting::setParamsKeyInt(int group, int key, int value)
	{

		if(key == ME_Params_Video_Display_Mirror)
		{
			bDisplayMirror = (value == 1)?true:false;
		}
		else 
		{
			//m_mediaSetting->setParamsKeyInt(key,value);
		}
	}

	int CMediaEngineWrapperSetting::getParamsKeyInt(int group, int key)
	{
		return 0;
		//return m_mediaSetting->getParamsKeyInt(key);
		
	}


	
    
	MBLayoutPosition pos;
	MBLayoutPosition* CMediaEngineWrapperSetting::getBigSmallViewsPos(int iScreenWidth,int iScreenHeight,
			int bigWidth, int bigHeight, int smallWidth, int smallHeight)
	{
		memset(&pos,0x0,sizeof(MBLayoutPosition));
		int w = bigWidth;
		int h = bigHeight;
		
		
		{
			pos.width = iScreenWidth;
			pos.height = iScreenWidth*h/w;
			pos.left = 0;
			pos.top = 0;
			if(pos.height > iScreenHeight)
			{   
				pos.height = iScreenHeight;
				pos.width = pos.height * w/ h;
				pos.left = (iScreenWidth - pos.width)/2;
			}
			else
			{
				pos.top = (iScreenHeight - pos.height)/2;
				
			}

			w = smallWidth/16;
			h = smallHeight/16;
			pos.smallLeft = 0;
			pos.smallWidth = iScreenWidth/4;
			pos.smallHeight = pos.smallWidth*h/w;
			pos.smallTop = 0;
		}
		return &pos;
	}

	MBLayoutPosition* CMediaEngineWrapperSetting::getBigViewsPos(int iScreenWidth,int iScreenHeight,
		int bigWidth, int bigHeight)
	{
		memset(&pos,0x0,sizeof(MBLayoutPosition));
		int w = bigWidth;
		int h = bigHeight;


		{
			pos.width = iScreenWidth;
			pos.height = iScreenWidth*h/w;
			pos.left = 0;
			pos.top = 0;
			if(pos.height > iScreenHeight)
			{   
				pos.height = iScreenHeight;
				pos.width = pos.height * w/ h;
				pos.left = (iScreenWidth - pos.width)/2;
			}
			else
			{
				pos.top = (iScreenHeight - pos.height)/2;

			}

			
		}
		return &pos;
	}

	MBLayoutPosition* CMediaEngineWrapperSetting::getSmallViewsPos(int iScreenWidth,int iScreenHeight,
		int smallWidth, int smallHeight)
	{
		memset(&pos,0x0,sizeof(MBLayoutPosition));
		{
			
			int w = smallWidth/16;
			int h = smallHeight/16;
			pos.smallLeft = 10;
			pos.smallWidth = iScreenWidth/4;
			pos.smallHeight = pos.smallWidth*h/w;
			pos.smallTop = 10;
		}
		return &pos;
	}


	/***********************************************************************************
	* utils functions start
	************************************************************************************/
	MediaChannelDirection CMediaEngineWrapperSetting::getChannelDirection(int direction)
	{
		if(direction == 0)
			return MEDIA_CHANNEL_RECEIVER;
		else
			return MEDIA_CHANNEL_SENDER;
	}

	MediaType CMediaEngineWrapperSetting::getChannelMediaType(int type)
	{
		if(type == 0)
			return MEDIA_TYPE_AUDIO;
		else if(type == 1)
			return MEDIA_TYPE_VIDEO;
		else if(type == 2)
			return MEDIA_TYPE_VIDEO_DATA;
		return MEDIA_TYPE_UNKNOWN;
	}

	int CMediaEngineWrapperSetting::getCodecTypeValue(MediaCodecType type)
	{
		switch(type)
		{
		case MEDIA_CODEC_G711_PCMU:
			return 0;
		case MEDIA_CODEC_G711_PCMA:
			return 1;
		case MEDIA_CODEC_G729:
			return 2;
		case MEDIA_CODEC_G7231:
			return 3;
		case MEDIA_CODEC_AMR_NB:
			return 4;
		case MEDIA_CODEC_AMR_WB:
			return 5;
		case MEDIA_CODEC_AAC:
			return 6;
		case MEDIA_CODEC_PCM_WB:
			return 7;
		case MEDIA_CODEC_iLBC:
			return 8;
		case MEDIA_CODEC_SILK:
			return 9;
		case MEDIA_CODEC_GSM:
			return 10;
		case MEDIA_CODEC_G722:
			return 11;
#ifdef MEDIA_ENGINE_VIDEO
		case MEDIA_CODEC_H263:
			return 12;
		case MEDIA_CODEC_MPEG4:
			return 13;
		case MEDIA_CODEC_H264:
			return 14;
#endif
		default:
			return -1;
		}
	}

	MediaCodecType CMediaEngineWrapperSetting::getMediaCodecType(int iType)
	{
		MediaCodecType type = MEDIA_CODEC_G711_PCMU;
		switch(iType)
		{
		case 0:
			type = MEDIA_CODEC_G711_PCMU;
			break;
		case 1:
			type = MEDIA_CODEC_G711_PCMA;
			break;
		case 2:
			type = MEDIA_CODEC_G729;
			break;
		case 3:
			type = MEDIA_CODEC_G7231;
			break;
		case 4:
			type = MEDIA_CODEC_AMR_NB;
			break;
		case 5:
			type = MEDIA_CODEC_AMR_WB;
			break;
		case 6:
			type = MEDIA_CODEC_AAC;
			break;
		case 7:
			type = MEDIA_CODEC_PCM_WB;
			break;
		case 8:
			type = MEDIA_CODEC_iLBC;
			break;
		case 9:
			type = MEDIA_CODEC_SILK;
			break;
		case 10:
			type = MEDIA_CODEC_GSM;
			break;
		case 11:
			type = MEDIA_CODEC_G722;
			break;

#ifdef MEDIA_ENGINE_VIDEO

		case 12:
			type = MEDIA_CODEC_H263;
			return type;
		case 13:
			type = MEDIA_CODEC_MPEG4;
			return type;
		case 14:
			type = MEDIA_CODEC_H264;
			return type;
#endif
		default:
			type = MEDIA_CODEC_G711_PCMU;
			break;

		}
		return type;
	}


	MediaCodecType CMediaEngineWrapperSetting::setCodecType(int iType)
	{
		switch(iType)
		{
		case 0:
			m_codecType = MEDIA_CODEC_G711_PCMU;
			break;
		case 1:
			m_codecType = MEDIA_CODEC_G711_PCMA;
			break;
		case 2:
			m_codecType = MEDIA_CODEC_G729;
			break;
		case 3:
			m_codecType = MEDIA_CODEC_G7231;
			break;
		case 4:
			m_codecType = MEDIA_CODEC_AMR_NB;
			break;
		case 5:
			m_codecType = MEDIA_CODEC_AMR_WB;
			break;
		case 6:
			m_codecType = MEDIA_CODEC_AAC;
			break;
		case 7:
			m_codecType = MEDIA_CODEC_PCM_WB;
			break;
		case 8:
			m_codecType = MEDIA_CODEC_iLBC;
			break;
		case 9:
			m_codecType = MEDIA_CODEC_SILK;
			break;
		case 10:
			m_codecType = MEDIA_CODEC_GSM;
			break;
		case 11:
			m_codecType = MEDIA_CODEC_G722;
			break;

#ifdef MEDIA_ENGINE_VIDEO

		case 12:
			m_videoCodecType = MEDIA_CODEC_H263;
			return m_videoCodecType;
		case 13:
			m_videoCodecType = MEDIA_CODEC_MPEG4;
			return m_videoCodecType;
		case 14:
			m_videoCodecType = MEDIA_CODEC_H264;
			return m_videoCodecType;
#endif
		default:
			m_codecType = MEDIA_CODEC_G711_PCMU;
			break;

		}
		return m_codecType;
	}
}
	
	
