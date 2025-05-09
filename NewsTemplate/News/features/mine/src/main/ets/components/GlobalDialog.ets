import { ComponentContent, promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

// dialog头部
@ComponentV2
struct BaseDialogHeader {
  @Param title: ResourceStr = ''
  @Param showClose: boolean = true
  @Event close: () => void

  build() {
    RelativeContainer() {
      Text(this.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .padding(14)
        .id('title')
        .alignRules({
          middle: { 'anchor': '__container__', 'align': HorizontalAlign.Center },
          center: { 'anchor': '__container__', 'align': VerticalAlign.Center },
        })

      if (this.showClose) {
        Column() {
          Image($r('app.media.ic_close')).width(16).height(16)
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.End)
        .id('close')
        .alignRules({
          right: { 'anchor': '__container__', 'align': HorizontalAlign.End },
          center: { 'anchor': '__container__', 'align': VerticalAlign.Center },
        })
        .onClick(() => {
          this.close && this.close()
        })
      }
    }
    .width('100%')
    .height(48)
  }
}

// Loading弹框的参数
export interface LoadingDialogParam {
  text?: ResourceStr,
  maskColor?: ResourceColor,
  maskRect?: Rectangle,
}

// 费用明细弹框参数
export interface CostDetailDialogParam {
  title: ResourceStr,
  totalCost: string,
  taxPrice: string,
  airportConstructionPrice: string,
  fuelPrice: string,
  passengerNum: number
}

// 订单创建弹框参数
export interface CreateOrderDialogParam {
  okList: boolean[],
  departureCity: ResourceStr, // 出发城市
  destinationCity: ResourceStr, // 目的城市
  takeoffTime: string, // 出发时间
  passengerList: string, // 乘客
  view?: () => void // 查看订单
  pay?: () => void // 去支付
}

// 离开支付页面弹框参数
export interface PayOrderDialogParam {
  exit: () => void
  pay: () => void
}

// 带有输入框的弹框参数
export interface GlobalDialogWithInputParam {
  hint: string //标题
  content: string // 输入框的内容
  textLength?: number,
  textType?: string,
  placeholder: string // 输入框的提示文案
  but1Name: string
  but2Name: string
  onConfirm: (value?: string) => void //确认按钮的回调函数
  onCancel: () => void // 取消按钮的回调函数
}

// 纯文本提示的弹框参数
export interface TextPromptDialogParam {
  title?: string,
  content: string,
  primaryButName: string,
  primaryButAction: () => void
  secondaryButName: string,
  secondaryButAction: () => void
}

export class GlobalDialog {
  static uiContext: UIContext;
  static globalDialogInstance?: ComponentContent<Object>;

  // 全局Loading弹框
  static async showLoadingDialog(dialogParam: LoadingDialogParam = {}): Promise<void> {
    if (!GlobalDialog.uiContext) {
      let context = getContext() as common.UIAbilityContext
      const windowStage = context.windowStage
      const mainWindow = await windowStage.getMainWindow()
      GlobalDialog.uiContext = mainWindow.getUIContext()
    }

    let contentNode: ComponentContent<LoadingDialogParam> =
      new ComponentContent(GlobalDialog.uiContext, wrapBuilder(loadingDialogBuilder), dialogParam);
    // 通过 context 获取 promptAction，用于操作对话框显示
    const promptAction = GlobalDialog.uiContext.getPromptAction()

    //显示弹窗
    await promptAction.openCustomDialog(contentNode, {
      alignment: DialogAlignment.Center, //对话框在屏幕中央显示
      autoCancel: false, //点击弹窗外区域是否取消弹窗
      maskColor: Color.Transparent,
      maskRect: dialogParam?.maskRect,
      onWillDismiss: (action: DismissDialogAction) => {
        if (action.reason === DismissReason.PRESS_BACK) {
          action.dismiss()
        }
      }
    });

    GlobalDialog.globalDialogInstance = contentNode
  }

  // toast提示
  static showToast(error: BusinessError | string) {
    const message: string = typeof error === 'string' ? error : error.message
    promptAction.showToast({
      message,
      duration: 2000,
      alignment: Alignment.Center,
      textColor: Color.White,
      backgroundColor: '#333333',
      backgroundBlurStyle: BlurStyle.NONE
    });
  }

  // 带有输入框的dialog
  static async showDialogWithInputBox(dialogParam: GlobalDialogWithInputParam) {
    if (!GlobalDialog.uiContext) {
      let context = getContext() as common.UIAbilityContext
      const windowStage = context.windowStage
      const mainWindow = await windowStage.getMainWindow()
      GlobalDialog.uiContext = mainWindow.getUIContext()
    }
    if (!dialogParam.but1Name) {
      dialogParam.but1Name = '取消';
    }
    if (!dialogParam.but2Name) {
      dialogParam.but2Name = '确定';
    }
    let contentNode: ComponentContent<GlobalDialogWithInputParam> =
      new ComponentContent(GlobalDialog.uiContext, wrapBuilder(buildInputBoxComponent), dialogParam);

    const promptAction = GlobalDialog.uiContext.getPromptAction()
    //显示弹窗
    await promptAction.openCustomDialog(contentNode, {
      alignment: DialogAlignment.Center, //对话框在屏幕中央显示
      autoCancel: false, //点击弹窗外区域是否取消弹窗
    });
    GlobalDialog.globalDialogInstance = contentNode
  }

  // 纯文本的dialog
  static async showTextDialog(dialogParam: TextPromptDialogParam) {
    if (!GlobalDialog.uiContext) {
      let context = getContext() as common.UIAbilityContext
      const windowStage = context.windowStage
      const mainWindow = await windowStage.getMainWindow()
      GlobalDialog.uiContext = mainWindow.getUIContext()
    }
    let contentNode: ComponentContent<TextPromptDialogParam> =
      new ComponentContent(GlobalDialog.uiContext, wrapBuilder(buildTextBoxComponent), dialogParam);

    const promptAction = GlobalDialog.uiContext.getPromptAction()
    //显示弹窗
    await promptAction.openCustomDialog(contentNode, {
      alignment: DialogAlignment.Center, //对话框在屏幕中央显示
      autoCancel: false, //点击弹窗外区域是否取消弹窗
    });
    GlobalDialog.globalDialogInstance = contentNode
  }

  //关闭弹窗
  static async close() {
    if (!GlobalDialog.uiContext) {
      return
    }
    const promptAction = GlobalDialog.uiContext.getPromptAction()
    if (GlobalDialog?.globalDialogInstance) {
      await promptAction.closeCustomDialog(GlobalDialog.globalDialogInstance)
    }

    GlobalDialog.globalDialogInstance = undefined
  }
}
// loading弹框的UI
@Builder
function loadingDialogBuilder(param: LoadingDialogParam) {
  Column() {
    LoadingProgress()
      .color($r('sys.color.icon_on_primary'))
      .width(72).height(72)
    Text(param?.text)
      .fontSize(13)
      .fontColor($r('sys.color.white'))
  }
  .width(90)
  .height(90)
  .padding(5)
  .justifyContent(FlexAlign.Center)
  .backgroundColor(Color.Black)
  .borderRadius(6)
}

// 带有输入框的UI
@Builder
function buildInputBoxComponent(param: GlobalDialogWithInputParam) {
  Column({ space: 14 }) {
    Text(param?.hint)
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.ohos_id_color_text_primary') )

    TextInput({ text: param.content, placeholder: param.placeholder })
      .placeholderColor($r('sys.color.font_secondary'))
      .placeholderFont({ size: $r('sys.float.Body_L'), weight: 400 })
      .type(param.textType === 'phone' ? InputType.Number : InputType.Normal)
      .height(54)
      .maxLength(param.textLength || 12)
      .layoutWeight(1)
      .backgroundColor($r('sys.color.ohos_id_background_secondary'))
      .caretColor($r('sys.color.font_emphasize'))
      .onChange((value: string) => {
        param.content = value
      })

    Row() {
      Text(param?.but1Name)
        .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
        .onClick(() => {
          param.onCancel();
        })
        .textAlign(TextAlign.Center)
        .padding({ top: 10 })
        .width('40%')

      Text(param?.but2Name)
        .fontColor('#466DFA')
        .onClick(() => {
          param.onConfirm(param.content);
        })
        .padding({ top: 10 })
        .textAlign(TextAlign.Center)
        .width('40%')
    }
  }
  .width('calc(100% - 32vp)')
  .padding(20)
  .height(150)
  .backgroundColor(Color.White)
  .borderRadius(16)
}

// 确认弹框
@Builder
function buildTextBoxComponent(param: TextPromptDialogParam) {
  Column({ space: 18 }) {
    Text(param?.title)
      .fontSize(20)
      .fontColor($r('sys.color.ohos_id_color_text_primary') )
      .fontWeight(FontWeight.Medium)
    Text(param.content).fontWeight(FontWeight.Regular).fontSize(14)
    Row() {
      Text(param.secondaryButName)
        .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
        .onClick(() => {
          param.secondaryButAction();
        })
        .textAlign(TextAlign.Center)
        .padding({ top: 10 })
        .width('40%')

      Text(param.primaryButName)
        .fontColor('#466DFA')
        .onClick(() => {
          param.primaryButAction();
        })
        .padding({ top: 10 })
        .textAlign(TextAlign.Center)
        .width('40%')
    }
  }
  .width('calc(100% - 32vp)')
  .padding(20)
  .height(140)
  .backgroundColor(Color.White)
  .borderRadius(16)
}

