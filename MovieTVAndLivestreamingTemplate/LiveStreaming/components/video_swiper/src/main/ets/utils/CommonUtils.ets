import { media } from '@kit.MediaKit';
import { AVPlayerState } from '../constant/AVPlayerState';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = '[CommonUtils]';

export function secondToTime(seconds: number): string {
  let hourUnit = 60 * 60;
  let hour: number = Math.floor(seconds / hourUnit);
  let minute: number = Math.floor((seconds - hour * 60) / 60);
  let second: number = seconds % (60 * 60);
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
  if (avPlayer === undefined) {
    hilog.debug(0x0000, TAG,  'setSeek error! avPlayer undefined!');
    return;
  }
  if (avPlayer.state === AVPlayerState.PREPARED || avPlayer.state === AVPlayerState.PLAYING ||
    avPlayer.state === AVPlayerState.PAUSED || avPlayer?.state === AVPlayerState.COMPLETED) {
    avPlayer.seek(seek, media.SeekMode.SEEK_PREV_SYNC);
  }
}

export async function playVideo(avPlayer: media.AVPlayer | undefined, curIndex: number, index: number) {
  if (avPlayer === undefined) {
    hilog.debug(0x0000, TAG,  `playVideo error! avPlayer undefined! curIndex: ${curIndex}, index: ${index}.`);
    return;
  }
  if (avPlayer.state === AVPlayerState.PREPARED || avPlayer.state === AVPlayerState.PAUSED ||
    avPlayer?.state === AVPlayerState.COMPLETED) {
    hilog.debug(0x0000, TAG,  `playVideo. state:${avPlayer.state}, curIndex: ${curIndex}, index: ${index}.`);
    await avPlayer.play();
  }
}

export async function pauseVideo(avPlayer: media.AVPlayer | undefined, curIndex: number, index: number) {
  if (avPlayer === undefined) {
    hilog.debug(0x0000, TAG,  `pauseVideo error! avPlayer undefined! curIndex: ${curIndex}, index: ${index}.`);
    return;
  }
  hilog.debug(0x0000, TAG,  `pauseVideo. state:${avPlayer.state}, curIndex: ${curIndex}, index: ${index}.`);
  await avPlayer.pause();
}

export async function stopVideo(avPlayer: media.AVPlayer | undefined, curIndex: number, index: number) {
  if (avPlayer === undefined) {
    hilog.debug(0x0000, TAG,  `stopVideo error! avPlayer undefined! curIndex: ${curIndex}, index: ${index}.`);
    return;
  }
  if (avPlayer.state === AVPlayerState.PREPARED || avPlayer.state === AVPlayerState.PLAYING ||
    avPlayer.state === AVPlayerState.PAUSED || avPlayer?.state === AVPlayerState.COMPLETED) {
    hilog.debug(0x0000, TAG,  `stopVideo. state:${avPlayer.state}, curIndex: ${curIndex}, index: ${index}.`);
    await avPlayer.stop();
  }
}

export function releaseVideo(avPlayer: media.AVPlayer | undefined, curIndex: number, index: number) {
  if (avPlayer === undefined) {
    hilog.debug(0x0000, TAG,  `releaseVideo error! avPlayer undefined! curIndex: ${curIndex}, index: ${index}.`);
    return;
  }
  hilog.debug(0x0000, TAG,  `releaseVideo. state:${avPlayer.state}, curIndex: ${curIndex}, index: ${index}.`);
  avPlayer.off('timeUpdate');
  avPlayer.off('seekDone');
  avPlayer.off('error');
  avPlayer.off('stateChange');
  avPlayer.release();
}