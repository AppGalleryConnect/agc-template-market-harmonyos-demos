import { qrViewFunction, QRViewFunction, recordingList, userPayMethod, UserPayMethod } from 'commonlib';
import { MainEntryVM } from 'commonlib';
import { TabListItem, TAB_LIST } from '../constants/Constants'
import { TabBarView } from '../components/tabBarBuilder'
import { BaseTitle } from 'componentlib';

let count = 100000;

@Component
export struct QRView {
  @State token: string = 'ECJL357802#s3eSWS2h#F98C0SA9#9D098&SJL22'
  vm: MainEntryVM = MainEntryVM.instance
  @State userPayMethod: UserPayMethod = userPayMethod
  @State currentIndex: number = 0
  private controller: TabsController = new TabsController()
  lastPageIndex: number = MainEntryVM.instance.navStack.size() - 1
  returnIndex: number = MainEntryVM.instance.navStack.getParamByIndex(this.lastPageIndex) as number

  @Builder
  QRTitleBuilder() {
    Text('乘车码')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Medium)
  }

  build() {
    Column() {
      BaseTitle({
        customTitle: () => {
          this.QRTitleBuilder()
        }
      })

      Column() {
        Row() {
          ForEach(TAB_LIST, (item: TabListItem, index: number) => {
            TabBarView({
              data: item,
              currentIndex: this.currentIndex,
              index: index,
              onClickTab: (index) => {
                this.currentIndex = index
              }
            })
          }, (item: string, index: number) => item + index)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')

        Tabs({
          barPosition: BarPosition.Start,
          index: this.currentIndex,
          controller: this.controller
        }) {
          TabContent() {
            Column() {
              Text('对准闸机扫描口刷码进站  高度5cm以上')
                .fontColor($r('app.color.highlight_font_color'))
                .fontSize(10)
              QRCode(this.token)
                .width(182)
                .height(182)
              Text('刷新')
                .fontColor($r('app.color.refresh'))
                .fontSize(14)
                .onClick(() => {
                  this.token = this.token + count
                })
              Divider()
                .width(304)
              Row() {
                Row() {
                  Image(this.userPayMethod.defaultPayMethod.imageDefault)
                    .width(25)
                    .height(25)
                  Text(this.userPayMethod.defaultPayMethod.text)
                    .fontSize(14)
                    .margin({ left: 4 })
                }

                Row() {
                  Text('切换')
                    .fontSize(14)
                    .fontColor($r('app.color.tab_font_color'))
                  Image($r('app.media.ic_public_right_arrow'))
                    .width(16)
                    .height(16)
                }
                .onClick(() => {
                  this.vm.navStack.pushPath({ name: 'PayMethodsPage' })
                })
              }
              .width(304)
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .width('100%')
            .height(315)
            .backgroundColor(Color.White)
            .justifyContent(FlexAlign.SpaceEvenly)
            .borderRadius(20)
          }
          .align(Alignment.Top)

          TabContent() {
            this.showCode(this.token)
          }
          .align(Alignment.Top)

          TabContent() {
            this.showCode(this.token)
          }
          .align(Alignment.Top)
        }
        .onChange((index: number) => {
          this.currentIndex = index
        })
        .height(315)
        .barHeight(0)
        .animationDuration(0)
        .margin({ top: 25 })

        Row() {
          ForEach(qrViewFunction, (item: QRViewFunction) => {
            Column() {
              Image(item.image)
                .width(24)
                .height(24)
                .onClick(() => {
                  this.vm.navStack.pushPath({
                    name: item.uri, onPop: (popInfo: PopInfo) => {
                      if (item.uri === 'MyTicketsPage') {
                        this.currentIndex = popInfo.result as number
                      }
                    }
                  })
                })
              Row() {
                Text(item.title)
                  .margin({ top: 4 })
                  .fontSize(14)
                  .fontColor($r('app.color.tab_font_color'))
              }
              .width(56)
              .height(20)
              .justifyContent(FlexAlign.Center)
            }
            .alignItems(HorizontalAlign.Center)
          }, (item: string, index: number) => item + index)
        }
        .borderRadius(16)
        .width('100%')
        .height(72)
        .backgroundColor($r('app.color.background_color_white'))
        .margin({ top: 12 })
        .justifyContent(FlexAlign.SpaceEvenly)
      }
      .margin({top: 10})
      .padding({left: 16, right: 16})
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.background_color'))
  }

  @Builder
  showCode(token: string) {
    Column() {
      Text('对准闸机扫描口刷码进站  高度5cm以上')
        .fontColor($r('app.color.highlight_font_color'))
        .fontSize(10)
        .margin({ top: 12 })
      QRCode(token)
        .width(182)
        .height(182)
        .margin({ top: 12 })
      Text('有效期内不限次数，不限里程')
        .fontSize(14)
        .fontColor($r('app.color.highlight_font_color'))
        .margin({ top: 22 })
      Text('支持扫码过闸，无需取票')
        .fontSize(14)
        .fontColor($r('app.color.highlight_font_color'))
        .margin({ top: 2 })
    }
    .width('100%')
    .height(315)
    .backgroundColor(Color.White)
    .borderRadius(20)
  }
}
