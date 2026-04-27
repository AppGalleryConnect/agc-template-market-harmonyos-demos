import { systemDateTime } from '@kit.BasicServicesKit';
import { PrivateChatSettingSingleEnum } from '../utils/MessageEnum';

@ObservedV2
export class PrivateChatSettingSingleModel {
  @Trace icon: string = '';
  @Trace title: ResourceStr = '';
  @Trace type: PrivateChatSettingSingleEnum = PrivateChatSettingSingleEnum.LINE;
  @Trace keyId: string = systemDateTime.getTime(true).toString();
  @Trace height: Length = $r('app.float.vp_12');
  @Trace isTopBorderRadius: boolean = false;
  @Trace isBottomBorderRadius: boolean = false;

  constructor(height?: Length) {
    this.height = height ?? $r('app.float.vp_12');
  }
}