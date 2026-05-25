/*
 * 音频相关常量
 */
import { audio } from '@kit.AudioKit';

export class Constants {
  static MIN_DB = -90;
  static VOLUME_MAX = 32768;
  static DRAW_LINE_WIDTH = 2;
  static WAVE_HEIGHT_RADIO = 30;
  static WAVE_RECORDING_COUNT = 25;
  static WAVE_TICK_INTERVAL = 50;
  static WAVE_RENDER_COUNT = 100;
  static CHANNEL_NUM = audio.AudioChannel.CHANNEL_1;
  static SAMPLING_RATE = audio.AudioSamplingRate.SAMPLE_RATE_16000;
  static SAMPLE_FORMAT = audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE;
  static SAMPLE_BIT = 16;
  static SAMPLE_BYTE = Constants.SAMPLE_BIT / 8;
  static WAVE_RECORD_INDEX: number[] = new Array(Constants.WAVE_RECORDING_COUNT).fill(0);
}

