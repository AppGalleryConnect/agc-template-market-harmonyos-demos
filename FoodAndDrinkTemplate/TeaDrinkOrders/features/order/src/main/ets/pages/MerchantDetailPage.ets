import {
  CallTelSheetBuilder,
  CommonUrl,
  Constants,
  HwMapModel,
  ImageRouter,
  NavHeaderBar,
  RouterMap,
  StoreInfoModel,
} from 'common/Index';
import { AppStorageV2, promptAction } from '@kit.ArkUI';

@Builder
export function MerchantDetailPageBuilder() {
  MerchantDetailPage()
}

@ComponentV2
struct MerchantDetailPage {
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local webFilePath: string = ''
  @Local storeDetails: string = ''
  @Local callTelSheet: boolean = false
  private scroller: Scroller = new Scroller()

  @Styles
  cardStyle(){
    .backgroundColor($r('sys.color.white'))
    .borderRadius(8)
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .margin({
      left: 16,
      right: 16,
    })
    .padding(12)
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
                  Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.storeModel.storeInfo?.logo}`)
                    .width(40)
                    .height(40)
                    .borderRadius(4)
                  Column() {
                    Text(this.storeModel.storeInfo?.name)
                      .fontSize(16)
                      .fontWeight(500)
                      .fontColor($r('sys.color.font_primary'))
                      .lineHeight(20)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(this.storeModel.storeInfo?.address)
                      .fontSize(12)
                      .fontColor($r('sys.color.mask_secondary'))
                      .lineHeight(14)
                      .constraintSize({ maxWidth: 190 })
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .margin({ top: 4 })
                  }.margin({ left: 11 }).alignItems(HorizontalAlign.Start).layoutWeight(1)
                }.layoutWeight(1)

                Row() {
                  Image($r('app.media.ic_tel')).width(24)
                    .onClick(() => {
                      this.callTelSheet = true
                    })
                  Image($r('app.media.ic_map')).width(24)
                    .margin({ left: 12 })
                    .onClick(() => {
                      let coordinates = this.storeModel.storeInfo?.coordinates?.split(',')
                      if (coordinates?.length === 2) {
                        let latitude: number = Number(coordinates[0])
                        let longitude: number = Number(coordinates[1])
                        this.pageStack.pushPathByName(RouterMap.HW_MAP,
                          { latitude, longitude, storeInfo: this.storeModel.storeInfo } as HwMapModel)
                      } else {
                        promptAction.showToast({ message: $r('app.string.store_address_error') })
                      }
                    })
                }.width(80).justifyContent(FlexAlign.End)
              }
              .width(Constants.FULL_SIZE)
              .margin({ bottom: 11 })
              .constraintSize({ maxWidth: Constants.FULL_SIZE })
              .justifyContent(FlexAlign.SpaceBetween)

              Divider()
              Row() {
                Image($r('app.media.ic_clock_grey')).width(14)
                Text() {
                  Span($r('app.string.monday_to_sunday'))
                  Span(this.storeModel.storeInfo?.time1)
                  Span('-')
                  Span(Constants.MID_DAY_TIME)
                  Span('  ')
                  Span(Constants.MID_DAY_TIME)
                  Span('-')
                  Span(this.storeModel.storeInfo?.time2)
                }.margin({ left: 9 }).fontSize(12).fontColor($r('sys.color.mask_secondary')).lineHeight(20)
              }
              .width(Constants.FULL_SIZE)
              .margin({ top: 11 })
              .constraintSize({ maxWidth: Constants.FULL_SIZE })
              .justifyContent(FlexAlign.Start)
            }.cardStyle()

            // 商家资质
            Column() {
              Column() {
                Text($r('app.string.merchant_qualifications'))
                  .fontSize(14)
                  .fontWeight(500)
                  .fontColor($r('sys.color.font_primary'))
                  .lineHeight(20)
                Grid() {
                  GridItem() {
                    Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.storeModel.storeInfo?.dpyyzz}`)
                      .width(100)
                      .height(70)
                      .draggable(false)
                      .borderRadius(8)
                  }

                  GridItem() {
                    Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.storeModel.storeInfo?.spjyxkz}`)
                      .width(100)
                      .height(70)
                      .draggable(false)
                      .borderRadius(8)
                  }
                }.rowsGap(5).columnsGap(5).maxCount(3).margin({ top: 12 })
              }
              .width(Constants.FULL_SIZE)
              .constraintSize({ maxWidth: Constants.FULL_SIZE })
              .alignItems(HorizontalAlign.Start)
            }.cardStyle()

            if (this.storeModel.storeInfo?.environment) {
              // 商家环境
              Column() {
                Column() {
                  Text($r('app.string.merchant_env'))
                    .fontSize(14)
                    .fontWeight(500)
                    .fontColor($r('sys.color.font_primary'))
                    .lineHeight(20)
                  Grid() {
                    ForEach(this.storeModel.storeInfo?.environment, (item: string) => {
                      GridItem() {
                        Image(`${CommonUrl.CLOUD_STORAGE_URL}${item}`)
                          .width(100)
                          .height(72)
                          .draggable(false)
                          .borderRadius(8)
                          .onClick(() => {
                            this.pageStack.pushPath({
                              name: RouterMap.PREVIEW_IMAGE_PAGE,
                              param: { imageSrc: `${CommonUrl.CLOUD_STORAGE_URL}${item}` } as ImageRouter,
                            })
                          })
                      }
                    }, (item: string) => item)
                  }.rowsGap(4).columnsGap(4).maxCount(3).margin({ top: 12 })
                }
                .width(Constants.FULL_SIZE)
                .constraintSize({ maxWidth: Constants.FULL_SIZE })
                .alignItems(HorizontalAlign.Start)
              }.cardStyle()
            }

            // 商家承诺
            Column() {
              Text($r('app.string.merchant_commitment'))
                .fontSize(14)
                .fontWeight(500)
                .fontColor($r('sys.color.font_primary'))
                .lineHeight(20)
              Row() {
                Text($r('app.string.food_safe'))
                  .fontSize(12)
                  .fontWeight(500)
                  .fontColor($r('sys.color.mask_secondary'))
                  .lineHeight(20)
                Row() {
                  Image($r('app.media.ic_doc_list')).width(16)
                  Text($r('app.string.licensed'))
                    .fontSize(12)
                    .fontColor($r('sys.color.mask_secondary'))
                    .lineHeight(20)
                    .margin({ left: 5 })
                }.margin({ left: 24 })

                Row() {
                  Image($r('app.media.ic_security')).width(16)
                  Text($r('app.string.worry_free'))
                    .fontSize(12)
                    .fontColor($r('sys.color.mask_secondary'))
                    .lineHeight(20)
                    .margin({ left: 5 })
                }.margin({ left: 16 })
              }.margin({ top: 12 })

              Row() {
                Text($r('app.string.basic_service'))
                  .fontSize(12)
                  .fontWeight(500)
                  .fontColor($r('sys.color.mask_secondary'))
                  .lineHeight(20)
                Row() {
                  Image($r('app.media.ic_wifi')).width(16)
                  Text($r('app.string.free_wifi'))
                    .fontSize(12)
                    .fontColor($r('sys.color.mask_secondary'))
                    .lineHeight(20)
                    .margin({ left: 5 })
                }.margin({ left: 24 })

                Row() {
                  Image($r('app.media.ic_car')).width(16)
                  Text($r('app.string.free_parking'))
                    .fontSize(12)
                    .fontColor($r('sys.color.mask_secondary'))
                    .lineHeight(20)
                    .margin({ left: 5 })
                }.margin({ left: 16 })
              }.margin({ top: 9 })
            }.cardStyle().width(Constants.FULL_SIZE).alignItems(HorizontalAlign.Start)

            // 商家公告
            Column() {
              Column() {
                Text($r('app.string.store_announce'))
                  .fontSize(14)
                  .fontWeight(500)
                  .fontColor($r('sys.color.font_primary'))
                  .lineHeight(20)
                Row() {
                  Image($r('app.media.ic_news')).width(16).margin({ top: 2 })
                  Text(this.storeModel.storeInfo?.announcement)
                    .fontSize(12)
                    .fontColor($r('sys.color.mask_secondary'))
                    .lineHeight(20)
                    .layoutWeight(1)
                    .margin({ left: 4 })
                }.margin({ top: 8 }).alignItems(VerticalAlign.Top)
              }
              .width(Constants.FULL_SIZE)
              .constraintSize({ maxWidth: Constants.FULL_SIZE })
              .alignItems(HorizontalAlign.Start)
            }.cardStyle()

          }.margin({ top: 12, bottom: 12 })
        }.backgroundColor('#F1F3F5').scrollBar(BarState.Off).layoutWeight(1).align(Alignment.Top)
      }
      .bindSheet($$this.callTelSheet, CallTelSheetBuilder(this.storeModel.storeInfo.tel, () => {
        this.closeTelSheet()
      }), {
        height: 290,
        blurStyle: BlurStyle.Thick,
        backgroundColor: '#E6FFFFFF',
        showClose: false,
      });
    }.hideTitleBar(true)
  }

  closeTelSheet() {
    this.callTelSheet = false
  }
}
