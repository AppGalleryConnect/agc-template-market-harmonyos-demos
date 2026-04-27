import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { CastService } from '../service/CastService';
import { MediaData, CastSessionListener, MediaType, CastParams } from '../model/Index';
import { RouterMap, getInstance } from '../util/Route';


@ObservedV2
export class CastControllerPageVM implements CastSessionListener {
  @Trace currentIndex: number = 0;
  @Trace mediaList: MediaData[] = [];
  @Trace mediaType: MediaType = MediaType.VIDEO;
  @Trace isVideoListShow: boolean = false;
  private static _instance: CastControllerPageVM;

  public static get instance() {
    if (!CastControllerPageVM._instance) {
      CastControllerPageVM._instance = new CastControllerPageVM();
    }
    return CastControllerPageVM._instance;
  }


  getRouteParm() {
    const param = getInstance().getParamByName(RouterMap.CONTROLLER)[0] as CastParams;
    this.mediaList = param.mediaList;
    this.currentIndex = param.selectIndex;
    this.mediaType = param.mediaType;
  }


  changeFile(param: CastParams) {
    this.mediaList = param.mediaList;
    this.currentIndex = param.selectIndex;
    this.mediaType = param.mediaType;
    CastService.getInstance()
      .setAVMetadata(this.mediaList[this.currentIndex], this.mediaList[this.currentIndex].duration);
    CastService.getInstance().play();
  }


  onStartCasting(): void {
    Logger.debug('onStartCasting callBack');
  }

  onEndCasting(): void {
    Logger.debug('onEndCasting callBack');
    getInstance().popToName(RouterMap.HOME);
    CastService.getInstance().unregisterSessionListener();
    CastService.getInstance().deinit();
  }

  onPlay(): void {
    Logger.debug('onPlay callBack');
  }

  onPause(): void {
    Logger.debug('onPause callBack');
  }

  onPlayNext(): void {
    this.currentIndex = (this.currentIndex + 1) % this.mediaList.length;
    CastService.getInstance()
      .setAVMetadata(this.mediaList[this.currentIndex], this.mediaList[this.currentIndex].duration);
    CastService.getInstance().play();
  }

  onPlayPre(): void {
    const targetIndex = (this.currentIndex - 1) % this.mediaList.length;
    if (targetIndex < 0) {
      this.currentIndex = targetIndex + this.mediaList.length;
    } else {
      this.currentIndex = targetIndex;
    }
    CastService.getInstance()
      .setAVMetadata(this.mediaList[this.currentIndex], this.mediaList[this.currentIndex].duration);
    CastService.getInstance().play();
  }

  onSeek(time: number): void {
    Logger.debug('onSeek callBack');
  }

  onFastForward(time: number): void {
    Logger.debug('onFastForward callBack');
  }

  onRewind(time: number): void {
    Logger.debug('onRewind callBack');
  }
}