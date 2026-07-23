import mediaQuery from '@ohos.mediaquery';
import { AppStorageV2, MediaQuery } from '@kit.ArkUI';
import { BreakpointNameEnum, BreakpointValueEnum } from '../constants/GridRowColSetting';
import { BreakpointModel } from '../models/BreakpointModel';
import { Logger } from './Logger';

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

  constructor(mediaQuery: MediaQuery) {
    this.mediaQuery = mediaQuery;
    this.smListen = this.mediaQuery.matchMediaSync(BreakpointUtils.RANGE_SM);
    this.mdListen = this.mediaQuery.matchMediaSync(BreakpointUtils.RANGE_MD);
    this.lgListen = this.mediaQuery.matchMediaSync(BreakpointUtils.RANGE_LG);
    this.xlListen = this.mediaQuery.matchMediaSync(BreakpointUtils.RANGE_XL);
    this.breakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  }

  private updateBreakpoint: (value: string) => void = (value: string) => {
    Logger.info(TAG, `updateBreakpoint: ${value}`);
    this.breakpointModel.currentBreakpoint = value as BreakpointNameEnum;
  }
  private smFunc: (result: mediaQuery.MediaQueryResult) => void = (result) => {
    if (result.matches) {
      this.updateBreakpoint(BreakpointNameEnum.SM);
    }
  }
  private mdFunc: (result: mediaQuery.MediaQueryResult) => void = (result) => {
    if (result.matches) {
      this.updateBreakpoint(BreakpointNameEnum.MD);
    }
  }
  private lgFunc: (result: mediaQuery.MediaQueryResult) => void = (result) => {
    if (result.matches) {
      this.updateBreakpoint(BreakpointNameEnum.LG);
    }
  }
  private xlFunc: (result: mediaQuery.MediaQueryResult) => void = (result) => {
    if (result.matches) {
      this.updateBreakpoint(BreakpointNameEnum.XL);
    }
  }

  register() {
    Logger.info(TAG, 'register breakpoint listener.');
    this.smListen.on('change', this.smFunc);
    this.mdListen.on('change', this.mdFunc);
    this.lgListen.on('change', this.lgFunc);
    this.xlListen.on('change', this.xlFunc);
  }

  unRegister() {
    Logger.info(TAG, 'unregister breakpoint listener.');
    this.smListen.off('change', this.smFunc);
    this.mdListen.off('change', this.mdFunc);
    this.lgListen.off('change', this.lgFunc);
    this.xlListen.off('change', this.xlFunc);
  }
}