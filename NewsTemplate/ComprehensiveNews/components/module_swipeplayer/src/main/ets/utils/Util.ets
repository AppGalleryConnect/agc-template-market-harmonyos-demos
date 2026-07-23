import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import { display, promptAction } from '@kit.ArkUI';
import { audio } from '@kit.AudioKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { sensor } from '@kit.SensorServiceKit';
import { Logger } from './Logger';
import { AVPlayerState } from '../type/Index';

const TAG = '[CommonUtils]';

export function secondToTime(seconds: number): string {
  let hourUnit = 60 * 60;
  let hour: number = Math.floor(seconds / hourUnit);
  let minute: number = Math.floor((seconds % hourUnit) / 60);
  let second: number = Math.floor(seconds % 60);
  let hourStr: string = hour < 10 ? `0${hour.toString()}` : `${hour.toString()}`;
  let minuteStr: string = minute < 10 ? `0${minute.toString()}` : `${minute.toString()}`;
  let secondStr: string = second < 10 ? `0${second.toString()}` : `${second.toString()}`;
  if (hour > 0) {
    return `${hourStr}:${minuteStr}:${secondStr}`;
  }
  if (minute > 0) {
    return `${minuteStr}:${secondStr}`;
  }
  return `00:${secondStr}`;
}

export function setSeek(avPlayer: media.AVPlayer | undefined, seek: number) {
  if (!avPlayer) {
    Logger.debug(TAG, 'setSeek error! avPlayer undefined!');
    return;
  }
  let states = [AVPlayerState.PREPARED, AVPlayerState.PLAYING, AVPlayerState.PAUSED, AVPlayerState.COMPLETED]
  if (states.includes(avPlayer.state as AVPlayerState)) {
    avPlayer.seek(seek, media.SeekMode.SEEK_CLOSEST);
  }
}

export function setSpeed(avPlayer: media.AVPlayer | undefined, speed: media.PlaybackSpeed) {
  if (avPlayer === undefined) {
    Logger.debug(TAG, 'setSpeed error! avPlayer undefined!');
    return;
  }
  if (speed < 0) {
    speed = media.PlaybackSpeed.SPEED_FORWARD_0_125_X;
    Logger.debug(TAG, 'The player speed cannot be lower than 0.125');
  }
  if (speed > 9) {
    speed = media.PlaybackSpeed.SPEED_FORWARD_3_00_X
    Logger.debug(TAG, 'The player speed cannot be higher than 3');
  }
  if (avPlayer.state === AVPlayerState.PLAYING) {
    avPlayer.setSpeed(speed);
  }
}

export async function playVideo(avPlayer: media.AVPlayer | undefined, curIndex?: number, index?: number) {
  try {
    if (!avPlayer) {
      Logger.debug(TAG, `playVideo error! avPlayer undefined! curIndex: ${curIndex}, index: ${index}.`);
      return;
    }
    let states = [AVPlayerState.PREPARED, AVPlayerState.PAUSED, AVPlayerState.COMPLETED]
    if (states.includes(avPlayer.state as AVPlayerState)) {
      Logger.debug(TAG, `playVideo. state:${avPlayer.state}, curIndex: ${curIndex}, index: ${index}.`);
      await avPlayer.play();
    }
  } catch (e) {
    Logger.error(TAG, 'playVideo fail, error: ' + JSON.stringify(e));
  }
}

export async function pauseVideo(avPlayer: media.AVPlayer | undefined, curIndex?: number, index?: number) {
  try {
    if (!avPlayer) {
      Logger.debug(TAG, `pauseVideo error! avPlayer undefined! curIndex: ${curIndex}, index: ${index}.`);
      return;
    }
    Logger.debug(TAG, `pauseVideo. state:${avPlayer.state}, curIndex: ${curIndex}, index: ${index}.`);
    await avPlayer.pause();
  } catch (e) {
    Logger.error(TAG, 'pauseVideo fail, error: ' + JSON.stringify(e));
  }
}

export async function setOrientation(uiContext: UIContext | undefined, orientation: number): Promise<void> {
  try {
    if (!uiContext) {
      return;
    }
    Logger.debug(TAG, 'setPreferredOrientation: ' + orientation);
    let context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext
    await context.windowStage.getMainWindowSync().setPreferredOrientation(orientation)
  } catch (e) {
    Logger.error(TAG, 'setOrientation fail, error: ' + JSON.stringify(e));
  }
}

/**
 * 检测设备是否水平放置
 * @param callback
 */
export function isDevicePlaceFlat(callback: (isFlat: boolean) => void): void {
  // 阈值常量
  const GRAVITY = 9.8; // 标准重力加速度
  const Z_THRESHOLD = 1.5; // Z轴允许误差范围
  const XY_THRESHOLD = 1.0; // X/Y轴倾斜阈值
  try {
    sensor.once(sensor.SensorId.GRAVITY, (data: sensor.GravityResponse) => {
      // 判断Z轴是否接近重力加速度绝对值
      const isZValid = Math.abs(Math.abs(data.z) - GRAVITY) < Z_THRESHOLD;
      // 判断设备是否水平（X/Y轴接近0）
      const isHorizontal = Math.abs(data.x) < XY_THRESHOLD && Math.abs(data.y) < XY_THRESHOLD;
      Logger.debug(TAG, `Success query sensor gravity, isFlat: ${isZValid && isHorizontal}`);
      callback(isZValid && isHorizontal)
    })
  } catch (e) {
    Logger.error(TAG, `Failed to invoke once. Code: ${e.code}, message: ${e.message}`);
    callback(false);
  }
}

export function toast(uiContext: UIContext, options: promptAction.ShowToastOptions) {
  try {
    let target = {
      duration: 2000,
    } as promptAction.ShowToastOptions;
    target = assign(target, options)
    uiContext.getPromptAction().showToast(target);
  } catch (e) {
    Logger.error(TAG, 'showToast fail, error: ' + JSON.stringify(e));
  }
}

// 合并对象
export function assign(
  target: promptAction.ShowToastOptions,
  ...source: promptAction.ShowToastOptions[]
): promptAction.ShowToastOptions {
  for (let s of source) {
    for (let k of Object.keys(s)) {
      target[k] = Reflect.get(s, k)
    }
  }
  return target
}

/**
 * 本地沙箱视频链接处理，沙箱视频播放依赖file为打开状态，默认不关闭文件
 * @param videoUrlPath
 * @param allowClose
 * @returns 文件描述符fd
 */
export function handleSandboxVideoUrl(videoUrlPath: string, allowClose: boolean = false): number {
  let file: fs.File | null = null;
  try {
    // 打开相应的资源文件地址获取fd，并为url赋值触发initialized状态机上报
    file = fs.openSync(videoUrlPath);
    return file.fd
  } catch (e) {
    Logger.error(TAG, 'openSync fail, error: ' + JSON.stringify(e));
    return 0;
  } finally {
    if (file && allowClose) {
      closeFileSync(file);
    }
  }
}

/**
 * 关闭文件
 * @param file
 */
export function closeFileSync(file: number | fs.File): void {
  try {
    if (file) {
      fs.closeSync(file);
    }
  } catch (e) {
    Logger.error(TAG, `Failed to closeFileSync. Code: ${e.code}, message: ${e.message}`);
  }
}

// 判断是否是折叠屏展开态
export const isDisplayModeFull = (): boolean => {
  try {
    const foldStatus = display.getFoldStatus();
    return display.isFoldable() && foldStatus === display.FoldStatus.FOLD_STATUS_EXPANDED;
  } catch (e) {
    Logger.error(TAG, 'isDisplayModeFull fail, error: ' + JSON.stringify(e));
    return false;
  }
}

/**
 * 判断折叠屏是否处于折叠态
 */
export const isDisplayModeFolded = () => {
  try {
    const foldStatus = display.getFoldStatus();
    return display.isFoldable() && foldStatus === display.FoldStatus.FOLD_STATUS_FOLDED;
  } catch (err) {
    let error = err as BusinessError;
    Logger.error(TAG, `isDisplayModeFolded err, error code: ${error.code}, error message: ${error.message}`);
    return false;
  }
};

export function registerAVPlayerCallback(
  avPlayer: media.AVPlayer,
  callbackMap: Map<string, Array<(...args: ESObject) => void>>,
) {
  avPlayer.on('durationUpdate', (duration: number) => {
    callbackMap.get('durationUpdate')?.forEach((item) => {
      item(duration);
    });
  });

  avPlayer.on('seekDone', (time: number) => {
    callbackMap.get('seekDone')?.forEach((item) => {
      item(time);
    });
  });

  avPlayer.on('speedDone', (speed: number) => {
    callbackMap.get('speedDone')?.forEach((item) => {
      item(speed);
    });
  });

  avPlayer.on('bitrateDone', (bitrate: number) => {
    callbackMap.get('bitrateDone')?.forEach((item) => {
      item(bitrate);
    });
  });

  avPlayer.on('availableBitrates', (bitrates: Array<number>) => {
    callbackMap.get('availableBitrates')?.forEach((item) => {
      item(bitrates);
    });
  });

  avPlayer.on('volumeChange', (vol: number) => {
    callbackMap.get('volumeChange')?.forEach((item) => {
      item(vol);
    });
  });

  avPlayer.on('endOfStream', () => {
    callbackMap.get('endOfStream')?.forEach((item) => {
      item();
    });
  });

  avPlayer.on('bufferingUpdate', (infoType: media.BufferingInfoType, value: number) => {
    callbackMap.get('bufferingUpdate')?.forEach((item) => {
      item(infoType, value);
    });
  });

  avPlayer.on('startRenderFrame', () => {
    callbackMap.get('startRenderFrame')?.forEach((item) => {
      item();
    });
  });

  try {
    avPlayer.on('audioOutputDeviceChangeWithInfo', (data: audio.AudioStreamDeviceChangeInfo) => {
      callbackMap.get('audioOutputDeviceChangeWithInfo')?.forEach((item) => {
        item(data);
      });
    });
  } catch (err) {
    Logger.error(TAG, `isDisplayModeFolded err, error code: ${err.code}, error message: ${err.message}`);
  }


  avPlayer.on('subtitleUpdate', (info: media.SubtitleInfo) => {
    callbackMap.get('subtitleUpdate')?.forEach((item) => {
      item(info);
    });
  });

  avPlayer.on('trackChange', (index: number, isSelect: boolean) => {
    callbackMap.get('trackChange')?.forEach((item) => {
      item(index, isSelect);
    });
  });

  avPlayer.on('trackInfoUpdate', (info: Array<media.MediaDescription>) => {
    callbackMap.get('trackInfoUpdate')?.forEach((item) => {
      item(info);
    });
  });
}