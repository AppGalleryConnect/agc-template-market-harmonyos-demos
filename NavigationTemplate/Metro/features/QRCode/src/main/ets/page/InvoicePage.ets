import { common } from '@kit.AbilityKit';
import { allCancel, invoiceManagement, invoiceTitle, MainEntryVM, recordingList, RecordingList } from 'commonlib';
import { recordingComponent } from '../components/recordingComponent';
import { invoiceAssistant } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BaseTitle } from 'componentlib';

@Builder
export function InvoicePageBuilder(name: string, param: Object) {
  InvoicePage()
}

@CustomDialog
@Component
struct CustomDialogExample {
  @Link textValue: string;
  emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
  controller?: CustomDialogController;
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  build() {
    Column() {
      Text('请输入邮箱').fontSize(16).margin({ top: 12, bottom: 12 })
      TextInput({ placeholder: '', text: this.textValue }).height(45).width('70%')
        .onChange((value: string) => {
          this.textValue = value;
        })
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('取消')
          .fontColor($r('app.color.font_gray'))
          .backgroundColor($r('app.color.background_white'))
          .onClick(() => {
            if (this.controller !== undefined) {
              this.controller.close();
              this.cancel();
            }
          })
        Button('确认')
          .onClick(() => {
            if (this.emailRegex.test(this.textValue)) {
              AlertDialog.show(
                {
                  message: '已发送至邮箱',
                  autoCancel: true,
                  alignment: DialogAlignment.Center,
                  primaryButton: {
                    value: '关闭',
                    action: () => {
                      this.textValue = ''
                      if (this.controller !== undefined) {
                        this.controller.close();
                        this.cancel();
                      }
                      console.info('Callback when the first button is clicked')
                    }
                  },
                }
              )} else {
              AlertDialog.show(
                {
                  message: '请输入正确邮箱',
                  autoCancel: true,
                  alignment: DialogAlignment.Center,
                  primaryButton: {
                    value: '关闭',
                    action: () => {
                      console.info('Callback when the first button is clicked')
                    }
                  },
                })
            }
          })
          .fontColor($r('app.color.orange'))
          .backgroundColor($r('app.color.background_white'))
      }
      .margin({ bottom: 12,top:12 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .height(160)
    .width(328)
  }
}

@Component
export struct InvoicePage {
  @State textValue: string = ''
  dialogController: CustomDialogController | null = new CustomDialogController({
    width:328,
    backgroundColor:$r('app.color.background_color_white'),
    builder: CustomDialogExample({
      cancel: () => {

      },
      confirm: () => {

      },
      textValue: this.textValue,

    }),

    autoCancel: true,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss();
      }
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss();
      }
    },
    alignment: DialogAlignment.Center,
    // offset: { dx: 0, dy: -300 },
    gridCount: 4,
    customStyle: false,
    cornerRadius: 10,
  })
  @State invoiceTitle: invoiceTitle = invoiceManagement
  @State totalSelected: number = 0
  @State radioIndex: number = 0
  @State totalPrice: number = 0
  @State listItem: RecordingList[] = recordingList[0]
  @State selectAll: boolean = false
  context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  vm: MainEntryVM = MainEntryVM.instance;

  aboutToAppear(): void {
    this.invoiceTitle = invoiceManagement

  }

  aboutToDisappear() {
    this.dialogController = null;
    allCancel()
  }

  @Builder
  InvoiceBuilder() {
    Text('开发票')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Medium)
  }

  build() {
    NavDestination() {
      BaseTitle({
        customTitle: () => {
          this.InvoiceBuilder()
        },
        showBackBtn: true,
        onBack: () => {
          this.vm.navStack.pop()
        },
      });

      Column() {
        Column() {
          Row() {
            Image($r('app.media.voice'))
              .width('12')
              .height('12')
              .margin({ left: 14 })
            Marquee({
              start: true,
              step: 5,
              loop: 0,
              fromStart: true,
              src: this.context.resourceManager.getStringSync($r('app.string.bill_voice'))
            })
              .height(14)
              .width(287)
              .fontColor($r('app.color.bill_voice_font_color'))
              .fontSize(10)
              .margin({ left: 10 })
          }
          .backgroundColor($r('app.color.bill_voice_background_color'))
          .borderRadius(12)
          .height(24)
          .width('100%')

          Row() {
            Text(this.invoiceTitle.title)
              .fontSize(16)
              .fontColor($r('app.color.tab_font_color'))
              .fontWeight(FontWeight.Bold)
              .margin({ left: 12 })
          }
          .height(45)
          .margin({ top: 12 })
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .width('100%')
          .borderRadius(16)
          .backgroundColor($r('app.color.background_color_white'))

          Row() {
            Row() {
              Image($r('app.media.bill'))
                .width(20)
                .height(16)
              Text('发票信息管理')
                .margin({ left: 6 })
              Image($r('app.media.right_arrow'))
                .margin({ left: 165 })
                .width(15)
                .height(15)
                .onClick(() => {
                  // 执行请求
                  if (canIUse('SystemCapability.HuaweiID.InvoiceAssistant')) {
                    try {
                      invoiceAssistant.selectInvoiceTitle(
                        getContext(this)).then((data: invoiceAssistant.InvoiceTitle) => {
                        hilog.info(0x0000, 'testTag', 'Succeeded in selecting invoice title');
                        invoiceManagement.type = data.type;
                        invoiceManagement.title = data.title;
                        invoiceManagement.taxNumber = data.taxNumber;
                        invoiceManagement.companyAddress = data.companyAddress;
                        invoiceManagement.telephone = data.telephone;
                        invoiceManagement.bankName = data.bankName;
                        invoiceManagement.bankAccount = data.bankAccount;
                        this.invoiceTitle = invoiceManagement
                      }).catch((error: BusinessError<Object>) => {
                      })
                    } catch (error) {
                    }
                  } else {
                    hilog.info(0x0000, 'testTag',
                      'The current device does not support the invoking of the selectInvoiceTitle interface.');
                  }
                })
            }
            .margin({ left: 14 })
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
          }
          .margin({ top: 12 })
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .width('100%')
          .height(44)
          .borderRadius(16)
          .backgroundColor($r('app.color.background_color_white'))

          recordingComponent({
            isBill: true,
            totalSelected: this.totalSelected,
            totalPrice: this.totalPrice,
            listItem: this.listItem,
            selectAll: this.selectAll
          })
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .width(328)

        Column() {
          Row() {
            Text(this.totalSelected + ' ').fontColor($r('app.color.orange'))
            Text('个行程，共 ')
            Text(this.totalPrice + '').fontColor($r('app.color.orange'))
            Text(' 元')
          }
          .margin({ left: 55, top: 12 })
          .width('100%')

          Divider().margin({ top: 12 })
          Row() {
            Checkbox()
              .onClick(() => {
                this.selectAll = !this.selectAll
                this.listItem.forEach((item) => {
                  item.checked = this.selectAll
                })
              })
              .select(this.selectAll)
              .margin({ left: 25 })

            Row() {
              Text('立即开票')
                .fontSize(14)
                .fontColor($r('app.color.background_white'))
            }
            .borderRadius(16)
            .backgroundColor($r('app.color.bill_voice_font_color'))
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .height(32)
            .width(80)
            .margin({ right: 25 })
            .onClick(() => {
              if (this.totalPrice === 0) {
                AlertDialog.show(
                  {
                    message: '请至少选择一张票',
                    autoCancel: true,
                    alignment: DialogAlignment.Center,
                    primaryButton: {
                      value: '关闭',
                      action: () => {
                        console.info('Callback when the first button is clicked')
                      }
                    },
                  }
                )
              } else {
                if (this.dialogController !== null) {
                  this.dialogController.open();
                }
              }
            })
          }
          .margin({ top: 12 })
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .backgroundColor($r('app.color.background_color_white'))
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .backgroundColor($r('app.color.background_color'))
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}