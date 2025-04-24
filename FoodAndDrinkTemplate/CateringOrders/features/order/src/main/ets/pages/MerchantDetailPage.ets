import {
  CallTelDialogBuilder,
  CommonUrl,
  Constants,
  HwMapModel,
  ImageRouter,
  NavHeaderBar,
  StoreInfo,
} from 'common/Index';
import { promptAction } from '@kit.ArkUI';
import web_webview from '@ohos.web.webview';

@Component
export struct MerchantDetailPage {
  @Consume('pageStack') pageStack: NavPathStack
  @Consume('storeInfo') storeInfo?: StoreInfo
  @State windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77
  @State windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28
  @State webFilePath: string = ''
  @State storeDetails: string = ''
  @State callTelSheet: boolean = false
  controller: web_webview.WebviewController = new web_webview.WebviewController();
  private scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    this.storeDetails =
      `<meta name="viewport" content="width=device-width, initial-scale=1.0">${this.storeInfo?.details ?? ''}`
  }

  @Styles
  cardStyle(){
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16,
    })
    .margin({
      left: 12,
      right: 12,
    })
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({ title: $r('app.string.store_detail') })

        Scroll(this.scroller) {
          Column({ space: 12 }) {
            Column() {
              Row() {
                Row() {
                  Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.storeInfo?.logo}`).width(40).height(40).borderRadius(8)
                  Column() {
                    Text(this.storeInfo?.name)
                      .fontSize($r('sys.float.Body_L'))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(this.storeInfo?.address)
                      .fontSize($r('sys.float.Body_S'))
                      .fontColor($r('sys.color.font_secondary'))
                      .constraintSize({ maxWidth: 190 })
                      .margin({ top: 2 })
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }.margin({ left: 8 }).alignItems(HorizontalAlign.Start).layoutWeight(1)
                }.layoutWeight(1)

                Row() {
                  Image($r('app.media.ic_tel')).width(24)
                    .onClick(() => {
                      this.callTelSheet = true
                    })
                    .bindSheet($$this.callTelSheet, CallTelDialogBuilder(this.storeInfo?.tel || '', () => {
                      this.callTelSheet = false
                    }), {
                      height: 309,
                      blurStyle: BlurStyle.Thick,
                      showClose: false,
                    });
                  Image($r('app.media.ic_map')).width(24).margin({ left: 12 })
                    .onClick(() => {
                      let coordinates = this.storeInfo?.coordinates?.split(',')
                      if (coordinates?.length === 2) {
                        let latitude: number = Number(coordinates[0])
                        let longitude: number = Number(coordinates[1])
                        this.pageStack.pushPath({
                          name: 'HwMap',
                          param: { latitude, longitude, storeInfo: this.storeInfo } as HwMapModel,
                        })
                      } else {
                        promptAction.showToast({ message: $r('app.string.store_address_error') })
                      }

                    })
                }.width(80).justifyContent(FlexAlign.End)
              }
              .width(Constants.FULL_SIZE)
              .constraintSize({ maxWidth: Constants.FULL_SIZE })
              .justifyContent(FlexAlign.SpaceBetween)

              Divider().margin({ top: 12, bottom: 12 })
              Row() {
                Image($r('app.media.clock')).width(14)
                Text() {
                  Span($r('app.string.monday_to_sunday'))
                  Span(this.storeInfo?.time)
                  Span('-')
                  Span(this.storeInfo?.time2)
                  Span('  ')
                  Span(this.storeInfo?.time3)
                  Span('-')
                  Span(this.storeInfo?.time4)
                }
                .margin({ left: 9 })
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.font_secondary'))
              }
              .width(Constants.FULL_SIZE)
              .justifyContent(FlexAlign.Start)
            }.cardStyle()

            // 商家资质
            Column() {
              Column() {
                Text($r('app.string.merchant_qualifications'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                Grid() {
                  GridItem() {
                    Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.storeInfo?.dpyyzz}`)
                      .width(100)
                      .height(70)
                      .draggable(false)
                      .borderRadius(8)
                  }

                  GridItem() {
                    Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.storeInfo?.spjyxkz}`)
                      .width(100)
                      .height(70)
                      .draggable(false)
                      .borderRadius(8)
                  }
                }.rowsGap(5).columnsGap(5).maxCount(3).margin({ top: 12 })
              }
              .width(Constants.FULL_SIZE)
              .alignItems(HorizontalAlign.Start)
            }.cardStyle()

            if (this.storeInfo?.environment) {
              // 商家环境
              Column() {
                Column() {
                  Text($r('app.string.merchant_env'))
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                  Grid() {
                    ForEach(this.storeInfo?.environment, (item: string) => {
                      GridItem() {
                        Image(`${CommonUrl.CLOUD_STORAGE_URL}${item}`)
                          .width(100)
                          .height(70)
                          .draggable(false)
                          .borderRadius(8)
                          .onClick(() => {
                            this.pageStack.pushPath({
                              name: 'PreviewImagePage',
                              param: { imageSrc: `${item}` } as ImageRouter,
                            })
                          })
                      }
                    }, (item: string) => item)
                  }.rowsGap(4).columnsGap(4).maxCount(3).margin({ top: 12 })
                }
                .width(Constants.FULL_SIZE)
                .alignItems(HorizontalAlign.Start)
              }.cardStyle()
            }

            // 商家承诺
            Column() {
              Text($r('app.string.merchant_commitment'))
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
              Row() {
                Text($r('app.string.food_safe'))
                  .fontSize($r('sys.float.Body_S'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_secondary'))
                Row() {
                  Image($r('app.media.ic_store_security')).width(16)
                  Text($r('app.string.licensed'))
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ left: 4 })
                }.margin({ left: 24 })

                Row() {
                  Image($r('app.media.ic_store_security')).width(16)
                  Text($r('app.string.worry_free'))
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ left: 4 })
                }.margin({ left: 16 })
              }.margin({ top: 12 })

              Row() {
                Text($r('app.string.basic_service'))
                  .fontSize($r('sys.float.Body_S'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_secondary'))
                Row() {
                  Image($r('app.media.ic_store_wifi')).width(16)
                  Text($r('app.string.free_wifi'))
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ left: 4 })
                }.margin({ left: 24 })

                Row() {
                  Image($r('app.media.ic_store_car')).width(16)
                  Text($r('app.string.free_parking'))
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ left: 4 })
                }.margin({ left: 16 })
              }.margin({ top: 8 })
            }.cardStyle().width(Constants.FULL_SIZE).padding(12).alignItems(HorizontalAlign.Start)

            // 商家公告
            Column() {
              Column() {
                Text($r('app.string.store_announce'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                Row() {
                  Image($r('app.media.news')).width(16)
                  Text(this.storeInfo?.announcement)
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_secondary'))
                    .layoutWeight(1)
                    .margin({ left: 4 })
                }.margin({ top: 12 }).alignItems(VerticalAlign.Top)
              }
              .width(Constants.FULL_SIZE)
              .alignItems(HorizontalAlign.Start)
            }.cardStyle()

          }
        }
        .backgroundColor($r('sys.color.background_secondary'))
        .scrollBar(BarState.Off)
        .layoutWeight(1)
        .padding({ top: 12 })
        .align(Alignment.Top)
      }

    }.hideTitleBar(true)
  }
}
