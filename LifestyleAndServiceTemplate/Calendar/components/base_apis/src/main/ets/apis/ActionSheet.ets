import { ComponentContent } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log'

const TAG = '[ActionSheet]'

/**
 * ActionSheetOption 类型
 */
class ActionSheetOption {
  /**
   * 模态框id
   */
  id?: string = ''
  /**
   * 高度
   */
  height?: SheetSize | Length
  /**
   * 半模态页面的切换高度档位
   */
  detents?: [(SheetSize | Length), (SheetSize | Length)?, (SheetSize | Length)?]
  /**
   * 原生标题
   */
  title?: SheetTitleOptions | CustomBuilder
  /**
   * 半模态页面的样式
   */
  preferType?: SheetType
  /**
   * 是否显示原生关闭图标
   */
  showClose?: boolean
  /**
   * 是否显示关闭图标
   */
  closeable?: boolean
  /**
   * 自定义内容
   */
  customContent?: () => void = () => {
  }
  /**
   * 打开回调
   */
  onOpen?: () => void
  /**
   * 点击取消回调
   */
  onCancel?: () => void
  /**
   * 关闭回调
   */
  onClose?: () => void
  /**
   * 背景
   */
  backgroundColor?: ResourceStr = ''
  onWillAppear?: () => void
  keyboardAvoidMode?: SheetKeyboardAvoidMode = SheetKeyboardAvoidMode.RESIZE_ONLY
}

class ActionSheetParams extends ActionSheetOption {
  id: string = ''
  close: (id: string) => void = () => {
  }

  constructor(option: ActionSheetOption) {
    super()
    this.height = option.height || SheetSize.FIT_CONTENT
    this.detents = option.detents
    this.backgroundColor = option.backgroundColor
    this.title = option.title
    this.showClose = option.showClose
    this.preferType = option.preferType
    this.closeable = option.closeable !== undefined ? option.closeable : true
    this.customContent = option.customContent || undefined
    this.onOpen = option.onOpen || undefined
    this.onCancel = option.onCancel || undefined
    this.onClose = option.onClose || undefined
    this.onWillAppear = option.onWillAppear || undefined
    this.keyboardAvoidMode = option.keyboardAvoidMode || SheetKeyboardAvoidMode.RESIZE_ONLY

  }
}

@Builder
function defaultBuilder(option: ActionSheetParams) {
  defaultContent({ option })
}

interface contentNodeMapVal {
  content: ComponentContent<ActionSheetParams>
  params: ActionSheetParams
}


class ActionSheet {
  private contentNodeMap: Map<string, contentNodeMapVal> = new Map()

  /*
   * 展示actionSheet
   */
  public async show(uiContext: UIContext, option: ActionSheetOption) {
    let key = option.id ?? this.getUniKey()
    let params = new ActionSheetParams(option)
    params.id = key
    params.close = (id: string): Promise<void> => this.close(uiContext, id)
    let contentNode = new ComponentContent(uiContext, wrapBuilder(defaultBuilder), params)
    let sheetOption: SheetOptions = {
      keyboardAvoidMode: params.keyboardAvoidMode ?? SheetKeyboardAvoidMode.RESIZE_ONLY,
      height: params.height,
      detents: params.detents,
      preferType: params.preferType || SheetType.CENTER,
      backgroundColor: params.backgroundColor ? params.backgroundColor : ($r('sys.color.background_primary')),
      showClose: params.showClose,
      onWillDismiss: async (dismissSheetAction: DismissSheetAction) => {
        // 0: 点击三键back、左滑/右滑、键盘ESC 1 点击蒙层  3: 跟手拖拽
        let reason = dismissSheetAction.reason
        if (reason === DismissReason.SLIDE_DOWN) {
          return
        }
        dismissSheetAction.dismiss()
      },
      onDisappear: () => {
        params.onClose?.()
      },
      onWillAppear: () => {
        params.onWillAppear?.()
      },
    }
    if (params.title) {
      sheetOption.title = params.title
    }
    if (params.detents) {
      sheetOption.detents = params.detents
    }
    if (params.backgroundColor) {
      sheetOption.backgroundColor = params.backgroundColor
    }
    this.contentNodeMap.set(key, {
      content: contentNode,
      params: params,
    })
    try {
      await uiContext.openBindSheet(contentNode, sheetOption)
      params.onOpen?.()
    } catch (e) {
      UtilLog.error(TAG, 'openBindSheet error' + e)
    }
    return key
  }

  /**
   * 关闭actionSheet
   */
  public async close(uiContext: UIContext, id?: string) {
    let key = id || this.getLastKey()
    if (this.contentNodeMap.has(key)) {
      let val = this.contentNodeMap.get(key) as contentNodeMapVal
      uiContext.closeBindSheet(val?.content).then(() => {
        val?.params.onClose?.()
        this.contentNodeMap.delete(key)
      }).catch((error: BusinessError) => {
        UtilLog.error(TAG, 'closeBindSheet error' + error)
      })
    }
  }

  private getUniKey(): string {
    let key = Math.random().toString(36).substring(2, 9)
    if (this.contentNodeMap.has(key)) {
      return this.getUniKey()
    }
    return key
  }

  private getLastKey(): string {
    return Array.from(this.contentNodeMap.keys()).pop() || ''
  }
}

const baseActionSheet = new ActionSheet()

export {
  baseActionSheet }

@Component
struct defaultContent {
  @Prop option: ActionSheetParams

  build() {
    customContent({ customBuilder: this.option.customContent })
  }
}

@Component
struct customContent {
  @BuilderParam customBuilder?: () => void

  build() {
    if (this.customBuilder) {
      this.customBuilder()
    }
  }
}