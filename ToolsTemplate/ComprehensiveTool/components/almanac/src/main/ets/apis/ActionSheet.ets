import { ComponentContent, window } from '@kit.ArkUI';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

/**
 * ActionSheetOption 类型
 */
class ActionSheetOption {
  uiContext: UIContext | null = null;
  /**
   * 模态框id
   */
  id?: string = '';
  /**
   * 原生标题
   */
  title?: SheetTitleOptions | CustomBuilder;
  /**
   * 半模态页面的样式
   */
  preferType?: SheetType;
  /**
   * 高度
   */
  height?: SheetSize | Length;
  /**
   * 半模态页面的切换高度档位
   */
  detents?: [(SheetSize | Length), (SheetSize | Length)?, (SheetSize | Length)?];
  /**
   * 是否显示原生关闭图标
   */
  showClose?: boolean;
  /**
   * 是否显示关闭图标
   */
  closeable?: boolean;
  /**
   * 自定义内容
   */
  customContent?: () => void = () => {
  };
  /**
   * 打开回调
   */
  onOpen?: () => void;
  /**
   * 背景
   */
  backgroundColor?: ResourceStr = '';
  /**
   * 点击取消回调
   */
  onCancel?: () => void;
  /**
   * 关闭回调
   */
  onClose?: () => void;
  onWillAppear?: () => void;
}

class ActionSheetParams extends ActionSheetOption {
  close: (id: string) => void = () => {
  };
  id: string = '';

  constructor(option: ActionSheetOption) {
    super();
    this.height = option.height || SheetSize.FIT_CONTENT;
    this.detents = option.detents;
    this.title = option.title;
    this.showClose = option.showClose;
    this.backgroundColor = option.backgroundColor;
    this.preferType = option.preferType || SheetType.BOTTOM;
    this.customContent = option.customContent || undefined;
    this.closeable = option.closeable !== undefined ? option.closeable : true;
    this.onOpen = option.onOpen || undefined;
    this.onClose = option.onClose || undefined;
    this.onCancel = option.onCancel || undefined;
    this.onWillAppear = option.onWillAppear || undefined;
  }
}

interface contentNodeMapVal {
  params: ActionSheetParams;
  content: ComponentContent<ActionSheetParams>;
}

class ActionSheet {
  private contentNodeMap: Map<string, contentNodeMapVal> = new Map();
  private uiContext: UIContext | null = null;

  /*
   * 展示actionSheet
   */
  public async show(option: ActionSheetOption) {
    let sheetKey = option.id ?? await this.getUniKey();
    this.uiContext = option.uiContext
    if (this.uiContext === null) {
      return ''
    }
    let params = new ActionSheetParams(option);
    params.id = sheetKey;
    params.close = (id: string): Promise<void> => this.close(id);
    let contentNode = new ComponentContent(this.uiContext, wrapBuilder(defaultBuilder), params);
    let sheetOptions: SheetOptions = {
      height: params.height,
      keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
      preferType: params.preferType,
      backgroundColor: params.backgroundColor ? params.backgroundColor : ($r('sys.color.background_primary')),
      showClose: params.showClose,
      detents: params.detents,
      onWillDismiss: async (dismissSheetAction: DismissSheetAction) => {
        // 0: 点击三键back、左滑/右滑、键盘ESC; 1 点击蒙层;  3: 跟手拖拽
        const dismissReason = dismissSheetAction.reason;
        if (dismissReason === DismissReason.SLIDE_DOWN) {
          return;
        }
        dismissSheetAction.dismiss();
      },
      onWillAppear: () => {
        params.onWillAppear?.();
      },
      onDisappear: () => {
        params.onClose?.();
      },
    };
    if (params.title) {
      sheetOptions.title = params.title;
    }
    if (params.detents) {
      sheetOptions.detents = params.detents;
    }
    if (params.backgroundColor) {
      sheetOptions.backgroundColor = params.backgroundColor;
    }
    this.contentNodeMap.set(sheetKey, {
      content: contentNode,
      params: params,
    });
    await this.uiContext.openBindSheet(contentNode, sheetOptions);
    params.onOpen?.();
    return sheetKey;
  }

  /**
   * 关闭actionSheet
   */
  public async close(id?: string) {
    const sheetKey = id || this.getLastKey();
    if (this.contentNodeMap.has(sheetKey)) {
      const val = this.contentNodeMap.get(sheetKey) as contentNodeMapVal;
      this.uiContext?.closeBindSheet(val?.content).then(() => {
        val?.params.onClose?.();
        this.contentNodeMap.delete(sheetKey);
        if (this.contentNodeMap.size === 0) {
          this.uiContext = null;
        }
      });
    }
  }

  private async getRandomValue() {
    let rand = cryptoFramework.createRandom();
    let seed = new Uint8Array([1, 2, 3]);
    rand.setSeed({ data: seed });
    let len = 3;
    let data = '';
    let randOutput = await rand.generateRandom(len);
    for (let i = 0; i < randOutput.data.length; i++) {
      data += randOutput.data[i];
    }
    let res = Number(data) / Math.pow(10, data.length);
    return res;
  }

  private getLastKey(): string {
    return Array.from(this.contentNodeMap.keys()).pop() || '';
  }

  private async getUniKey(): Promise<string> {
    const result = await this.getRandomValue();
    const key = result.toString(36).substring(2, 9);
    if (this.contentNodeMap.has(key)) {
      return this.getUniKey();
    }
    return key;
  }
}

@ComponentV2
struct CustomContent {
  @BuilderParam customBuilder?: () => void;

  build() {
    if (this.customBuilder) {
      this.customBuilder();
    }
  }
}

@ComponentV2
struct DefaultContent {
  @Param @Require option: ActionSheetParams;

  build() {
    CustomContent({ customBuilder: this.option.customContent });
  }
}

@Builder
function defaultBuilder(option: ActionSheetParams) {
  DefaultContent({ option });
}

const baseActionSheet = new ActionSheet();

export { baseActionSheet };