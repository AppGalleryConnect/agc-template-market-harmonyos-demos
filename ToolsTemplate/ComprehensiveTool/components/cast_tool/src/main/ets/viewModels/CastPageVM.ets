import { wifiManager } from '@kit.ConnectivityKit';
import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { avSession } from '@kit.AVSessionKit';
import { ImageUtil } from '../util/ImageUtil';
import { CastService } from '../service/CastService';
import { UtilLog } from '@hw-agconnect/util-log';

@ObservedV2
export class CastPageVM {
  @Trace tips: string = '开始连接设备';
  // wifi名称
  @Trace wifiName: string = '';
  // 连接状态
  @Trace connState: wifiManager.ConnState = wifiManager.ConnState.UNKNOWN;
  // 工具封面
  @Trace appCover: image.PixelMap | undefined = undefined;
  @Trace audioCover: image.PixelMap | undefined = undefined;
  private static _instance: CastPageVM;

  public static get instance() {
    if (!CastPageVM._instance) {
      CastPageVM._instance = new CastPageVM();
    }
    return CastPageVM._instance;
  }

  // 获取wifi信息
  getWifiInfo: () => void = () => {
    try {
      wifiManager.getLinkedInfo((err, data: wifiManager.WifiLinkedInfo) => {
        if (err) {
          this.connState = wifiManager.ConnState.UNKNOWN;
          return;
        }
        this.wifiName = data.ssid;
        this.connState = data.connState;
      });
    } catch (e) {
      UtilLog.error(`getWifiInfo failed with error ${JSON.stringify(e)}`);
    }
  };

  // 获取封面
  public async fetchCover(ctx: Context) {
    this.appCover = await ImageUtil.getPixmapFromMedia(ctx, $r('app.media.cast_tool_icon'));
    this.audioCover = await ImageUtil.getPixmapFromMedia(ctx, $r('app.media.ic_list_audio'));
  }


  async avCastPicker(context: common.Context) {
    let avCastPickerOptions: avSession.AVCastPickerOptions = {
      sessionType: 'video',
    };
    let avCastPicker = new avSession.AVCastPickerHelper(context);
    await avCastPicker.select(avCastPickerOptions);
  }
}