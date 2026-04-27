import { display, window } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { BaseViewModel, BreakpointNameEnum, Logger, RouterMap, RouterUtils } from 'lib_common';
import { AvModel } from 'lib_news_api';
import { isDisplayModeFull, setOrientation } from 'module_swipeplayer';
import {
  CardTvWidthSizeConstants,
  CardTvHeightSizeConstants,
  televisionWidthSize,
  televisionHeightSize,
  televisionLanes,
  tvDetailsLanes,
  Constants,
  televisionTabletLanes,
} from '../constants/Constants';

const TAG = '[VideoDetails]'

@ObservedV2
export class VideoVM extends BaseViewModel {
  @Trace curAudioInfo: AvModel = new AvModel()
  @Trace isMute: boolean = false
  private uiContext: UIContext;
  // 视频宽高比
  @Trace videoAspectRatio: number = 1920 / 1080;

  constructor(uiContext: UIContext) {
    super();
    this.uiContext = uiContext;
  }

  /**
   * 往期推荐卡片根据断点改变大小
   * @returns
   */
  public geVideoWidth() {
    return televisionWidthSize.getValue(this.breakPointModel.currentBreakpoint) ?? CardTvWidthSizeConstants.xlSize
  }

  public geVideoHeight() {
    return televisionHeightSize.getValue(this.breakPointModel.currentBreakpoint) ?? CardTvHeightSizeConstants.xlSize
  }

  @Computed
  get isTablet() {
    return [BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.breakPointModel.currentBreakpoint);
  }

  /**
   * 获取猜您喜欢格栅
   * @param isTvDetails
   * @returns
   */
  public getTelevisionLanes(isTvDetails: boolean) {
    return this.isTablet && isTvDetails ? televisionTabletLanes.getValue(this.breakPointModel.currentBreakpoint) :
      televisionLanes.getValue(this.breakPointModel.currentBreakpoint) ?? Constants.COMMON_LANES_1
  }

  /**
   * 电视详情栅格
   * @returns
   */
  public getTvDetailsLanes() {
    return tvDetailsLanes.getValue(this.breakPointModel.currentBreakpoint) ?? Constants.COMMON_LANES_2
  }

  /**
   * 静音切换
   * @param value
   */
  public setMute(value: boolean) {
    this.isMute = value
  }

  private displayFoldStatusChangeCallback = (data: display.FoldStatus) => {
    const lastName = RouterUtils.getLastPathName();
    if (lastName !== RouterMap.VIDEO_PROGRAM_DETAILS) {
      return;
    }
    if (data === display.FoldStatus.FOLD_STATUS_FOLDED) {
      Logger.debug(TAG, 'set USER_ROTATION_PORTRAIT')
      setOrientation(this.uiContext, window.Orientation.USER_ROTATION_PORTRAIT)
    } else if (data === display.FoldStatus.FOLD_STATUS_EXPANDED) {
      Logger.debug(TAG, 'set FOLLOW_DESKTOP')
      setOrientation(this.uiContext, window.Orientation.FOLLOW_DESKTOP);
    }
  }

  /**
   * 还原旋转
   */
  public resetOrientation() {
    setOrientation(this.uiContext, window.Orientation.FOLLOW_DESKTOP);
    try {
      display.off('foldStatusChange', this.displayFoldStatusChangeCallback);
    } catch (e) {
      Logger.error(TAG, 'off foldStatusChange fail, error: ' + JSON.stringify(e));
    }
  }

  /**
   * 设置旋转
   */
  public setOrientation() {
    const isFullMode = isDisplayModeFull();
    if (isFullMode || deviceInfo.deviceType === 'tablet') {
      setOrientation(this.uiContext, window.Orientation.FOLLOW_DESKTOP)
    } else {
      setOrientation(this.uiContext, window.Orientation.USER_ROTATION_PORTRAIT)
    }
    try {
      display.on('foldStatusChange', this.displayFoldStatusChangeCallback);
    } catch (e) {
      Logger.error(TAG, 'on foldStatusChange fail, error: ' + JSON.stringify(e));
    }
  }

  @Computed
  get videoBoxAspectRatio() {
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.breakPointModel.currentBreakpoint)) {
      return -1;
    }
    return this.videoAspectRatio;
  }

  @Computed
  get videoBoxHeight() {
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.breakPointModel.currentBreakpoint)) {
      return '100%';
    }
    return 'auto';
  }
}