const TAG: string = '[CheckInChannelUtil]';

export class CheckInChannelUtil {
  private static isFromServiceCard: boolean = false;

  public static set() {
    CheckInChannelUtil.isFromServiceCard = true;
  }

  public static reset() {
    CheckInChannelUtil.isFromServiceCard = false;
  }

  public static fromServiceCard(): boolean {
    return CheckInChannelUtil.isFromServiceCard;
  }
}