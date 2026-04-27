// 振幅灵敏系数
const RATIO = 3;
// 16bit采样格式最大振幅值
const DEFAULT_AMPLITUDE_MAX = 32767;

// 波纹显示最大高度
export const AMPLITUDE_MAX_HEIGHT = 60;

// 修正最大振幅
export const AMPLITUDE_MAX = DEFAULT_AMPLITUDE_MAX / RATIO;

// 波纹条数目
export const WAVE_BAR_COUNT = 8;

// 波纹条最小高度
export const AMPLITUDE_MIN_HEIGHT = 6;

// todo 根据需求配置语音识别支持的音频长度 单位s
export const MAX_DURATION = 60;

// todo 根据需求配置音频最大支持变速到的长度 默认2h
export const MAX_EDIT_DURATION = 7200;