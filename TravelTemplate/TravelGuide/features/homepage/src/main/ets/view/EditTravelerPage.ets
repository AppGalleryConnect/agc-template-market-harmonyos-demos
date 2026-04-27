import { TValueType } from 'common';
import { TravelerModel } from 'common_travel_guide';
import { phoneRouterControl } from 'oh_router';

@Builder
export function EditTravelerPageBuilder(param: TValueType) {
  EditTravelerPage({
    pageParam: param
  })
}


@ComponentV2
export struct EditTravelerPage {
  @Param pageParam: TValueType = null
  @Local vmEdit: TravelerModel = this.pageParam as TravelerModel
  @Local idCardDisplayText: string = ''
  vm: TravelerModel = new TravelerModel()
  private uiContext: UIContext = this.getUIContext();

  private showToast(msg: string): void {
    this.uiContext.getPromptAction().showToast({ message: `Test: ${msg}` });
  }

  aboutToAppear() {
    if(this.vmEdit.idNumber){
      this.idCardDisplayText = this.maskedIdCard(this.vmEdit.idNumber)
    }
  }

  maskedIdCard(idCard: string) {
    return idCard.replace(/^(\d{4})\d+(\d{3})$/, '$1******$2');
  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .width('100%')
    .padding({ left: 16, right: 16, top: 44 })
    .backgroundColor('#F1F3F5')

  }

  /**
   * 校验身份证
   * @param idCode
   * @returns
   */
  isValidChineseID(idCode: string) {
    const iDCodeReg = /^[1-9]\d{5}(19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}[\dX]$/;
    return iDCodeReg.test(idCode)
  }

  regPhone(phone:string){
    const phoneRegex = /^1(?:3[0-9]|4[014-9]|5[0-35-9]|6[2567]|7[0-8]|8[0-9]|9[0-35-9])\d{8}$/;
    return phoneRegex.test(phone)
  }

  @Builder
  render() {
    Column() {
      Row() {
        Image($r('app.media.leftReturn'))
          .width(40)
          .height(40)
          .onClick(() => {
            phoneRouterControl.popPage()
            return true
          })
        Text('编辑出行人')
          .fontSize(20)
          .fontColor('#000')
          .margin({ left: 8 })
      }
      .width('100%')
      .margin({ bottom: 18 })

      Column() {
        Row() {
          Text('姓名')
            .fontSize(14)
            .width(56)
            .textAlign(TextAlign.Start)
          TextInput({ text: this.vmEdit.name, placeholder: '请填写姓名' })
            .width(216)
            .backgroundColor('rgba(0, 0, 0, 0)')
            .onChange((event: string) => {
              this.vmEdit.name = event
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text('证件号码')
            .fontSize(14)
            .width(56)
            .textAlign(TextAlign.Start)
          TextInput({
            text: this.idCardDisplayText,
            placeholder: '请填写证件号码'
          })
            .width(216)
            .backgroundColor('rgba(0, 0, 0, 0)')
            .onChange((event: string) => {
              this.idCardDisplayText = event
              this.vmEdit.idNumber = event
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text('手机号')
            .fontSize(14)
            .textAlign(TextAlign.Start)
            .width(56)
          TextInput({ text: this.vmEdit.phone, placeholder: '请填写手机号' })
            .width(216)
            .type(InputType.PhoneNumber)
            .backgroundColor('rgba(0, 0, 0, 0)')
            .onChange((event: string) => {
              this.vmEdit.phone = event
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .padding(12)
      .height(150)
      .width('100%')
      .borderRadius(16)
      .backgroundColor('#ffffff')

      Row() {
        Text('保存')
          .fontSize(18)
          .fontColor('#333')
          .textAlign(TextAlign.Center)
          .width('100%')
      }
      .onClick(() => {
        if(!this.vmEdit.name){
          this.showToast('请输入您的姓名');
          return
        }
        if (!this.isValidChineseID(this.vmEdit.idNumber)) {
          this.showToast('身份正格式错误');
          return
        }
        if(!this.regPhone(this.vmEdit.phone)){
          this.showToast('手机号格式错误');
          return
        }
        this.vmEdit.show = 0
        phoneRouterControl.popPage({
          popData: this.vmEdit
        })
      })
      .width('100%')
      .borderRadius(24)
      .margin({ top: 76, bottom: 10 })
      .height(42)
      .backgroundColor('#FEE231')

      Row() {
        Text('删除')
          .textAlign(TextAlign.Center)
          .width('100%')
          .fontSize(18)
          .fontColor('#FF4A26')
      }
      .onClick(() => {
        this.vmEdit.show =1
        phoneRouterControl.popPage({
          popData: this.vmEdit
        })
        return true
      })
      .borderRadius(24)
      .width('100%')
      .height(42)
      .backgroundColor('#EAECED')

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}