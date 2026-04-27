import { RouterMap } from 'common';
import { TravelerListPageVM } from 'common_travel_guide';
import { TravelerModel } from 'common_travel_guide/src/main/ets/model/TravelerModel';
import { phoneRouterControl } from 'oh_router';
import { EditTravelerPageBuilder } from './EditTravelerPage'


@Builder
export function TravelerPageBuilder() {
  TravelerPage()
}

@ComponentV2
export struct TravelerPage {
  vm: TravelerListPageVM = new TravelerListPageVM()
  vmAdd: TravelerModel = new TravelerModel()
  @Local vmList: TravelerModel[] = this.vm.travelerList
  @Local vmSelectList: TravelerModel[] = []

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
    .backgroundColor($r('sys.color.background_secondary'))

  }

  @Builder
  render() {
    Column() {
      Row() {
        Image($r('app.media.leftReturn'))
          .width(40)
          .height(40)
          .onClick(() => {
            phoneRouterControl.popPage({
              popData: this.vmSelectList
            })
            return true
          })
        Text('选择出行人')
          .fontSize(20)
          .fontColor('#000')
          .margin({ left: 8 })
      }
      .width('100%')
      .margin({ bottom: 18 })

      if (this.vm.travelerList && this.vm.travelerList.length > 0) {
        this.content()
      }
      Row() {
        Image($r('app.media.addTraveler'))
          .width(14)
          .height(14)
          .margin({ right: 5 })
        Text('新增出行人')
          .fontSize(14)
          .fontColor('#333')
      }
      .margin({ top: 12 })
      .onClick(() => {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.TEDIT_RAVE_LER_PAGE,
          builder: wrapBuilder(EditTravelerPageBuilder),
          param: this.vmAdd,
          onPop: (popInfo: PopInfo) => {
            let data: TravelerModel = popInfo.result as TravelerModel
            data.id = this.vm.travelerList.length + 1
            this.vm.travelerList.push(data)
          }
        })
      })
      .width('100%')
      .borderRadius(24)
      .height(42)
      .backgroundColor('#fff')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      Row() {
        Text('确认')
          .fontSize(15)
          .fontColor('#333')
          .textAlign(TextAlign.Center)
          .width('100%')
      }
      .onClick(() => {
        phoneRouterControl.popPage({
          popData: this.vmSelectList
        })
      })
      .width('100%')
      .borderRadius(24)
      .margin({ top: 10, bottom: 10 })
      .height(42)
      .backgroundColor('#FEE231')
    }
    .width('100%')
    .backgroundColor('#F1F3F5')
  }

  @Builder
  content() {
    List({ space: 12 }) {
      ForEach(this.vm.travelerList, (item: TravelerModel, index: number) => {
        ListItem() {
          Row() {
            Checkbox({ name: 'checkbox1', group: 'checkboxGroup' + index })
              .select(false)
              .selectedColor($r('sys.color.comp_background_emphasize'))
              .shape(CheckBoxShape.CIRCLE)
              .onChange((value: boolean) => {
                if (value) {
                  this.vmSelectList.push(item)
                } else {
                  this.vmSelectList = this.vmSelectList.filter(selectedItem =>
                  selectedItem.id !== item.id
                  )
                }
              })
            Column() {
              Text(item.name)
                .width('100%')
                .textAlign(TextAlign.Start)
              Row() {
                Text('身份证')
                  .fontColor('#333')
                Text(this.maskedIdCard(item.idNumber))
                  .fontColor('#333')
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
            }
            .layoutWeight(1)
            .margin({ right: 14 })

            Image($r('app.media.ic_edit'))
              .width(14)
              .height(14)
              .onClick(() => {
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.TEDIT_RAVE_LER_PAGE,
                  builder: wrapBuilder(EditTravelerPageBuilder),
                  param: item,
                  onPop: (popInfo: PopInfo) => {
                    let data: TravelerModel = popInfo.result as TravelerModel
                    if (data.show === 1) {
                      this.vm.travelerList = this.vm.travelerList.filter(item => item.id !== data.id);
                    } else {
                      if (item.id === data.id) {
                        this.vm.travelerList = this.vm.travelerList.filter(item => item.id !== data.id);
                        this.vm.travelerList.push(data)
                      }
                    }
                  }
                })
              })
          }
          .alignItems(VerticalAlign.Center)
          .height(60)
        }
      },(item: TravelerModel) => JSON.stringify(item))
    }
    .backgroundColor('#fff')
    .padding(12)
    .borderRadius(16)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
  }
}