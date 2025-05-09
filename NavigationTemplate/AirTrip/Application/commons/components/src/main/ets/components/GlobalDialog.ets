import { ComponentContent, promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Constants, DayFormat, getDayLabel, PassengerInfo } from 'common';

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

  // 费用明细的弹框
  static async showDialogForCostDetail(dialogParam: CostDetailDialogParam) {
    if (!GlobalDialog.uiContext) {
      let context = getContext() as common.UIAbilityContext
      const windowStage = context.windowStage
      const mainWindow = await windowStage.getMainWindow()
      GlobalDialog.uiContext = mainWindow.getUIContext()
    }
    let contentNode: ComponentContent<CostDetailDialogParam> =
      new ComponentContent(GlobalDialog.uiContext, wrapBuilder(costDetailDialogComponent), dialogParam);
    // 通过 context 获取 promptAction，用于操作对话框显示
    const promptAction = GlobalDialog.uiContext.getPromptAction()

    //显示弹窗
    await promptAction.openCustomDialog(contentNode, {
      alignment: DialogAlignment.Bottom,
      autoCancel: false,
      transition: TransitionEffect.OPACITY.animation({ duration: 200 })
        .combine(TransitionEffect.translate({ y: 100 })),
      onWillDismiss: (action: DismissDialogAction) => {
        if (action.reason === DismissReason.PRESS_BACK) {
          action.dismiss()
        }
      }
    });

    GlobalDialog.globalDialogInstance = contentNode
  }

  // 订单创建中的弹框
  static async showDialogForCreateOrder(dialogParam: CreateOrderDialogParam) {
    if (!GlobalDialog.uiContext) {
      let context = getContext() as common.UIAbilityContext
      const windowStage = context.windowStage
      const mainWindow = await windowStage.getMainWindow()
      GlobalDialog.uiContext = mainWindow.getUIContext()
    }
    let contentNode: ComponentContent<CreateOrderDialogParam> =
      new ComponentContent(GlobalDialog.uiContext, wrapBuilder(createOrderDialogComponent), dialogParam);
    // 通过 context 获取 promptAction，用于操作对话框显示
    const promptAction = GlobalDialog.uiContext.getPromptAction()

    //显示弹窗
    await promptAction.openCustomDialog(contentNode, {
      alignment: DialogAlignment.Center,
      autoCancel: false,
      onWillDismiss: (action: DismissDialogAction) => {
        if (action.reason === DismissReason.PRESS_BACK) {
        }
      }
    });

    GlobalDialog.globalDialogInstance = contentNode
  }

  // 订单支付页面返回时的弹框
  static async showDialogForPayOrder(dialogParam: PayOrderDialogParam) {
    if (!GlobalDialog.uiContext) {
      let context = getContext() as common.UIAbilityContext
      const windowStage = context.windowStage
      const mainWindow = await windowStage.getMainWindow()
      GlobalDialog.uiContext = mainWindow.getUIContext()
    }
    let contentNode: ComponentContent<PayOrderDialogParam> =
      new ComponentContent(GlobalDialog.uiContext, wrapBuilder(payOrderDialogComponent), dialogParam);
    // 通过 context 获取 promptAction，用于操作对话框显示
    const promptAction = GlobalDialog.uiContext.getPromptAction()

    //显示弹窗
    await promptAction.openCustomDialog(contentNode, {
      alignment: DialogAlignment.Center,
      autoCancel: false,
      onWillDismiss: (action: DismissDialogAction) => {
        if (action.reason === DismissReason.PRESS_BACK) {
        }
      }
    });

    GlobalDialog.globalDialogInstance = contentNode
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
      .width($r('app.float.loading_icon_width_seventyTwo')).height($r('app.float.loading_icon_width_seventyTwo'))
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

// 费用明细弹框UI
@Builder
function costDetailDialogComponent(param: CostDetailDialogParam) {
  Column({space: 14}) {
    BaseDialogHeader({
      title: param.title
    })

    Row({space: 4}) {
      Text('在线支付').fontWeight(400)
      Text('¥' + param.totalCost).fontColor($r('sys.color.ohos_id_color_warning'))
    }
    .width('100%')
    .backgroundColor($r('sys.color.white'))
    .padding(14)
    .borderRadius(6)

    Column({space: 14}) {
      Row() {
        Text('票价').fontSize(13).fontWeight(400).fontColor($r('sys.color.ohos_id_color_text_tertiary'))
        Text('¥'+ param.taxPrice + '*' + param.passengerNum + '人')
          .fontSize(12).fontWeight(400).fontColor($r('sys.color.ohos_id_color_text_tertiary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Divider().color($r('sys.color.comp_divider')).width('100%')
      Row() {
        Text('机建费').fontSize(13).fontWeight(400).fontColor($r('sys.color.ohos_id_color_text_tertiary'))
        Text('¥'+ param.airportConstructionPrice + '*' + param.passengerNum + '人')
          .fontSize(12).fontWeight(400).fontColor($r('sys.color.ohos_id_color_text_tertiary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Divider().color($r('sys.color.comp_divider')).width('100%')
      Row() {
        Text('燃油费').fontSize(13).fontWeight(400).fontColor($r('sys.color.ohos_id_color_text_tertiary'))
        Text('¥'+ param.fuelPrice + '*' + param.passengerNum + '人')
          .fontSize(12).fontWeight(400).fontColor($r('sys.color.ohos_id_color_text_tertiary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(14)
    .backgroundColor($r('sys.color.white'))
    .borderRadius(6)
  }
  .alignItems(HorizontalAlign.Start)
  .width('100%')
  .height('70%')
  .padding({left: 14, right: 14, bottom: px2vp(91)})
  .backgroundColor('#fff5f3f3')
  .borderRadius(10)
}

// 订单创建中的弹框UI
@Builder
function createOrderDialogComponent(param: CreateOrderDialogParam) {
  Column({space: 14}) {
    Row() {
      Text('请确认订单信息')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .padding(20)
    }
    .width(Constants.FULL_PERCENT_WIDTH)
    .justifyContent(FlexAlign.Center)

    Scroll() {
      Column({space: 14}) {
        Row() {
          Row({space: 8}) {
            Text('单程')
              .fontSize(12)
              .fontColor($r('sys.color.white'))
              .padding({
                left: 4,
                right: 4,
                top: 2,
                bottom: 2,
              })
              .backgroundColor('#466DFA')
              .borderRadius(3);
            Text(`${param.departureCity} - ${param.destinationCity}`)
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
          }
          if (param.okList[0]) {
            Image($r('app.media.ic_selected')).width(14).height(14)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text(`${new DayFormat(new Date(param.takeoffTime)).format('YYYY-MM-DD')} ${getDayLabel(new Date(param.takeoffTime))}`)
            .fontSize(13).fontWeight(400).fontColor($r('sys.color.ohos_id_color_text_tertiary'))
          if (param.okList[1]) {
            Image($r('app.media.ic_selected')).width(14).height(14)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text(`${param.takeoffTime.split(' ')[1]} 出发`)
            .fontSize(13).fontWeight(400).fontColor($r('sys.color.ohos_id_color_text_tertiary'))
          if (param.okList[2]) {
            Image($r('app.media.ic_selected')).width(14).height(14)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Text('乘机人').fontWeight(400)
        List({space: 12}) {
          ForEach(JSON.parse(param.passengerList), (item: PassengerInfo) => {
            if (item) {
              ListItem() {
                Row() {
                  Text() {
                    Span(item.name).fontWeight(400).fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                    Span(' ')
                    Span(item.certificateNo).fontWeight(400).fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                  }
                  if (param.okList[3]) {
                    Image($r('app.media.ic_selected')).width(14).height(14)
                  }
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
              }
            }
          })
        }
        .width('100%')
        .height(80)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)

        Divider().color($r('sys.color.comp_divider')).width('100%')

        Row({space: 10}) {
          if (param.okList.every((isOk: boolean) => isOk)) {
            Button({ type: ButtonType.Capsule, stateEffect: true }) {
              Text('查看订单').fontSize(16).fontColor('#466DFA').fontWeight(FontWeight.Medium)
            }
            .padding({left: 16, top: 8, bottom: 8, right: 16 })
            .backgroundColor('#F3F3F3')
            .onClick(() => {
              param.view && param.view()
            })

            Button({ type: ButtonType.Capsule, stateEffect: true }) {
              Text('去支付').fontSize(16).fontColor($r('sys.color.white')).fontWeight(FontWeight.Medium)
            }
            .padding({left: 16, top: 8, bottom: 8, right: 16 })
            .backgroundColor('#466DFA')
            .onClick(() => {
              param.pay && param.pay()
            })
          } else {
            LoadingProgress().color($r('sys.color.icon_secondary')).width(32).height(32)
            Text('订单生成中，请稍等...')
              .fontSize(16)
              .fontColor('#99000000')
              .fontWeight(FontWeight.Medium)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .align(Alignment.TopStart)
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }
  .alignItems(HorizontalAlign.Start)
  .width('88%')
  .constraintSize({maxHeight: '45%'})
  .padding({left: 12, right: 12})
  .backgroundColor($r('sys.color.white'))
  .borderRadius(16)
}

// 订单支付页面返回时弹框UI
@Builder
function payOrderDialogComponent(param: PayOrderDialogParam) {
  Column() {
    BaseDialogHeader({
      title: '温馨提示',
      showClose: false
    })

    Text('请您尽快完成支付，若退出后，您可以前往个人中心-待支付订单内继续支付').margin({top: 6})
      .fontWeight(400)
      .fontSize(13)
      .fontColor($r('sys.color.ohos_id_color_text_primary'))

    Divider().color($r('sys.color.comp_divider')).width('100%').margin({top: 14})

    Row() {
      Text('狠心离开').fontColor($r('sys.color.ohos_id_color_text_tertiary')).fontWeight(400).fontSize(13)
        .padding(14)
        .onClick(() => {
          param.exit && param.exit()
        })
      Divider().strokeWidth(0.5).color($r('sys.color.ohos_id_color_button_divider')).height(14).vertical(true)
      Text('继续支付').fontColor($r('sys.color.ohos_id_color_emphasize')).fontWeight(400).fontSize(13)
        .padding(14)
        .onClick(() => {
          param.pay && param.pay()
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
  .alignItems(HorizontalAlign.Start)
  .width('80%')
  .constraintSize({maxHeight: '50%'})
  .padding({left: 14, right: 14})
  .backgroundColor($r('sys.color.white'))
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

