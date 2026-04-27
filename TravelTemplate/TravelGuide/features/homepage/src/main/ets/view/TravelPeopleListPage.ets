import { TravelPeopleModel } from 'common_travel_guide';
import { BarVM, CommonHeader, TValueType } from 'common';
import { TravelPeopleListPageVM } from '../viewmodel/TravelPeopleListPageVM'

@Builder
export function TravelPeopleListPageBuilder(params: TValueType) {
  TravelPeopleListPage({
    pageParam: params
  })
}

@ComponentV2
export struct TravelPeopleListPage {
  @Local vm: TravelPeopleListPageVM = new TravelPeopleListPageVM()
  @Param pageParam: TValueType = null


  aboutToAppear(): void {
    if(this.pageParam !==null){
      this.vm.selectList = this.pageParam as TravelPeopleModel[]
      this.vm.initData()
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
    .padding({ top: BarVM.instance.staBarH })
  }

  @Builder
  render() {
    Column() {
      // 顶部标题
      CommonHeader({
        title: '选择出行人',
        onReturnClick: () => {
          this.vm.backPage()
        },
      }).padding({ left: 16 })

      // 中间滚动区域
      Scroll() {
        Column() {
          if (this.vm.peopleList.list.length) {
            this.travelPeopleListBuilder()
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 100 })
      }
      .align(Alignment.TopStart)
      .padding({ left: 16, right: 16 })
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)

      // 底部操作栏
      this.bottomOperationBuilder();
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  travelPeopleListBuilder() {
    Column() {
      List({ space: 12 }) {
        ForEach(this.vm.peopleList.list, (item: TravelPeopleModel, index: number) => {
          ListItem() {
            Row() {
              Checkbox({ name: `checkbox-${item.idNumber}` })
                .select(item.isCheck)
                .selectedColor($r('sys.color.comp_background_emphasize'))
                .shape(CheckBoxShape.CIRCLE)
                .onChange((value: boolean) => {
                  this.vm.operateCheck(value, item)
                })
              Column() {
                Text(item.name)
                  .width('100%')
                  .textAlign(TextAlign.Start)
                Row() {
                  Text('身份证')
                    .fontColor('#333')
                  Text(item.maskedIdNumber)
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
                  this.vm.jumpTravelPeopleAddPage(item)
                })
            }
            .alignItems(VerticalAlign.Center)
            .height(60)
          }
        },(item: TravelPeopleModel) => JSON.stringify(item))
      }
      .width('100%')
      .backgroundColor('#fff')
      .padding(12)
      .borderRadius(16)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .scrollBar(BarState.Off)
    }
  }

  // 底部按钮
  @Builder
  bottomOperationBuilder() {
    // 待付款
    Column({ space: 16 }) {
      Text('新增出行人')
        .fontSize(14)
        .fontColor('#333333')
        .textAlign(TextAlign.Center)
        .padding({
          top: 12,
          bottom: 12,
        })
        .width('100%')
        .borderRadius(24)
        .backgroundColor($r('sys.color.background_primary'))
        .onClick(() => {
          this.vm.jumpTravelPeopleAddPage(null)
        })
      if (this.vm.peopleList.list.length) {
        Text('确认')
          .fontSize(15)
          .fontColor('#333333')
          .textAlign(TextAlign.Center)
          .padding({ top: 12, bottom: 12 })
          .borderRadius(24)
          .width('100%')
          .backgroundColor('#FFFEE231')
          .onClick(() => {
            this.vm.confirmClick()
          })
      }
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: BarVM.instance.aiBarH + 12
    })
  }
}