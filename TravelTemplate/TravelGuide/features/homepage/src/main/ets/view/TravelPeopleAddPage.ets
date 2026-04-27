import { BarVM, CommonHeader, TValueType } from 'common';
import { TravelPeopleAddPageVM } from '../viewmodel/TravelPeopleAddPageVM'
import { TravelPeopleModel } from 'common_travel_guide';

@Builder
export function TravelPeopleAddPageBuilder(params: TValueType) {
  TravelPeopleAddPage({
    pageParam: params
  })
}

@ComponentV2
export struct TravelPeopleAddPage {
  @Local vm: TravelPeopleAddPageVM = new TravelPeopleAddPageVM()
  @Param pageParam: TValueType = null

  aboutToAppear(): void {
    //  是否是编辑状态
    this.vm.isEdit = this.pageParam !== null
    if (this.pageParam !== null) {
      // 对编辑信息回显
      let routerParam:TravelPeopleModel = this.pageParam as TravelPeopleModel;
      this.vm.peopleItem = {
        id:routerParam.id,
        idNumber:routerParam.idNumber,
        name:routerParam.name,
        phone:routerParam.phone,
        maskedIdNumber:routerParam.maskedIdNumber,
        maskedPhone:routerParam.maskedPhone,
        isCheck:routerParam.isCheck,
        isMyself:routerParam.isMyself
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
        title: this.vm.isEdit ? '编辑出行人' : '新增出行人',
        onReturnClick: () => {
          this.vm.backPage()
        },
      }).margin({ bottom: 20 })
      // 编辑出行人信息
      this.peopleEditBuilder()
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
        TextInput({ text: this.vm.peopleItem.name, placeholder: '请填写姓名' })
          .layoutWeight(1)
          .backgroundColor('rgba(0, 0, 0, 0)')
          .onChange((event: string) => {
            this.vm.peopleItem.name = event.trim()
          })
      }
      .width('100%')

      Row() {
        Text('证件号码')
          .fontSize(14)
          .width(60)
          .textAlign(TextAlign.Start)
        TextInput({
          text: this.vm.peopleItem.idNumber,
          placeholder: '请填写证件号码'
        })
          .layoutWeight(1)
          .backgroundColor('rgba(0, 0, 0, 0)')
          .onChange((event: string) => {
            this.vm.peopleItem.idNumber = event.trim()
          })
      }
      .width('100%')

      Row() {
        Text('手机号')
          .fontSize(14)
          .textAlign(TextAlign.Start)
          .width(60)
        TextInput({ text: this.vm.peopleItem.phone, placeholder: '请填写手机号' })
          .layoutWeight(1)
          .type(InputType.PhoneNumber)
          .backgroundColor('rgba(0, 0, 0, 0)')
          .onChange((event: string) => {
            this.vm.peopleItem.phone = event.trim()
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
  }

  // 底部按钮
  @Builder
  bottomOperationBuilder() {
    // 待付款
    Column({ space: 16 }) {
      Text('保存')
        .fontSize(15)
        .fontColor('#333333')
        .textAlign(TextAlign.Center)
        .padding({ top: 12, bottom: 12 })
        .borderRadius(24)
        .width('100%')
        .backgroundColor('#FFFEE231')
        .onClick(() => {
          this.vm.saveClick()
        })
      if (this.vm.isEdit) {
        Text('删除')
          .fontSize(15)
          .fontColor('#FF4A26')
          .textAlign(TextAlign.Center)
          .padding({
            top: 12,
            bottom: 12,
          })
          .width('100%')
          .borderRadius(24)
          .backgroundColor($r('sys.color.background_primary'))
          .onClick(() => {
            this.vm.deleteClick()
          })
      }
    }
    .width('100%')
    .padding({
      top: 72,
      bottom: 12
    })
  }
}
