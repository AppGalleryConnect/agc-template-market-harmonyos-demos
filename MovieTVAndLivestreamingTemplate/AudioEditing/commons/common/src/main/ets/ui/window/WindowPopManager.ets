import { display, window } from '@kit.ArkUI'
import { util } from '@kit.ArkTS'
import { BusinessError } from '@kit.BasicServicesKit'
import { WindowParam } from './interface/WindowParam'
import { TCLogger } from '../../basic/TCLogger'
import { WindowUtils } from '../../util/WindowUtils'

const pageRouteName = 'WindowUtil.Page' + util.generateRandomUUID()
// 全局暂仅支持一个window弹框
const pageRouteParam = 'WindowUtil.Param'

const TAG = 'WindowPopManager: '

/**
 * window弹框工具类，可承载自定义view，实现效果同bindSheet、CustomDialog
 * 但可同时支持多个弹框同时显示，可自行管理生命周期
 * 层级为应用内的window层级
 */
export class WindowPopManager {
  static async showWindow(obj: WindowParam, rect?: window.Rect): Promise<void> {
    try {
      const uuidName = obj.name ?? util.generateRandomUUID(true)
      let storage: LocalStorage = new LocalStorage()
      obj.name = uuidName
      // 注册事件
      obj.event = {
        hide: () => {
          WindowPopManager.moveWindowTo(uuidName, 0, display.getDefaultDisplaySync().height)
        },
        show: () => {
          WindowPopManager.moveWindowTo(uuidName, 0, rect?.top ?? 0)
        },
        remove: () => {
          WindowPopManager.destroyWindow(uuidName)
        }
      }
      obj.align = obj.align ?? Alignment.Bottom
      storage.setOrCreate(pageRouteParam, obj)
      let subWindow = await WindowUtils.currentWindowStage?.createSubWindow(uuidName)
      await (subWindow as window.Window).loadContentByName(pageRouteName, storage)
      await subWindow.showWindow()
      await subWindow.setWindowBackgroundColor('#00000000')
      if (rect !== undefined) {
        await subWindow.resize(rect.width, rect.height)
        await subWindow.moveWindowTo(rect.left, rect.top)
      }
    } catch (err) {
      let error = err as BusinessError;
      TCLogger.error(TAG, `showWindow error` + JSON.stringify(error));
    }
  }

  static async destroyWindow(windowName: string) {
    if (!windowName) {
      return
    }
    let windowClass: window.Window | undefined = undefined;
    try {
      windowClass = window.findWindow(windowName);
      await windowClass.destroyWindow();
    } catch (err) {
      TCLogger.error(TAG, `destroyWindow error` + JSON.stringify(err));
    }
  }

  static moveWindowTo(windowName: string | undefined, x: number, y: number) {
    if (!windowName) {
      return
    }
    let windowClass: window.Window | undefined = undefined;
    try {
      windowClass = window.findWindow(windowName);
      windowClass.moveWindowTo(x, y)
    } catch (err) {
      TCLogger.error(TAG, `moveWindowTo error` + JSON.stringify(err))
      return
    }
  }
}

@Entry({ routeName: pageRouteName, storage: LocalStorage.getShared() })
@Component
struct Index {
  @LocalStorageProp(pageRouteParam) wrapParam?: WindowParam = undefined

  aboutToAppear(): void {
    this.wrapParam?.aboutToAppear?.(this.wrapParam.name ?? '')
  }

  aboutToDisappear(): void {
    this.wrapParam?.aboutToDisappear?.(this.wrapParam.name ?? '')
    // 销毁时清理内存中的弹框数据
    LocalStorage.getShared().delete(pageRouteParam)
  }

  onBackPress(): void {
    // 业务拦截返回键，交由业务处理
    this.wrapParam?.onBackPress?.(this.wrapParam.name ?? '')
  }

  build() {
    if (this.wrapParam) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(this.wrapParam.showMask ? '#33000000' : '#00000000')
          .onClick(() => {
            this.autoCancelClick()
          })
        this.wrapParam.builder.builder(this.wrapParam)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Transparent)
      .align(this.wrapParam.align)
    }
  }

  autoCancelClick() {
    if (!this.wrapParam?.autoCancel) {
      return
    }
    WindowPopManager.destroyWindow(this.wrapParam?.name ?? '')
    this.wrapParam?.autoHideCallBack?.()
    // 销毁时清理内存中的弹框数据
    LocalStorage.getShared().delete(pageRouteParam)
  }
}