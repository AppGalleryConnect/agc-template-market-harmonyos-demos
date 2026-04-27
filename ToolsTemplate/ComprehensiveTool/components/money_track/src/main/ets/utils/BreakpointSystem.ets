import { UtilLog } from '@hw-agconnect/util-log';
import { AppStorageV2, window } from '@kit.ArkUI';
import { Logger } from './Logger';

export enum BreakpointTypeEnum {
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
}

export interface BreakpointType<T> {
  sm: T;
  md: T;
  lg: T;
}

export class BreakpointModel<T> {
  sm: T;
  md: T;
  lg: T;

  constructor(param: BreakpointType<T>) {
    this.sm = param.sm;
    this.md = param.md;
    this.lg = param.lg;
  }

  getValue(currentBreakpoint: string): T {
    if (currentBreakpoint === BreakpointTypeEnum.SM) {
      return this.sm;
    }
    if (currentBreakpoint === BreakpointTypeEnum.MD) {
      return this.md;
    }
    return this.lg;
  }
}

const TAG = '[BreakpointSystem]'

@ObservedV2
export class BreakpointStorage {
  @Trace
  value: BreakpointTypeEnum = BreakpointTypeEnum.SM
}

@ObservedV2
class BreakpointSystem {
  @Trace
  public currentBreakpoint: BreakpointStorage =
    AppStorageV2.connect(BreakpointStorage, () => new BreakpointStorage())!
  private _uiContext: UIContext | undefined
  private _windowClass: window.Window | undefined

  public register(uiContext: UIContext) {
    if (this._uiContext) {
      return;
    }
    this._uiContext = uiContext
    if (this._uiContext) {
      this.updateBreakpoint()
      try {
        window.getLastWindow(this._uiContext.getHostContext()).then((win) => {
          this._windowClass = win
          this._windowClass.on('windowSizeChange', () => {
            this.updateBreakpoint()
          })
        })
      } catch (e) {
        UtilLog.error(`session close failed: ${JSON.stringify(e)}`);
      }
    }
  }

  public unregister() {
    if (this._windowClass) {
      this._windowClass.off('windowSizeChange')
    }
  }

  public updateBreakpoint() {
    let temp: BreakpointTypeEnum = BreakpointTypeEnum.MD
    const curBreakPoint = this._uiContext!.getWindowWidthBreakpoint()
    if (curBreakPoint === WidthBreakpoint.WIDTH_XS || curBreakPoint === WidthBreakpoint.WIDTH_SM) {
      temp = BreakpointTypeEnum.SM
    } else if (curBreakPoint === WidthBreakpoint.WIDTH_MD) {
      temp = BreakpointTypeEnum.MD
    } else {
      temp = BreakpointTypeEnum.LG
    }
    this.currentBreakpoint.value = temp
    Logger.info(TAG, 'set breakpoint success, result:' + temp)
  }
}

const breakpointSystem = new BreakpointSystem()

export { breakpointSystem as BreakpointSystem }