import { common } from '@kit.AbilityKit';
import { GlobalContextUtils, Logger } from 'lib_common';

const TAG = '[Utils]';

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

export async function setOrientation(orientation: number): Promise<void> {
  let context: common.UIAbilityContext = GlobalContextUtils.globalUIAbilityContext
  try {
    const window = context.windowStage.getMainWindowSync()
    await window.setPreferredOrientation(orientation)
  } catch (error) {
    Logger.error(TAG, 'setOrientation fail, error: ' + JSON.stringify(error));
  }
}
