import { Constants } from 'common'
import { phoneRouterControl } from 'oh_router'
import { AddressManagerItem, AddressManagerPageVM } from '../viewmodel/AddressManagerPageVM'
import { promptAction } from '@kit.ArkUI'
import { PhoneValidatorUtil } from '../utils/PhoneValidatorUtil'

@Builder
export function EditAddressPageBuilder(param: Object) {
  EditAddressPage({ selectIconIndex: param as number })
}

@ComponentV2
export struct EditAddressPage {
  private logTag: string = 'EditAddressPage'
  @Local addressManager: AddressManagerPageVM = AddressManagerPageVM.instance
  // 当前的标签下标：-1、> 0
  @Param @Require selectIconIndex: number
  // 本地保存的地址数据
  @Local addressLocal: string = ''
  @Local addressPhoneLocal: string = ''
  @Local addressAreaLocal: string = ''
  @Local addressDetailLocal: string = ''
  @Local addressLabelLocal: string = ''
  // 是否需要设置成默认地址
  @Local isDefaultLocal: boolean = false

  aboutToAppear(): void {
    this.addressManager.addressSelectedIndex = this.selectIconIndex
    // 如果有数据，则赋值
    if (this.addressManager.addressSelectedIndex >= 0) {
      this.addressLocal = this.addressManager.addressList[this.addressManager.addressSelectedIndex].name
      this.addressPhoneLocal = this.addressManager.addressList[this.addressManager.addressSelectedIndex].phone
      this.addressAreaLocal = this.addressManager.addressList[this.addressManager.addressSelectedIndex].area
      this.addressDetailLocal = this.addressManager.addressList[this.addressManager.addressSelectedIndex].detailAddress
      this.addressLabelLocal = this.addressManager.addressList[this.addressManager.addressSelectedIndex].remark
      this.isDefaultLocal = this.addressManager.addressList[this.addressManager.addressSelectedIndex].isDefault
    }
    this.addressManager.selectedTagIndex = this.getSelectedIndex()
  }

  // 标题布局
  @Builder
  private titleLayout() {
    Row() {
      Text('编辑取件地址')
        .fontSize(20)
        .fontColor('rgba(0, 0, 0, 1)')
        .margin({ left: 5 })

      Blank().layoutWeight(1)

      Text('删除')
        .fontSize(14)
        .fontColor('rgba(0, 0, 0, 0.6)')
        .margin({ right: 16 })
    }.width('100%').height(56).alignItems(VerticalAlign.Center).backgroundColor('rgba(255, 255, 255, 1)')
  }

  // 获取选择的标签下标
  getSelectedIndex(): number {
    if (this.addressManager.addressSelectedIndex < 0) {
      return -1
    }
    for (let i = 0; i < this.addressManager.defaultTagArray.length; i++) {
      if (this.addressManager.defaultTagArray[i] ===
      this.addressManager.addressList[this.addressManager.addressSelectedIndex].remark) {
        return i
      }
    }
    return -1
  }

  @Builder
  render() {
    RelativeContainer() {
      Column() {
        // 收货人+手机号
        Column() {
          // 收货人
          Row() {
            Text('收货人')
              .width(48)
              .fontSize(12)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Regular)
              .textAlign(TextAlign.Start)
              .margin({ right: 24 })

            TextInput({ placeholder: '请输入收货人', text: this.addressLocal })
              .placeholderFont({ size: $r('sys.float.Body_L') })
              .placeholderColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.Body_L'))
              .fontColor('rgba(0, 0, 0, 0.9)')
              .fontWeight(FontWeight.Regular)
              .layoutWeight(1)
              .onChange((value: string) => {
                this.addressLocal = value
              })

          }.margin({ left: 12, right: 12 }).height(56).justifyContent(FlexAlign.Start)

          // 分割线
          Row() {
            Divider().layoutWeight(1).margin({ left: 12, right: 12 })
          }.width('100%')

          // 手机号
          Row() {
            Text('手机号')
              .width(48)
              .fontSize(12)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Regular)
              .textAlign(TextAlign.Start)
              .margin({ right: 24 })

            TextInput({ placeholder: '请输入手机号', text: this.addressPhoneLocal })
              .placeholderFont({ size: $r('sys.float.Body_L') })
              .placeholderColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.Body_L'))
              .fontColor('rgba(0, 0, 0, 0.9)')
              .fontWeight(FontWeight.Regular)
              .layoutWeight(1)
              .maxLength(11)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.addressPhoneLocal = value
              })

          }.margin({ left: 12, right: 12 }).height(56).justifyContent(FlexAlign.Start)

        }
        .width('100%')
        .height(112)
        .margin({ top: 12 })
        .border({ radius: 16 })
        .backgroundColor('rgba(255, 255, 255, 1)')

        // 所在地区+详细地址
        Column() {
          // 所在地区
          Row() {
            Text('所在地区')
              .width(48)
              .fontSize(12)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Regular)
              .textAlign(TextAlign.Start)
              .margin({ right: 24 })

            TextInput({ placeholder: '请输入所在地区', text: this.addressAreaLocal })
              .placeholderFont({ size: $r('sys.float.Body_L') })
              .placeholderColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.Body_L'))
              .fontColor('rgba(0, 0, 0, 0.9)')
              .fontWeight(FontWeight.Regular)
              .layoutWeight(1)
              .onChange((value: string) => {
                this.addressAreaLocal = value
              })

          }.margin({ left: 12, right: 12 }).height(56).justifyContent(FlexAlign.Start)

          // 分割线
          Row() {
            Divider().layoutWeight(1).margin({ left: 12, right: 12 })
          }.width('100%')

          // 详细地址
          Row() {
            Text('详细地址')
              .width(48)
              .fontSize(12)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Regular)
              .textAlign(TextAlign.Start)
              .margin({ right: 24 })

            TextInput({ placeholder: '请输入详细地址', text: this.addressDetailLocal })
              .placeholderFont({ size: $r('sys.float.Body_L') })
              .placeholderColor($r('sys.color.font_secondary'))
              .fontSize($r('sys.float.Body_L'))
              .fontColor('rgba(0, 0, 0, 0.9)')
              .fontWeight(FontWeight.Regular)
              .layoutWeight(1)
              .onChange((value: string) => {
                this.addressDetailLocal = value
              })

          }.margin({ left: 12, right: 12 }).height(56).justifyContent(FlexAlign.Start)

        }
        .width('100%')
        .height(112)
        .margin({ top: 12 })
        .border({ radius: 16 })
        .backgroundColor('rgba(255, 255, 255, 1)')

        // 设置默认地址
        Column() {
          // 设置默认地址
          Row() {
            Column() {
              Text('设为默认地址').fontSize(12).fontColor('rgba(0, 0, 0, 0.9)')

              Text('提醒：下单时会优先使用该地址').fontSize(10).fontColor('rgba(0, 0, 0, 0.6)').margin({ top: 2 })
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .padding({ left: 12 })
            .alignItems(HorizontalAlign.Start)

            Toggle({ type: ToggleType.Switch, isOn: this.isDefaultLocal })
              .selectedColor($r('sys.color.comp_background_emphasize'))
              .switchPointColor($r('sys.color.comp_background_primary_contrary'))
              .margin({ right: 12 })
              .onChange((isOn: boolean) => {
                this.isDefaultLocal = isOn
              })

          }
          .width('100%')
          .height(68)

          // 分割线
          Row() {
            Divider().layoutWeight(1).margin({ left: 12, right: 12 })
          }.width('100%')

          // 标签
          Row() {
            // 标签文本
            Text('标签')
              .fontSize(12)
              .fontColor('rgba(0, 0, 0, 0.9)')
              .width(33)
              .height(56)
              .textAlign(TextAlign.Center)
              .margin({ right: 10 })

            // 标签数据
            ForEach(this.addressManager.defaultTagArray, (tag: string, index: number) => {
              Row() {
                Text(tag)
                  .fontSize(12)
                  .fontColor(this.addressManager.selectedTagIndex === index ? 'rgba(255, 75, 75, 1)' :
                    'rgba(0, 0, 0, 0.6)')
                  .textAlign(TextAlign.Center)
              }
              .width(82)
              .height(28)
              .border({ radius: 8 })
              .backgroundColor(this.addressManager.selectedTagIndex === index ? 'rgba(255, 75, 75, 0.1)' :
                'rgba(0, 0, 0, 0.1)')
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              .margin({ top: 17, right: 8 })
              .onClick(() => {
                this.addressManager.selectedTagIndex = index
                this.addressLabelLocal = this.addressManager.defaultTagArray[index]
              })
            }, (item: string, idx: number) => JSON.stringify(item) + idx)
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 12 })
          .alignItems(VerticalAlign.Top)
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .height(147)
        .margin({ top: 12 })
        .border({ radius: 16 })
        .backgroundColor('rgba(255, 255, 255, 1)')

      }.width('100%').layoutWeight(1)

      // 确定添加
      Row() {
        Text('确定')
          .layoutWeight(1)
          .height(40)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('rgba(255, 255, 255, 1)')
          .backgroundColor('rgba(255, 75, 75, 1)')
          .textAlign(TextAlign.Center)
          .margin({ left: 12, right: 12 })
          .borderRadius(20)
          .alignRules({
            bottom: { align: VerticalAlign.Bottom, anchor: '__container__' }
          })
          .onClick(() => {
            // 提交前的校验
            if (!this.addressLocal || !this.addressPhoneLocal || !this.addressAreaLocal || !this.addressDetailLocal) {
              promptAction.showToast({
                message: '请填写完整信息'
              })
              return
            }
            // 校验手机号格式
            if (!PhoneValidatorUtil.isValidPhoneNumber(this.addressPhoneLocal)) {
              promptAction.showToast({
                message: '输入的手机号码格式有误'
              })
              return
            }
            // 如果是新添加
            if (this.selectIconIndex < 0) {
              const addressItem: AddressManagerItem =
                new AddressManagerItem(Date.now().toString(), this.addressLocal, this.addressPhoneLocal,
                  `${this.addressAreaLocal} ${this.addressDetailLocal}`, this.isDefaultLocal,
                  this.addressLabelLocal, this.addressAreaLocal, this.addressDetailLocal,
                )
              this.addressManager.addressList = [addressItem, ...this.addressManager.addressList]
              // 修改默认地址标志，如果选择了默认地址，则刷新默认，否则不刷新
              this.refreshDefaultAddress(addressItem.id, this.isDefaultLocal)
            } else {
              const addressItem: AddressManagerItem = this.addressManager.addressList[this.selectIconIndex]
              addressItem.address = `${this.addressAreaLocal} ${this.addressDetailLocal}`
              addressItem.name = this.addressLocal
              addressItem.phone = this.addressPhoneLocal
              addressItem.remark = this.addressLabelLocal
              addressItem.area = this.addressAreaLocal
              addressItem.detailAddress = this.addressDetailLocal
              // 修改默认地址标志，如果选择了默认地址，则刷新默认，否则不刷新
              addressItem.isDefault = this.isDefaultLocal
              this.refreshDefaultAddress(addressItem.id, this.isDefaultLocal)
            }
            // 退出页面
            phoneRouterControl.popPage()
          })
      }
      .width('100%')
      .margin({ bottom: 24 })
      .alignRules({
        bottom: { align: VerticalAlign.Bottom, anchor: '__container__' }
      })

    }.width('100%').height('100%').backgroundColor('rgba(245, 245, 245, 1)').padding({ left: 16, right: 16 })

  }

  // 重新刷新列表的默认地址
  refreshDefaultAddress(id: string, isOn: boolean) {
    this.addressManager.addressList.forEach((item: AddressManagerItem, index: number) => {
      if (isOn) {
        if (item.id === id) {
          item.isDefault = true
        } else {
          item.isDefault = false
        }
      }

    })
  }

  build() {
    NavDestination() {
      this.render()
    }
    .title(this.titleLayout())
    .hideToolBar(true)
    .padding({ top: Constants.PADDING_7XL })
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}