import { RouteEntryVM } from 'common'
import { promptAction } from '@kit.ArkUI';

@Builder
export function ActivateCloudCardBuilder() {
  ActivateCloudCard()
}

@Component
export struct ActivateCloudCard {
  @StorageLink('cloudCard') cloudCard: boolean = AppStorage.get('cloudCard') ?? false;
  @StorageLink('trueName') trueName: string = '';
  @StorageLink('phoneNumber') phoneNumber: string = '';
  @StorageLink('certificateNumber') certificateNumber: string = '';
  @State certificateType: string = '请选择证件类型';
  private select: number | number[] = 0
  private selectCertificateType: string[] =
    ['居民身份证', '港澳居民来往内地通行证', '台湾居民来往大陆通行证', '外国人永久居留身份证']
  @State isTreatyAgree: boolean = false
  vm: RouteEntryVM = RouteEntryVM.instance;

  clickLogInButton(): void {
    // 先勾选协议
    if (!this.isTreatyAgree) {
      promptAction.showToast({
        message: '请阅读并勾选协议',
        duration: 1500,
        bottom: '80vp',
      });
      return;
    }
  }

  build() {
    NavDestination() {
      Column() {
        Stack({ alignContent: Alignment.Top }) {
          Image($r('app.media.activate_card'))
            .height('371lpx')
            .width('360lpx')
          Column() {
            Row() {
              Checkbox({ name: 'agreement' })
                .selectedColor($r('app.color.system_color_green'))
                .shape(CheckBoxShape.CIRCLE)
                .unselectedColor($r('app.color.system_color_green'))
                .width(20)
                .height(20)
                .select(this.isTreatyAgree)
                .onChange((value) => this.isTreatyAgree = value);
              Text() {
                Span('查看')
                  .fontSize(12)
                Span($r('app.string.permissionAgreement'))
                  .fontColor('#0A59F7')
                  .fontSize(12)
                  .onClick(()=>{
                    this.vm.toRouteDetail('PrivacyPolicyDetailPage')
                  })
                Span('，授权一卡通电子卡获取您的姓名、手机号、证件类型、证件号用于实名领卡')
                  .fontSize(12)
              }
              .width(275)
              .margin({ left: 6 })
            }
            .margin({
              left: 14,
              right: 14,
              top: 12,
              bottom: 29
            })

            Row() {
              Text('姓名')
                .width(70)
              TextInput({ text: $$this.trueName, placeholder: '请填写姓名' })
                .caretColor($r('app.color.system_color_green'))
                .backgroundColor($r('sys.color.comp_background_list_card'))
                .margin({ left: '8vp' })
                .maxLength(6)
                .width(200)
                .type(InputType.USER_NAME)
            }

            Divider()
              .margin({ top: '4vp', left: '12vp', right: '12vp' })
              .strokeWidth('1px').color($r('sys.color.ohos_id_color_list_separator'))

            Row() {
              Text('手机号码')
                .width(70)
              TextInput({ text: $$this.phoneNumber, placeholder: '请填写手机号' })
                .caretColor($r('app.color.system_color_green'))
                .backgroundColor($r('sys.color.comp_background_list_card'))
                .margin({ left: '8vp' })
                .maxLength(11)
                .width(200)
                .type(InputType.PhoneNumber)
            }

            Divider()
              .margin({ top: '4vp', left: '12vp', right: '12vp' })
              .strokeWidth('1px').color($r('sys.color.ohos_id_color_list_separator'))

            Row() {
              Text('证件类型')
                .width(70)
              Text(this.certificateType)
                .onClick(() => {
                  TextPickerDialog.show({
                    // 建议使用 this.getUIContext().showTextPickerDialog()接口
                    range: this.selectCertificateType,
                    selected: this.select,
                    selectedTextStyle: {
                      color: $r('app.color.system_color_green'),
                      font: { size: 20, weight: FontWeight.Medium }
                    },
                    onAccept: (value: TextPickerResult) => {
                      // 设置select为按下确定按钮时候的选中项index，这样当弹窗再次弹出时显示选中的是上一次确定的选项
                      this.select = value.index
                      console.log(this.select + '')
                      // 点击确定后，被选到的文本数据展示到页面
                      this.certificateType = value.value as string
                      console.info('TextPickerDialog:onAccept()' + JSON.stringify(value))
                    }
                  })
                })
                .width(184)
                .margin({ left: 24, top: 8, bottom: 8 })
            }

            Divider()
              .margin({ top: '4vp', left: '12vp', right: '12vp' })
              .strokeWidth('1px').color($r('sys.color.ohos_id_color_list_separator'))

            Row() {
              Text('证件号')
                .width(70)
              TextInput({ text: $$this.certificateNumber, placeholder: '请填写证件号' })
                .caretColor($r('app.color.system_color_green'))
                .backgroundColor($r('sys.color.comp_background_list_card'))
                .margin({ left: '8vp' })
                .maxLength(18)
                .width(200)
                .type(InputType.Normal)
            }

            Divider()
              .margin({ top: '4vp', left: '12vp', right: '12vp' })
              .strokeWidth('1px').color($r('sys.color.ohos_id_color_list_separator'))

            Row() {
              Checkbox({ name: 'freePasswordPayment' })
                .selectedColor($r('app.color.system_color_green'))
                .shape(CheckBoxShape.CIRCLE)
                .onChange((value: boolean) => {
                  console.info('Checkbox1 change is' + value)
                })
                .unselectedColor($r('app.color.system_color_green'))
                .width(20)
                .height(20)
              Text('免密支付')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
            }
            .width('90%')
            .margin({ top: 16 })
            .align(Alignment.TopStart)

            Button('同意协议并领卡')
              .height(40)
              .width(312)
              .backgroundColor($r('app.color.system_color_green'))
              .margin({ top: 75 })
              .onClick(() => {
                if (this.isTreatyAgree === false) {
                  this.clickLogInButton()
                } else if (this.trueName && this.phoneNumber.length === 11 && this.certificateNumber.length === 18) {
                  this.cloudCard = true;
                  this.vm.pop()
                } else {
                  promptAction.showToast({
                    message: '请完善信息',
                    duration: 1500,
                    bottom: '80vp',
                  });
                }
              })
          }
          .align(Alignment.TopStart)
          .height(439)
          .width(328)
          .margin({ top: 302, bottom: 10 })
          .backgroundColor($r('sys.color.white'))
          .borderRadius(16)
        }
        .backgroundColor('#F5F5F5')
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(false)
    .title('开通电子卡')
  }
}