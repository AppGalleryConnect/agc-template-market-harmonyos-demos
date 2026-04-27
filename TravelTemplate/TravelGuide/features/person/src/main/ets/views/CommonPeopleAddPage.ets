import { BarVM, CommonHeader, TValueType } from 'common';
import { CommonPeopleAddPageVM } from '../viewmodel/CommonPeopleAddPageVM'
import { TravelPeopleModel } from 'common_travel_guide';

@Builder
export function CommonPeopleAddPageBuilder(params: TValueType) {
  CommonPeopleAddPage({
    pageParam: params
  })
}

@ComponentV2
export struct CommonPeopleAddPage {
  @Local vm: CommonPeopleAddPageVM = new CommonPeopleAddPageVM()
  @Param pageParam: TValueType = null

  aboutToAppear(): void {
    //  是否是编辑状态
    this.vm.isEditPeople = this.pageParam !== null
    if (this.pageParam !== null) {
      // 对编辑信息回显
      let commonRouterParam: TravelPeopleModel = this.pageParam as TravelPeopleModel;
      this.vm.commonPeopleItem = {
        id:commonRouterParam.id,
        idNumber: commonRouterParam.idNumber,
        name: commonRouterParam.name,
        phone: commonRouterParam.phone,
        maskedIdNumber: commonRouterParam.maskedIdNumber,
        maskedPhone: commonRouterParam.maskedPhone,
        isCheck: commonRouterParam.isCheck,
        isMyself: commonRouterParam.isMyself
      }
    }
  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.vm.backPage()
      return true
    })
    .backgroundColor('#F1F3F5')
    .padding({
      top: BarVM.instance.staBarH,
      bottom: BarVM.instance.aiBarH
    })
  }

  @Builder
  render() {
    Column() {
      // 顶部标题
      CommonHeader({
        title: this.vm.isEditPeople ? '编辑常用人' : '新增常用人',
        onReturnClick: () => {
          this.vm.backPage()
        },
      }).margin({ bottom: 20 })
      // 编辑出行人信息
      this.peopleEditBuilder()
      // 设置为本人
      this.mySelfCheckBuilder()
      // 操作按钮
      this.bottomOperationBuilder()
    }
    .padding({
      left: 16,
      right: 16
    })
  }

  @Builder
  peopleEditBuilder() {
    Column() {
      Row() {
        Text('姓名')
          .fontSize(14)
          .width(60)
          .textAlign(TextAlign.Start)
        TextInput({ text: this.vm.commonPeopleItem.name, placeholder: '请填写姓名' })
          .layoutWeight(1)
          .backgroundColor('rgba(0, 0, 0, 0)')
          .onChange((event: string) => {
            this.vm.commonPeopleItem.name = event.trim()
          })
      }
      .width('100%')

      Row() {
        Text('证件号码')
          .fontSize(14)
          .width(60)
          .textAlign(TextAlign.Start)
        TextInput({
          text: this.vm.commonPeopleItem.idNumber,
          placeholder: '请填写证件号码'
        })
          .layoutWeight(1)
          .backgroundColor('rgba(0, 0, 0, 0)')
          .onChange((event: string) => {
            this.vm.commonPeopleItem.idNumber = event.trim()
          })
      }
      .width('100%')

      Row() {
        Text('手机号')
          .fontSize(14)
          .textAlign(TextAlign.Start)
          .width(60)
        TextInput({ text: this.vm.commonPeopleItem.phone, placeholder: '请填写手机号' })
          .layoutWeight(1)
          .type(InputType.PhoneNumber)
          .backgroundColor('rgba(0, 0, 0, 0)')
          .onChange((event: string) => {
            this.vm.commonPeopleItem.phone = event.trim()
          })
      }
      .width('100%')
    }
    .padding({
      left: 12,
      right: 12
    })
    .width('100%')
    .borderRadius(16)
    .backgroundColor('#ffffff')
    .margin({ bottom: 10 })
  }

  @Builder
  mySelfCheckBuilder() {
    Column() {
      Row() {
        Text('设置为本人')
          .fontSize(14)
          .fontColor('#000')
        Toggle({
          type: ToggleType.Switch,
          isOn: this.vm.commonPeopleItem.isMyself
        })
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .switchPointColor($r('sys.color.comp_background_list_card'))
          .onChange((isOn: boolean) => {
            this.vm.commonPeopleItem.isMyself = isOn;
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }.padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16
    })
    .width('100%')
    .borderRadius(16)
    .backgroundColor('#ffffff')
  }

  // 底部按钮
  @Builder
  bottomOperationBuilder() {
    // 待付款
    Column({ space: 16 }) {
      Text('保存')
        .fontSize(15)
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Center)
        .padding({ top: 12, bottom: 12 })
        .borderRadius(24)
        .width('100%')
        .backgroundColor(this.vm.allowSave ? '#FEE231' : '#DBDBDB ')
        .onClick(() => {
          this.vm.saveCommonPeopleClick()
        })
    }
    .width('100%')
    .padding({
      top: 72,
      bottom: 12
    })
  }
}
