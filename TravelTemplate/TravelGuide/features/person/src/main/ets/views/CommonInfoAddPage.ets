import { CommonHeader, TValueType } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router'
import { CommonInfoAddVM, PageType } from '../viewmodel/CommonInfoAddVM';

@Builder
export function CommonInfoAddPageBuilder(params: TValueType) {
  CommonInfoAddPage({
    pageParam: params
  });
}

@ComponentV2
export struct CommonInfoAddPage {
  @Param pageParam?: TValueType = null
  vm: CommonInfoAddVM = new CommonInfoAddVM()

  aboutToAppear() {
    this.vm.getPageParam(this.pageParam)
    this.vm.getPageName()
  }

  @Builder
  addContentBuilder() {
    if (this.vm.pageType === PageType.PASSENGER) {
      Column({ space: 10 }) {
        Column() {
          this.inputRow('姓名', this.vm.data.name, '请填写姓名', (value) => {
            this.vm.data.name = value
          }, 11)
          this.inputRow('手机号', this.vm.data.phone, '请填写手机号', (value) => {
            this.vm.data.phone = value
          }, 11, InputType.PhoneNumber)
          this.inputRow('证件号码', this.vm.data.idNumber, '请填写证件号码', (value) => {
            this.vm.data.idNumber = value
          })
        }
        .contentCol()

        this.mySelfCheckRow()
      }
    }
    if (this.vm.pageType === PageType.ADDRESS) {
      Column() {
        this.inputRow('收货人', this.vm.data.name, '请填写收货人姓名', (value) => {
          this.vm.data.name = value
        }, 11)
        this.inputRow('手机号', this.vm.data.phone, '请填写手机号', (value) => {
          this.vm.data.phone = value
        }, 11, InputType.PhoneNumber)
        this.inputRow('所在地区', this.vm.data.area, '省/市/区/县、乡镇等', (value) => {
          this.vm.data.area = value
        })
        this.inputRow('详细地址', this.vm.data.detailAddress, '如道路、小区、楼牌号等', (value) => {
          this.vm.data.detailAddress = value
        })
      }
      .contentCol()
    }
  }

  @Builder
  inputRow(label: string, data: string, placeholder: string, onChange: (value: string) => void, maxLength?: number,
    type?: InputType) {
    Row({ space: 32 }) {
      Text(label)
        .fontSize(14)
        .fontColor('#000')
        .width(56)
        .alignSelf(label === '详细地址' ? ItemAlign.Baseline : ItemAlign.Auto)
        .translate({ y: label === '详细地址' ? 10 : 0 })
      if (label === '详细地址') {
        TextArea({ text: data, placeholder: placeholder })
          .layoutWeight(1)
          .height(150)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor(Color.Transparent)
          .placeholderColor($r('sys.color.font_secondary'))
          .placeholderFont({ size: $r('sys.float.Body_L') })
          .onChange((value) => onChange(value))
      } else {
        TextInput({ text: data, placeholder: placeholder })
          .type(type ? type : InputType.Normal)
          .layoutWeight(1)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor(Color.Transparent)
          .placeholderColor($r('sys.color.font_secondary'))
          .placeholderFont({ size: $r('sys.float.Body_L') })
          .inputFilter(label === '证件号码' ? '[0-9Xx]' : '')
          .onChange((value) => onChange(value))
          .maxLength(maxLength ? maxLength : 50)
      }
    }
    .width('100%')
    .padding({ top: 5, bottom: 5 })
  }

  @Builder
  mySelfCheckRow() {
    Column() {
      Row() {
        Text('设置为本人')
          .fontSize(14)
          .fontColor('#000')
        Toggle({
          type: ToggleType.Switch,
          isOn: !!this.vm.data.id && this.vm.passengerList.mySelfId === this.vm.data.id
        })
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .switchPointColor($r('sys.color.comp_background_list_card'))
          .onChange((isOn: boolean) => {
            this.vm.mySelfId = isOn ? (this.vm.data.id || Date.now().toString()) : ''
          })
      }
      .padding({ top: 14, bottom: 14 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .contentCol()
  }

  @Builder
  saveButton() {
    Button('保存')
      .width('100%')
      .height(42)
      .backgroundColor(this.vm.allowSave ? '#FEE231' : '#DBDBDB ')
      .fontColor($r('sys.color.font_primary'))
      .enabled(this.vm.allowSave)
      .margin({ top: 84 })
      .borderRadius(24)
      .onClick(() => {
        this.vm.saveData()
      })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: this.vm.pageName,
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
      })
        .margin({ top: 12, bottom: 20 })
      this.addContentBuilder()
      this.saveButton()
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      isFullScreen: true,
      useSafePadding: true
    })
  }
}

@Extend(Column)
function contentCol() {
  .padding({
    left: 12,
    right: 12
  })
  .backgroundColor('#fff')
  .borderRadius(16)
  .width('100%')
}

