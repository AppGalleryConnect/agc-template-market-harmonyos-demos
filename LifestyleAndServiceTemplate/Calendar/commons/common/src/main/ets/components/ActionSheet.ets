import { ComponentContent, window } from '@kit.ArkUI'

/**
 * ActionSheetOption 类型
 */
class ActionSheetOption {
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
    this.preferType = option.preferType || SheetType.BOTTOM
    this.closeable = option.closeable !== undefined ? option.closeable : true
    this.customContent = option.customContent || undefined
    this.onOpen = option.onOpen || undefined
    this.onCancel = option.onCancel || undefined
    this.onClose = option.onClose || undefined
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
  private uiContext: UIContext | null = null
  private contentNodeMap: Map<string, contentNodeMapVal> = new Map()

  /*
   * 展示actionSheet
   */
  public async show(option: ActionSheetOption) {
    let key = option.id ?? this.getUniKey()
    if (this.uiContext === null) {
      let windowClass: window.Window = await window.getLastWindow(getContext())
      this.uiContext = windowClass.getUIContext()
    }
    let params = new ActionSheetParams(option)
    params.id = key
    params.close = (id: string): Promise<void> => this.close(id)
    let contentNode = new ComponentContent(this.uiContext, wrapBuilder(defaultBuilder), params)
    let sheetOption: SheetOptions = {
      height: params.height,
      preferType: params.preferType,
      backgroundColor: params.backgroundColor ? params.backgroundColor : ($r('sys.color.background_primary')),
      showClose: params.showClose,
      onWillDismiss: async (dismissSheetAction: DismissSheetAction) => {
        // 0: 点击三键back、左滑/右滑、键盘ESC 1 点击蒙层  3: 跟手拖拽
        if (dismissSheetAction.reason === DismissReason.PRESS_BACK ||
          dismissSheetAction.reason === DismissReason.TOUCH_OUTSIDE) {
          return
        }
        dismissSheetAction.dismiss()
        params.onClose?.()
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
    await this.uiContext.openBindSheet(contentNode, sheetOption)
    params.onOpen?.()
    return key
  }

  /**
   * 关闭actionSheet
   */
  public async close(id?: string) {
    let key = id || this.getLastKey()
    if (this.contentNodeMap.has(key)) {
      let val = this.contentNodeMap.get(key) as contentNodeMapVal
      this.uiContext?.closeBindSheet(val?.content).then(() => {
        val?.params.onClose?.()
        this.contentNodeMap.delete(key)
        if (this.contentNodeMap.size === 0) {
          this.uiContext = null
        }
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

const commonActionSheet = new ActionSheet()

export {
  commonActionSheet }

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