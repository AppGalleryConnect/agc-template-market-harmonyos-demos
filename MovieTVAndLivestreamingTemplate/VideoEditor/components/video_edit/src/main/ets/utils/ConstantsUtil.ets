import { TValueType } from 'video_common';
import { DisplayUtil } from './DisplayUtil';

export default class ConstantsUtil {
  static readonly SECONDS_TO_MILLISECONDS: number = 1000;
  static readonly MINUTES_TO_MILLISECONDS: number = 60000;
  static readonly PROGRESS_REFRESH_INTERVAL: number = 100;
  static readonly PIP_WIDTH: number = DisplayUtil.getWidth() / 2;
  static readonly BASIC_HEIGHT: number = 200;
  static readonly PIP_HEIGHT: number = 100;
  static readonly BASIC_VIDEO_WIDTH: number = DisplayUtil.getWidth();
  static readonly BASIC_VIDEO_HEIGHT: number = DisplayUtil.getHeight() * 0.515;
  static readonly BASIC_FULL_VIDEO_WIDTH: number = DisplayUtil.getHeight();
  static readonly PIP_VIDEO_WIDTH: number = DisplayUtil.getWidth() / 2;
  static readonly PIP_VIDEO_HEIGHT: number = 180;
  static readonly IMAGE_WIDTH: number = 50
  static readonly IMAGE_HEIGHT: number = 50
  static readonly PIP_IMAGE_HEIGHT: number = 30
  static readonly BASIC_VIDEO_URL: string = '/basicVideo';
  static readonly PIP_VIDEO_URL: string = '/pipVideo';
  static readonly BASIC_VIDEO_FRAME_URL: string = '/basicVideoFrame';
  static readonly PIP_VIDEO_FRAME_URL: string = '/pipVideoFrame';
  static readonly VIDEO_SUBTITLE_URL: string = '/videoSubTitle';
  static readonly VIDEO_AUTOCUE_URL: string = '/videoAutoCue';
  static readonly VIDEO_COVER_URL: string = '/videoCover';
  static currentDisplayWidth: number = DisplayUtil.getWidth();
  static currentDisplayHeight: number = DisplayUtil.getHeight();
  static isFullScreen: boolean = false
}

export class ActionWithAppBean {
  /**
   * 与APP层交互
   */
  static readonly ACTION_WITH_APP = 0x1001

  action: string = '';
  data: TValueType = null
}

// 视频转化格式
export const CODEC_TABLE: Map<string, string[]> = new Map();

CODEC_TABLE.set('mp4', ['h264', 'mpeg4', 'mpeg2video']);
CODEC_TABLE.set('mkv', ['h264', 'mpeg4', 'mpeg2video', 'h263p']);
CODEC_TABLE.set('mov', ['h264', 'mpeg4', 'mpeg2video', 'h263p']);
CODEC_TABLE.set('avi', ['h264', 'mpeg4', 'mpeg2video', 'h263p']);
CODEC_TABLE.set('flv', ['h264', 'mpeg4', 'mpeg2video']);


// 视频分辨率
export const RESOLUTION_TABLE: Map<string, string[]> = new Map();

RESOLUTION_TABLE.set('1080', ['1920', '1080']);
RESOLUTION_TABLE.set('720', ['1280', '720']);
RESOLUTION_TABLE.set('480', ['854', '480']);

// 分钟数字元素列表
export const SUBTITLES_MINUTE_LIST: string[] = [
  '00', '01', '02', '03', '04', '05', '06', '07', '08', '09',
  '10', '11', '12', '13', '14', '15', '16', '17', '18', '19',
  '20', '21', '22', '23', '24', '25', '26', '27', '28', '29',
  '30', '31', '32', '33', '34', '35', '36', '37', '38', '39',
  '40', '41', '42', '43', '44', '45', '46', '47', '48', '49',
  '50', '51', '52', '53', '54', '55', '56', '57', '58', '59',
];
