import {
  addCarSpecUtil,
  addCarUtil,
  CommonUrl,
  Constants,
  getGoodInfoUtil,
  GetGoodSpecResp,
  getGoodSpecUtil,
  Good,
  GoodRouter,
  GoodSpec,
  GoodSpecEnum,
  GoodSpecInfo,
  NavHeaderBar,
  PackageSpec,
} from 'common/Index';
import web_webview from '@ohos.web.webview';
import { promptAction } from '@kit.ArkUI';
import { MustGoodsController } from '../models/MustGoodsController';
import { Decimal } from '@kit.ArkTS';
import measure from '@ohos.measure';

@Preview
@Component
export struct GoodDetailPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @Consume('mustGoodsCtrl') mustGoodsCtrl: MustGoodsController;
  @State goodInfo?: Good = undefined;
  @State goodSpecList: Array<GoodSpec> = [];
  @State selectSpecArr: Array<PackageSpec> = [];
  @State selectSpecInfo?: GetGoodSpecResp = undefined;
  @State sumPrice: string = this.goodInfo?.money ?? '0';
  @State goodSinglePrice: number = 0;
  @State goodNum: string = '1';
  @State windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @State windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @State goodDetails: string = '';
  @State swiperIndex: number = 0;
  @State showMore: boolean = false;
  @State expandMore: boolean = false;
  @State textSize?: SizeOptions = undefined;
  private scroller: Scroller = new Scroller();
  controller: web_webview.WebviewController = new web_webview.WebviewController();
  buyNoteList: BuyNote[] =
    [{
      icon: $r('app.media.ic_public_clock'),
      noteTitle: $r('app.string.use_time'),
      noteDesc: [$r('app.string.use_time_desc')],
    },
      {
        icon: $r('app.media.ic_ict_trip'),
        noteTitle: $r('app.string.validity'),
        noteDesc: [$r('app.string.order_validity_desc')],
      },
      {
        icon: $r('app.media.ic_public_doc_list'),
        noteTitle: $r('app.string.usage_rules'),
        noteDesc: [$r('app.string.usage_rules_desc1'), $r('app.string.usage_rules_desc2')],
      }];

  aboutToAppear(): void {
    this.getParams();
    getGoodInfoUtil(this.goodInfo?.id).then((resp: Good) => {
      this.goodInfo = resp;
      if (resp.spec?.length && resp.spec?.length > 0) {
        this.goodSpecList = resp.spec ?? [];
        this.selectSpecArr = this.goodSpecList.map((item: GoodSpec) => {
          let goodSpec = item.specVal.find((spec: GoodSpecInfo) => item.specValId === spec.specValId);
          let result: PackageSpec = { specName: goodSpec?.specValName, specNum: Number(goodSpec?.specValNum ?? 1) };
          return result;
        });

        getGoodSpecUtil(this.goodInfo?.id, this.selectSpecArr).then((res) => {
          this.selectSpecInfo = res;
          this.goodSinglePrice = Number(res.money);
          this.sumPrice = `${this.goodSinglePrice * Number(this.goodNum)}`;
        });

      } else {
        this.goodSinglePrice = Number(resp.money);
        this.sumPrice = `${this.goodSinglePrice * Number(this.goodNum)}`;
      }

    });
    this.goodDetails =
      `<meta name="viewport" content="width=device-width, initial-scale=1.0">${this.goodInfo?.details ?? ''}`;
  }

  getParams() {
    let paramsArr: GoodRouter[] = this.pageStack.getParamByName('GoodDetailPage') as GoodRouter[];
    if (paramsArr.length) {
      let routerParam = paramsArr[paramsArr.length-1];
      this.goodInfo = routerParam?.goodInfo ?? undefined;
    }
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({ title: $r('app.string.good_details'), hasBgColor: false })
          .backgroundImage($r('app.media.background'))
          .backgroundImageSize(ImageSize.Cover);

        Scroll(this.scroller) {
          Column() {
            Column({ space: 12 }) {
              Column() {
                Swiper() {
                  ForEach(this.goodInfo?.bigImg, (item: string) => {
                    Image(`${CommonUrl.CLOUD_STORAGE_URL}${item}`).width(Constants.FULL_SIZE).height(300);
                  }, (item: string, index: number) => `${item}`)
                }
                .displayMode(SwiperDisplayMode.STRETCH)
                .loop(true)
                .autoPlay(true)
                .vertical(false)
                .indicator(new DotIndicator().selectedColor($r('sys.color.multi_color_09')))
                .interval(2000)
                .onChange((index) => {
                  this.swiperIndex = index;
                })

                Column() {
                  Row() {
                    Text(this.goodInfo?.name)
                      .fontSize($r('sys.float.Subtitle_L'))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .layoutWeight(1)
                    Text() {
                      Span($r('app.string.currency_symbol'))
                        .fontSize($r('sys.float.Caption_M'))
                        .fontWeight(FontWeight.Medium)
                      Span(this.goodInfo?.money).fontSize($r('sys.float.Subtitle_L')).fontWeight(FontWeight.Medium)
                    }.fontColor($r('sys.color.multi_color_09'));
                  }.width(Constants.FULL_SIZE)
                  .justifyContent(FlexAlign.SpaceBetween);

                  Row() {
                    Text(Number(this.goodInfo?.sales) > 100 ? $r('app.string.sales_more') :
                    $r('app.string.month_sale', this.goodInfo?.sales))
                      .fontSize($r('sys.float.Caption_M'))
                      .fontColor($r('sys.color.font_tertiary'))
                      .margin({ top: 4 });
                    if (this.goodInfo?.specType === GoodSpecEnum.PACKAGE_TYPE) {
                      Row() {
                        Text($r('app.string.discount', this.goodInfo.discount))
                          .fontSize($r('sys.float.Caption_S'))
                          .fontColor($r('sys.color.multi_color_09'))
                          .padding({ left: 5, right: 5 })
                          .borderWidth(1)
                          .borderColor($r('sys.color.multi_color_09'))
                          .borderRadius(4)
                          .margin({ top: 3, bottom: 3 });
                        Text($r('app.string.currency_symbol_post_params', this.goodInfo?.money2))
                          .fontSize($r('sys.float.Caption_S'))
                          .fontColor($r('sys.color.font_primary'))
                          .margin({ left: 6 })
                          .decoration({
                            type: TextDecorationType.LineThrough,
                            color: $r('sys.color.font_secondary'),
                          });
                      };
                    }
                  }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween);

                }
                .width(Constants.FULL_SIZE)
                .justifyContent(FlexAlign.SpaceBetween)
                .padding({
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 12,
                });

              }
              .width(Constants.FULL_SIZE)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor($r('sys.color.background_primary'));

              if (this.goodInfo?.specType === GoodSpecEnum.SPEC_TYPE) {
                this.goodSpecComp();
                this.goodDetailComp();
              } else if (this.goodInfo?.specType === GoodSpecEnum.PACKAGE_TYPE) {
                this.goodPkgComp();
              } else {
                this.goodDetailComp();
              }
            };
          };
        }
        .backgroundColor($r('sys.color.background_secondary'))
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);

        Column() {
          Row() {
            Column() {
              Text() {
                Span($r('app.string.currency_symbol'))
                  .fontSize($r('sys.float.Caption_M'))
                  .fontColor($r('sys.color.font_primary'))
                Span(`${Number(this.sumPrice)}`)
                  .fontSize($r('sys.float.Subtitle_L'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
              };

              Text() {
                Span($r('app.string.selected'));
                Span(this.selectSpecArr.map(item => item?.specName).join('/'));
              }
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
            }.alignItems(HorizontalAlign.Start).layoutWeight(1);

            Row() {
              Image($r('app.media.ic_subtract')).width(24).onClick(() => {
                if (Number(this.goodNum) > 1) {
                  this.goodNum = `${Number(this.goodNum) - 1}`;
                  this.sumPrice = new Decimal(this.goodSinglePrice).mul(this.goodNum).toString();
                }
              });
              Text(this.goodNum)
                .margin({ left: 12, right: 12 })
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
              Image($r('app.media.add_car')).width(24).onClick(() => {
                this.goodNum = `${Number(this.goodNum) + 1}`;
                this.sumPrice = new Decimal(this.goodSinglePrice).mul(this.goodNum).toString();
              });
            }.alignItems(VerticalAlign.Center);
          }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween);

          Row() {
            Text($r('app.string.add_car'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_on_primary'))
          }
          .borderRadius(18)
          .justifyContent(FlexAlign.Center)
          .width(Constants.FULL_SIZE)
          .margin({ top: 12 })
          .padding({ top: 8, bottom: 8 })
          .backgroundColor($r('sys.color.multi_color_09'))
          .onClick(() => {
            this.clickAddCar();
          });
        }
        .width(Constants.FULL_SIZE)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })
        .padding({
          left: 18,
          right: 18,
          top: 12,
          bottom: 8,
        })
        .justifyContent(FlexAlign.Start);
      }.margin({ bottom: this.windowBottomHeight });

    }.hideTitleBar(true);
  }

  @Builder
  goodDetailComp() {
    // 商品详情
    Column() {
      Text($r('app.string.good_details'))
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
      Web({ src: '', controller: this.controller }).onControllerAttached(() => {
        this.controller.loadData(this.goodDetails, 'text/html', 'UTF-8');
      }).nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST,
      })
        .margin({ top: 16 }).layoutMode(WebLayoutMode.FIT_CONTENT);
    }
    .width(Constants.FULL_SIZE)
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16,
    })
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
    .margin({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH, bottom: 12 })
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .backgroundColor($r('sys.color.background_primary'));
  }

  @Builder
  goodSpecComp() {
    Column({ space: 8 }) {
      ForEach(this.goodSpecList, (goodSpec: GoodSpec, index: number) => {
        Row() {
          Text(goodSpec.specName)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .width(64)
            .margin({ top: 10, bottom: 10, right: 10 });
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(goodSpec.specVal, (item: GoodSpecInfo) => {
              Row() {
                Text(item.specValName)
                  .fontSize($r('sys.float.Body_S'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.selectSpecArr[index]?.specName === item.specValName ?
                  $r('sys.color.font_on_primary') :
                  $r('sys.color.font_secondary'))
              }
              .padding({
                left: 12,
                right: 12,
                top: 8,
                bottom: 8,
              })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.selectSpecArr[index]?.specName === item.specValName ?
              $r('sys.color.multi_color_09') : $r('sys.color.background_primary'))
              .borderRadius(20)
              .border(this.selectSpecArr[index]?.specName === item.specValName ?
                { width: 0 } : { width: 1, color: '#66000000' })
              .onClick(() => {
                if (this.selectSpecArr && this.selectSpecArr[index]) {
                  let pkgSpec: PackageSpec = {
                    specName: item.specValName,
                    specNum: Number(item.specValNum),
                  };
                  this.selectSpecArr[index] = pkgSpec;
                  getGoodSpecUtil(this.goodInfo?.id, this.selectSpecArr).then((resp) => {
                    this.selectSpecInfo = resp;
                    this.goodSinglePrice = Number(resp.money);
                    this.sumPrice = `${this.goodSinglePrice * Number(this.goodNum)}`;
                  });
                }

              });
            }, (item: GoodSpecInfo) => item.specValId);
          }.margin({ left: 8 });
        }.alignItems(VerticalAlign.Top);
      }, (goodSpec: GoodSpec, index: number) => goodSpec.specId);
    }
    .width(Constants.FULL_SIZE)
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16,
    })
    .borderRadius(16)
    .margin({ top: 12, left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH })
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .justifyContent(FlexAlign.Start)
    .backgroundColor($r('sys.color.background_primary'));
  }

  @Builder
  goodPkgComp() {
    Column() {
      Text($r('app.string.package_details'))
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .margin({ top: 12, bottom: 12, left: Constants.BORDER_WIDTH });
      Column() {
        ForEach(this.goodSpecList, (goodSpec: GoodSpec, index: number) => {
          Column() {
            Row() {
              Column()
                .width(2)
                .height(14)
                .backgroundColor($r('sys.color.multi_color_09'))
                .borderRadius(2);
              Text(`${goodSpec.specName}`)
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .margin({ left: 8 });
            }.width(Constants.FULL_SIZE);

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(goodSpec.specVal, (item: GoodSpecInfo) => {
                Column() {
                  Image(`${CommonUrl.CLOUD_STORAGE_URL}${item.specValLogo}`).width(88).height(80).borderRadius(8);
                  Text(item.specValName)
                    .fontSize($r('sys.float.Caption_M'))
                    .height(26)
                    .fontColor(this.selectSpecArr[index].specName === item.specValName ?
                    $r('sys.color.multi_color_09') :
                    $r('sys.color.font_secondary'))
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 6 })
                    .width(Constants.FULL_SIZE);
                  Text(`x${item.specValNum}`)
                    .fontSize($r('sys.float.Caption_L'))
                    .fontColor(this.selectSpecArr[index].specName === item.specValName ?
                    $r('sys.color.multi_color_09') :
                    $r('sys.color.font_secondary'))
                    .width(Constants.FULL_SIZE)
                    .textAlign(TextAlign.End);
                }
                .width(100)
                .height(140)
                .padding(6)
                .margin({ right: 6, bottom: 12 })
                .backgroundColor(this.selectSpecArr[index].specName === item.specValName ? '#1AED6F21' :
                $r('sys.color.background_secondary'))
                .borderRadius(8)
                .border(this.selectSpecArr[index].specName === item.specValName ?
                  { width: 1, color: $r('sys.color.multi_color_09') } : { width: 0 })
                .onClick(() => {
                  let pkgSpec: PackageSpec = {
                    specName: item.specValName,
                    specNum: Number(item.specValNum),
                  };
                  this.selectSpecArr[index] = pkgSpec;
                  getGoodSpecUtil(this.goodInfo?.id, this.selectSpecArr).then((resp) => {
                    this.selectSpecInfo = resp;
                    this.goodSinglePrice = Number(resp.money);
                    this.sumPrice = `${this.goodSinglePrice * Number(this.goodNum)}`;
                  });
                });
              }, (item: GoodSpecInfo) => item.specValId);
            };

          }.justifyContent(FlexAlign.Start).alignItems(HorizontalAlign.Start);
        }, (goodSpec: GoodSpec, index: number) => goodSpec.specId);
      }
      .width(Constants.FULL_SIZE)
      .constraintSize({ maxWidth: Constants.FULL_SIZE })
      .justifyContent(FlexAlign.Start)
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius(16)
      .padding({
        left: 12,
        right: 12,
        top: 16,
        bottom: 16,
      })
      .margin({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH })

      Text($r('app.string.buy_notes'))
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .margin({ top: 12, bottom: 12, left: Constants.BORDER_WIDTH });
      Column() {
        List({ space: 12 }) {
          ForEach(this.buyNoteList, (item: BuyNote) => {
            ListItem() {
              this.buyNoteCard(item);
            };
          }, (item: BuyNote, index: number) => JSON.stringify(item.noteTitle));
        }.divider({ strokeWidth: 1, startMargin: 28 });
      }
      .width(Constants.FULL_SIZE)
      .constraintSize({ maxWidth: Constants.FULL_SIZE })
      .justifyContent(FlexAlign.Start)
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius(16)
      .padding({
        left: 12,
        right: 12,
        top: 16,
        bottom: 16,
      })
      .margin({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH, bottom: 12 })
    }.alignItems(HorizontalAlign.Start)
  }

  @Builder
  buyNoteCard(item: BuyNote) {
    Row() {
      Image(item.icon).width(16).margin({ top: 2 });
      Column() {
        Text(item.noteTitle)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_primary'))
          .margin({ bottom: 2 })
        ForEach(item.noteDesc, (str: ResourceStr, index: number) => {
          if (index === 1 && !this.expandMore) {
            Text(str)
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .onAreaChange((newValue: Area) => {
                this.textSize = measure.measureTextSize({
                  textContent: str,
                  fontSize: $r('sys.float.Caption_M'),
                })
                if (item.noteDesc.length > 2 ||
                  (this.textSize?.width && newValue.width && px2vp(Number(this.textSize?.width)) > newValue.width)) {
                  this.showMore = true
                }
              })
          } else if (index < 2 || this.expandMore) {
            Text(str)
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
          }
        }, (str: ResourceStr, index: number) => JSON.stringify(str));

        if (item.noteDesc.length > 1 && this.showMore) {
          Row() {
            Text($r('app.string.show_more')).fontSize($r('sys.float.Caption_S')).fontColor($r('sys.color.font_primary'))
            Image(this.expandMore ? $r('app.media.ic_up') : $r('app.media.ic_down'))
              .width(16)
              .height(16)
              .margin({ left: 8 })
          }
          .width(Constants.FULL_SIZE)
          .justifyContent(FlexAlign.Center)
          .margin({ top: 12 })
          .onClick(() => {
            this.expandMore = !this.expandMore
          })
        }

      }.alignItems(HorizontalAlign.Start).margin({ left: 12 }).layoutWeight(1)
    }.width(Constants.FULL_SIZE).alignItems(VerticalAlign.Top);
  }

  clickAddCar() {
    if (this.goodSpecList.length) {
      if (!this.selectSpecInfo) {
        console.error(`add car selectSpecInfo empty.`);
        return;
      }
      addCarSpecUtil(this.selectSpecInfo, this.goodInfo?.id ?? '', Number(this.goodNum)).then(() => {
        promptAction.showToast({ message: $r('app.string.add_success') });
        if (this.goodInfo?.isMust === Constants.GOODS_MUST) {
          this.mustGoodsCtrl.addIsMust(Number(this.goodNum));
        }
        this.pageStack.pop();
      }).catch(() => {
        promptAction.showToast({ message: $r('app.string.add_failed') });
      });
    } else {
      if (this.goodInfo) {
        addCarUtil(this.goodInfo, Number(this.goodNum)).then(() => {
          promptAction.showToast({ message: $r('app.string.add_success') });
          if (this.goodInfo?.isMust === Constants.GOODS_MUST) {
            this.mustGoodsCtrl.addIsMust(Number(this.goodNum));
          }
          this.pageStack.pop();
        }).catch(() => {
          promptAction.showToast({ message: $r('app.string.add_failed') });
        });
      } else {
        console.error(`add car goodInfo empty.`);
      }

    }
  }
}

interface BuyNote {
  icon: Resource;
  noteTitle: Resource;
  noteDesc: Resource[];
}