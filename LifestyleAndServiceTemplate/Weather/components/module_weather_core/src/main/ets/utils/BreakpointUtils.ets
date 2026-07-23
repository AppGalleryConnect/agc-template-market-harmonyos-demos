import { AppStorageV2, MediaQuery, mediaquery } from '@kit.ArkUI';
import { BreakpointModel } from '../common/BreakpointModel';
import { BreakpointNameEnum, BreakpointValueEnum } from '../common/GridRowColSetting';
import { Logger } from './Logger';

const TAG = '[BreakpointUtils]';

export class BreakpointUtils {
  private static readonly RANGE_SM: string = `(width<${BreakpointValueEnum.SM})`;
  private static readonly RANGE_MD: string =
    `(width>=${BreakpointValueEnum.SM}) and (width<${BreakpointValueEnum.MD})`;
  private static readonly RANGE_LG: string =
    `(width>=${BreakpointValueEnum.MD}) and (width<${BreakpointValueEnum.LG})`;
  private static readonly RANGE_XL: string = `(width>=${BreakpointValueEnum.LG})`;
  private mediaQuery: MediaQuery;
  private smListener: mediaquery.MediaQueryListener;
  private mdListener: mediaquery.MediaQueryListener;
  private lgListener: mediaquery.MediaQueryListener;
  private xlListener: mediaquery.MediaQueryListener;
  private breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  constructor(mediaQuery: MediaQuery) {
    this.mediaQuery = mediaQuery;
    this.smListener = this.mediaQuery.matchMediaSync(BreakpointUtils.RANGE_SM);
    this.mdListener = this.mediaQuery.matchMediaSync(BreakpointUtils.RANGE_MD);
    this.lgListener = this.mediaQuery.matchMediaSync(BreakpointUtils.RANGE_LG);
    this.xlListener = this.mediaQuery.matchMediaSync(BreakpointUtils.RANGE_XL);
  }

  register(): void {
    Logger.info(TAG, 'register breakpoint listener.');
    this.smListener.on('change', this.smFunc);
    this.mdListener.on('change', this.mdFunc);
    this.lgListener.on('change', this.lgFunc);
    this.xlListener.on('change', this.xlFunc);
    this.refreshCurrentBreakpoint();
  }

  unRegister(): void {
    Logger.info(TAG, 'unregister breakpoint listener.');
    this.smListener.off('change', this.smFunc);
    this.mdListener.off('change', this.mdFunc);
    this.lgListener.off('change', this.lgFunc);
    this.xlListener.off('change', this.xlFunc);
  }

  private refreshCurrentBreakpoint(): void {
    if (this.smListener.matches) {
      this.updateBreakpoint(BreakpointNameEnum.SM);
    } else if (this.mdListener.matches) {
      this.updateBreakpoint(BreakpointNameEnum.MD);
    } else if (this.lgListener.matches) {
      this.updateBreakpoint(BreakpointNameEnum.LG);
    } else if (this.xlListener.matches) {
      this.updateBreakpoint(BreakpointNameEnum.XL);
    }
  }

  private updateBreakpoint(value: BreakpointNameEnum): void {
    this.breakpointModel.currentBreakpoint = value;
  }

  private smFunc: (result: mediaquery.MediaQueryResult) => void = (result: mediaquery.MediaQueryResult) => {
    if (result.matches) {
      this.updateBreakpoint(BreakpointNameEnum.SM);
    }
  }
  private mdFunc: (result: mediaquery.MediaQueryResult) => void = (result: mediaquery.MediaQueryResult) => {
    if (result.matches) {
      this.updateBreakpoint(BreakpointNameEnum.MD);
    }
  }
  private lgFunc: (result: mediaquery.MediaQueryResult) => void = (result: mediaquery.MediaQueryResult) => {
    if (result.matches) {
      this.updateBreakpoint(BreakpointNameEnum.LG);
    }
  }
  private xlFunc: (result: mediaquery.MediaQueryResult) => void = (result: mediaquery.MediaQueryResult) => {
    if (result.matches) {
      this.updateBreakpoint(BreakpointNameEnum.XL);
    }
  }
}
