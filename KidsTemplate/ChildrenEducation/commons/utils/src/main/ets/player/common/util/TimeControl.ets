import { DateUtil } from '../../../utils/DateUtil';
import { GlobalContext } from '../../../utils/GlobalContext';
import { promptAction } from '@kit.ArkUI';
import { PlayConstants } from '../constants/PlayConstants';
import { CommonConstants } from '../../../constants/CommonConstants';

export class TimeControl {
  public static timeControl(): boolean {
    if (TimeControl.checkTime()) {
      promptAction.showToast({
        message: PlayConstants.NOT_ALLOW_WATCH,
        alignment: Alignment.Center,
      });
      return true;
    }
    return false;
  }

  private static checkTime(): boolean {
    let currentTime = Number(DateUtil.getFormatDateStr(new Date(), 'HH:mm').replaceAll(':', ''));

    let lunchTimeState = GlobalContext.getContext().getObject(CommonConstants.LUNCH_TIME_STATE) as boolean;
    let nightTimeState = GlobalContext.getContext().getObject(CommonConstants.NIGHT_TIME_STATE) as boolean;

    if (lunchTimeState) {
      let lunchStartTime =
        TimeControl.convertTimeToNumber(GlobalContext.getContext()
          .getObject(CommonConstants.LUNCH_START_TIME) as string);
      let lunchEndTime =
        TimeControl.convertTimeToNumber(GlobalContext.getContext().getObject(CommonConstants.LUNCH_END_TIME) as string);
      if (currentTime >= lunchStartTime && currentTime <= lunchEndTime) {
        return true;
      }
    }

    if (nightTimeState) {
      let nightStartTime =
        TimeControl.convertTimeToNumber(GlobalContext.getContext()
          .getObject(CommonConstants.NIGHT_START_TIME) as string);
      let nightEndTime =
        TimeControl.convertTimeToNumber(GlobalContext.getContext().getObject(CommonConstants.NIGHT_END_TIME) as string);

      if (nightStartTime <= nightEndTime) {
        if (currentTime >= nightStartTime && currentTime <= nightEndTime) {
          return true;
        }
      } else {
        if (currentTime >= nightStartTime || currentTime <= nightEndTime) {
          return true;
        }
      }
    }
    return false;
  }

  private static convertTimeToNumber(param: string): number {
    return Number(param.replaceAll(':', ''));
  }
}