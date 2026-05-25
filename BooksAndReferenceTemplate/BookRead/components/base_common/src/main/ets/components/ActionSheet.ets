import { ComponentContent, window } from '@kit.ArkUI'
import { cryptoFramework } from '@kit.CryptoArchitectureKit'
import { Decimal } from '@kit.ArkTS'

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
   * 关闭回调
   */
  onWillDismiss?: (DismissSheetAction: DismissSheetAction) => void
  /**
   * 背景
   */
  backgroundColor?: ResourceStr = ''
  /**
   * 背景模糊
   */
  blurStyle?: BlurStyle
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
    this.blurStyle = option.blurStyle || BlurStyle.NONE
    this.title = option.title
    this.showClose = option.showClose
    this.preferType = option.preferType || SheetType.BOTTOM
    this.closeable = option.closeable !== undefined ? option.closeable : true
    this.customContent = option.customContent || undefined
    this.onOpen = option.onOpen || undefined
    this.onCancel = option.onCancel || undefined
    this.onClose = option.onClose || undefined
    this.onWillDismiss = option.onWillDismiss || undefined
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
      this.uiContext = AppStorage.get('uiContext') as UIContext;
    }
    let params = new ActionSheetParams(option)
    params.id = key
    params.close = (id: string): Promise<void> => this.close(id)
    let contentNode = new ComponentContent(this.uiContext, wrapBuilder(defaultBuilder), params)
    let sheetOption: SheetOptions = {
      height: params.height,
      preferType: params.preferType,
      backgroundColor: params.backgroundColor ? params.backgroundColor : ($r('sys.color.ohos_dialog_text_alert_transparent')),
      showClose: params.showClose,
      blurStyle: params.blurStyle
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
    if (params.onWillDismiss) {
      sheetOption.onWillDismiss = params.onWillDismiss
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
    try {
      let key = Decimal.random().d[0].toString(36).substring(2, 9)
      if (this.contentNodeMap.has(key)) {
        return this.getUniKey()
      }
      return key
    } catch (e) {
      console.error('ActionSheet', `getUniKey failed: ${e}`);
      return Date.now().toString(36);
    }
  }

  private getLastKey(): string {
    return Array.from(this.contentNodeMap.keys()).pop() || ''
  }
}

const baseActionSheet = new ActionSheet()

export {
  baseActionSheet }

@ComponentV2
struct defaultContent {
  @Param @Require option: ActionSheetParams

  build() {
    customContent({ customBuilder: this.option.customContent })
  }
}

@ComponentV2
struct customContent {
  @BuilderParam customBuilder?: () => void

  build() {
    if (this.customBuilder) {
      this.customBuilder()
    }
  }
}