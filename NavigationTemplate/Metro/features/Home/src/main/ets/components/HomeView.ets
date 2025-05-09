import { MainEntryVM } from 'commonlib';
import { BACKGROUND_COLOR_GRAY, } from '../constants/HomeViewConstants';
import {
  functionRegion,
  functionRegionInterface,
  newsInformation,
  newsInformationInterface,
  swiperContent,
  swiperContentInterface
} from 'commonlib';
import { BusinessError } from '@kit.BasicServicesKit';
import { call } from '@kit.TelephonyKit';
import { common } from '@kit.AbilityKit';
import { newsComponent } from './newsComponent';
import { BaseTitle } from 'componentlib'


@ComponentV2
export struct HomeView {
  @Local isShow: boolean = false
  context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  vm: MainEntryVM = MainEntryVM.instance;
  private swiperController: SwiperController = new SwiperController()

  @Builder
  HomeTitleBuilder() {
    Text('首页')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Medium)
  }

  build() {
    Column() {
      BaseTitle({
        customTitle: () => {
          this.HomeTitleBuilder()
        }
      })

      Scroll() {
        Column({ space: 16 }) {
          Swiper(this.swiperController) {
            ForEach(swiperContent, (item: swiperContentInterface) => {
              Image(item.image)
                .width('100%')
                .borderRadius(16)
            }, (item: string, index: number) => item + index)
          }
          .indicator(
            new DotIndicator()
              .itemWidth(6)
              .itemHeight(6)
              .selectedItemHeight(6)
          )

          Row() {
            ForEach(functionRegion, (item: functionRegionInterface) => {
              Column() {
                Image(item.image)
                  .onClick(() => {
                    if (item.uri === undefined) {
                      this.isShow = true
                    } else {
                      this.vm.navStack.pushPath({ name: item.uri })
                    }
                  })
                  .width(32)
                  .height(32)
                Text(item.text)
                  .fontSize(12)
                  .margin({ top: 8 })
              }
            }, (item: string, index: number) => item + index)
          }
          .width('100%')
          .padding({
            left: 12,
            right: 12,
            top: 12,
            bottom: 12
          })
          .borderRadius(16)
          .backgroundColor(Color.White)
          .justifyContent(FlexAlign.SpaceBetween)
          .bindSheet($$this.isShow, this.myBuilder(this.context), {
            height: SheetSize.FIT_CONTENT,
            backgroundColor: $r('app.color.stationsInformation_background_color'),
            dragBar: true
          })

          Column() {
            Row() {
              Text('新闻公告')
                .fontSize(14)
                .fontColor($r('app.color.stationsInformation_default'))
                .fontWeight('medium')
              Row() {
                Text('更多')
                  .fontSize(10)
                  .fontColor($r('app.color.grey'))
                  .margin({ right: 3 })
                Image($r('app.media.ic_public_right_arrow'))
                  .width(10)
                  .height(10)
              }
              .onClick(() => {
                this.vm.navStack.pushPath({ name: 'moreNewsPage' })
              })
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .alignItems(VerticalAlign.Center)
            .margin({ bottom: 12 })

            List({ space: 25 }) {
              ForEach(newsInformation, (item: newsInformationInterface, index: number) => {
                if (index < 3) {
                  newsComponent(item, this.vm)
                }
              }, (item: string, index: number) => item + index)
            }
            .divider({
              strokeWidth: 1,
              startMargin: 104,
              endMargin: 0,
              color: $r('app.color.divider')
            })
            .width('100%')
          }
          .borderRadius(16)
          .padding({
            left: 12,
            right: 13,
            top: 12,
            bottom: 12
          })
          .backgroundColor(Color.White)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12 })
      }
      .layoutWeight(1)
      .align(Alignment.TopStart)
    }
    .backgroundColor(BACKGROUND_COLOR_GRAY)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  myBuilder(context: common.UIAbilityContext) {
    Column({space: 22}) {
      Text('联系客服')
        .fontSize(20)
        .fontWeight('medium')

      Column({ space: 12 }) {
        Text($r('app.string.AnonymousConnectUsPhoneNumber'))
          .fontSize(18)
          .fontWeight('medium')

        Row({ space: 8 }) {
          Image($r('app.media.phone'))
            .width(24)
            .height(24)
          Text('一键拨号')
            .fontColor($r('app.color.background_color_white'))
            .fontSize(16)
        }
        .padding({top: 10, bottom: 10})
        .width('100%')
        .borderRadius(20)
        .backgroundColor($r('app.color.orange'))
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          call.makeCall(context.resourceManager.getStringSync($r('app.string.connectUsPhoneNumber')),
            (err: BusinessError) => {
              if (err) {
                console.error(`makeCall fail, err->${JSON.stringify(err)}`);
              } else {
                console.log(`makeCall success`);
              }
            });
        })

        Row() {
          Text('取消')
            .fontColor($r('app.color.font_color_gray'))
            .fontSize(16)
        }
        .width('100%')
        .borderRadius(20)
        .padding({top: 8, bottom: 8})
        .backgroundColor($r('app.color.background_color_cancel'))
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.isShow = false
        })
      }
      .padding({top: 16, right: 12, left: 12, bottom: 16})
      .width('100%')
      .borderRadius(16)
      .backgroundColor($r('app.color.background_color_white'))
    }
    .padding({left: 16, right: 16, bottom: 44, top: 31})
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
  }
}


