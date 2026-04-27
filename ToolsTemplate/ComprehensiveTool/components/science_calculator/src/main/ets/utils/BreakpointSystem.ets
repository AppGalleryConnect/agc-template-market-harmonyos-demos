import { UtilLog } from '@hw-agconnect/util-log';
import { AppStorageV2, window } from '@kit.ArkUI';

export interface BreakpointType<T> {
  sm?: T;
  md?: T;
  lg?: T;
  xl?: T;
  lgWide?: T;
  lgNormal?: T;
}

export enum BreakpointTypeEnum {
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
  XL = 'xl',
  LG_WIDE = 'lgWide',
  LG_NORMAL = 'lgNormal',
}

export class BreakpointModel<T> {
  private options: BreakpointType<T>;

  constructor(options: BreakpointType<T>) {
    this.options = options;
  }

  public getValue(bp: BreakpointTypeEnum) {
    return Reflect.get(this.options, bp) as T;
  }
}

@ObservedV2
export class BreakpointStorage {
  @Trace wight: BreakpointTypeEnum = BreakpointTypeEnum.SM
  @Trace height: BreakpointTypeEnum = BreakpointTypeEnum.LG_NORMAL
}

@ObservedV2
class BreakpointSystem {
  @Trace currentBreakpoint: BreakpointStorage = AppStorageV2.connect(BreakpointStorage, () => new BreakpointStorage())!
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
          this._windowClass.on('windowSizeChange', (data: window.Size) => {
            this.updateBreakpoint(data)
          })
        })
      } catch (e) {
        UtilLog.error(`session close failed: ${JSON.stringify(e)}`);
      }
    }
  }

  public updateBreakpoint(data?: window.Size) {
    let temp: BreakpointTypeEnum = BreakpointTypeEnum.MD
    const curBreakPoint = this._uiContext!.getWindowWidthBreakpoint()
    if (curBreakPoint === WidthBreakpoint.WIDTH_XS || curBreakPoint === WidthBreakpoint.WIDTH_SM) {
      temp = BreakpointTypeEnum.SM
    } else if (curBreakPoint === WidthBreakpoint.WIDTH_MD) {
      temp = BreakpointTypeEnum.MD
    } else if (curBreakPoint === WidthBreakpoint.WIDTH_XL) {
      temp = BreakpointTypeEnum.XL
    } else {
      temp = BreakpointTypeEnum.LG
    }
    this.currentBreakpoint.wight = temp
    let height = AppStorage.get('height') as number || 792
    if (data) {
      height = this._uiContext?.px2vp(data.height) || 792
    }
    if (height < 792) {
      this.currentBreakpoint.height = BreakpointTypeEnum.LG_WIDE
    }
  }

  public unregister() {
    if (this._windowClass) {
      this._windowClass.off('windowSizeChange')
    }
  }
}

const breakpointSystem = new BreakpointSystem()

export { breakpointSystem as BreakpointSystem }