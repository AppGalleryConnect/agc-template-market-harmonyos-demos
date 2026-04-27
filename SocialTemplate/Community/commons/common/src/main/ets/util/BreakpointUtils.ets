import mediaQuery from '@ohos.mediaquery';
import { AppStorageV2, display, MediaQuery } from '@kit.ArkUI';
import { BreakpointNameEnum, BreakpointValueEnum } from '../constant/GridRowColSetting';
import { BreakpointModel } from '../model/BreakpointModel';
import { TCLogger } from '../basic/TCLogger';
import { ChatBreakpoint, ChatBreakpointEnum } from 'chat_base';

const TAG = 'BreakpointUtils';

/**
 * 断点类
 */
export class BreakpointUtils {
  private static readonly RANGE_SM: string = `(width<${BreakpointValueEnum.SM})`;
  private static readonly RANGE_MD: string = `(width>=${BreakpointValueEnum.SM}) and (width<${BreakpointValueEnum.MD})`;
  private static readonly RANGE_LG: string = `(width>=${BreakpointValueEnum.MD}) and (width<${BreakpointValueEnum.LG})`;
  private static readonly RANGE_XL: string = `(width>=${BreakpointValueEnum.LG})`;
  private mediaQuery: MediaQuery;
  private smListen: mediaQuery.MediaQueryListener;
  private mdListen: mediaQuery.MediaQueryListener;
  private lgListen: mediaQuery.MediaQueryListener;
  private xlListen: mediaQuery.MediaQueryListener;
  private breakpointModel: BreakpointModel = new BreakpointModel();
  private chatBreakpoint: ChatBreakpoint = new ChatBreakpoint();


  constructor(mediaQuery: MediaQuery) {
    this.mediaQuery = mediaQuery;
    this.smListen = this.mediaQuery.matchMediaSync(BreakpointUtils.RANGE_SM);
    this.mdListen = this.mediaQuery.matchMediaSync(BreakpointUtils.RANGE_MD);
    this.lgListen = this.mediaQuery.matchMediaSync(BreakpointUtils.RANGE_LG);
    this.xlListen = this.mediaQuery.matchMediaSync(BreakpointUtils.RANGE_XL);
    this.breakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
    this.chatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  }

  private updateBreakpoint: (value: string) => void = (value: string) => {
    TCLogger.info(TAG, `updateBreakpoint: ${value}`);
    this.breakpointModel.currentBreakpoint = value as BreakpointNameEnum;
    this.chatBreakpoint.currentChatBreakpoint = value as ChatBreakpointEnum;
  }
  private updateCurrentDisplay: () => void = () => {
    this.breakpointModel.currentDisplayWidth = px2vp(display.getDefaultDisplaySync().width);
    this.chatBreakpoint.currentScreenWidth = px2vp(display.getDefaultDisplaySync().width);
    TCLogger.debug(TAG, `updateCurrentDisplayWidth: ${this.breakpointModel.currentDisplayWidth}`);
    this.breakpointModel.currentDisplayHeight = px2vp(display.getDefaultDisplaySync().height);
    TCLogger.debug(TAG, `updateCurrentDisplayHeight: ${this.breakpointModel.currentDisplayHeight}`);
  }
  private smFunc: (result: mediaQuery.MediaQueryResult) => void = (result) => {
    if (result.matches) {
      this.updateBreakpoint(BreakpointNameEnum.SM);
      this.updateCurrentDisplay();
    }
  }
  private mdFunc: (result: mediaQuery.MediaQueryResult) => void = (result) => {
    if (result.matches) {
      this.updateBreakpoint(BreakpointNameEnum.MD);
      this.updateCurrentDisplay();
    }
  }
  private lgFunc: (result: mediaQuery.MediaQueryResult) => void = (result) => {
    if (result.matches) {
      this.updateBreakpoint(BreakpointNameEnum.LG);
      this.updateCurrentDisplay();
    }
  }
  private xlFunc: (result: mediaQuery.MediaQueryResult) => void = (result) => {
    if (result.matches) {
      this.updateBreakpoint(BreakpointNameEnum.XL);
      this.updateCurrentDisplay();
    }
  }

  register() {
    TCLogger.info(TAG, 'register breakpoint listener.');
    this.smListen.on('change', this.smFunc);
    this.mdListen.on('change', this.mdFunc);
    this.lgListen.on('change', this.lgFunc);
    this.xlListen.on('change', this.xlFunc);
  }

  unRegister() {
    TCLogger.info(TAG, 'unregister breakpoint listener.');
    this.smListen.off('change', this.smFunc);
    this.mdListen.off('change', this.mdFunc);
    this.lgListen.off('change', this.lgFunc);
    this.xlListen.off('change', this.xlFunc);
  }
}