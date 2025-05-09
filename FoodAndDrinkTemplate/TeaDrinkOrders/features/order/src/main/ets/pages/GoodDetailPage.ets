import {
  CommonUrl,
  Constants,
  Good,
  GoodRouter,
  GoodSpec,
  GoodSpecEnum,
  GoodSpecInfo,
  GoodSpecVal,
  HttpRequest,
  MyCarModel,
  NavHeaderBar,
  PackageSpec,
  WindowModel,
} from 'common/Index';
import web_webview from '@ohos.web.webview';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { SpecSheetBuilder } from '../components/SpecSheetComp';
import { Decimal } from '@kit.ArkTS';
import { PackageCarListComp } from '../components/PackageCarListComp';

@Builder
export function GoodDetailPageBuilder() {
  GoodDetailPage()
}

@ComponentV2
struct GoodDetailPage {
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()
  @Local myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!
  @Local goodInfo?: Good = undefined;
  @Local packageCar: Array<GoodSpecInfo> = [];
  @Local goodSpecList: Array<GoodSpec> = [];
  @Local selectSpecArr: Array<PackageSpec> = [];
  @Local selectSpecInfo?: GoodSpecInfo = undefined;
  @Local sumPrice: string = this.goodInfo?.money ?? '0';
  @Local goodSinglePrice: number = 0;
  @Local goodNum: number = 1;
  @Local specSheetFlag: boolean = false;
  @Local sheetGood?: Good;
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Local goodDetails: string = '';
  @Local swiperIndex: number = 0;
  @Local showCarList: boolean = false;
  private scroller: ListScroller = new ListScroller();
  // Scroll的偏移量
  @Local scrollOffset: number = 0;
  // 状态栏组件的透明度
  @Local headOpacity: number = 0;
  // 透明度默认值
  private opacityDefaultValue: number = 1;
  // 透明度计算基数
  private opacityComputeRadix: number = 35;
  controller: web_webview.WebviewController = new web_webview.WebviewController();

  aboutToAppear(): void {
    this.getParams();
    HttpRequest.getGoodInfo(this.goodInfo?.id).then((resp: Good) => {
      this.goodInfo = resp;
      if (resp.spec?.length && resp.spec?.length > 0) {
        this.goodSpecList = resp.spec ?? [];
        this.selectSpecArr = this.goodSpecList.map((item: GoodSpec) => {
          let goodSpec = item.specVal.find((spec: GoodSpecVal) => item.specValId === spec.specValId);
          let result: PackageSpec = { specName: goodSpec?.specValName, specNum: Number(goodSpec?.specValNum ?? 1) };
          return result;
        });

        HttpRequest.getGoodSpec(this.goodInfo?.id, this.selectSpecArr).then((res) => {
          this.selectSpecInfo = res;
          this.goodSinglePrice = Number(res.money);
          this.sumPrice = new Decimal(this.goodSinglePrice).mul(this.goodNum).toString()
        });
      } else {
        this.goodSinglePrice = Number(resp.money);
        this.sumPrice = new Decimal(this.goodSinglePrice).mul(this.goodNum).toString()
      }
      this.goodDetails =
        `<meta name="viewport" content="width=device-width, initial-scale=1.0">${this.goodInfo?.details ?? ''}`;
    });
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
      Stack() {
        Stack() {
          List({ space: 12, scroller: this.scroller }) {
            ListItem() {
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
                      .fontSize(18)
                      .fontWeight(500)
                      .fontColor($r('sys.color.font_primary'))
                      .lineHeight(20);
                    Text() {
                      Span($r('app.string.currency_symbol')).fontSize(10).fontWeight(500).lineHeight(14);
                      Span(this.goodInfo?.money).fontSize(18).fontWeight(500).lineHeight(20);
                    }.fontColor($r('app.color.mainColor'));
                  }.width(Constants.FULL_SIZE)
                  .justifyContent(FlexAlign.SpaceBetween);

                  Row() {
                    Text(Number(this.goodInfo?.sales) > 100 ? $r('app.string.sales_more') :
                    $r('app.string.month_sale', this.goodInfo?.sales))
                      .fontSize(10)
                      .fontColor($r('sys.color.mask_tertiary'))
                      .lineHeight(14)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .margin({ top: 8 });
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
              .backgroundColor($r('sys.color.white'));
            }

            if (this.goodInfo?.specType === GoodSpecEnum.PACKAGE_TYPE) {
              ListItem() {
                this.goodPkgComp();
              }
            } else {
              ListItem() {
                this.goodSpecComp();
              }

              ListItem() {
                this.goodDetailComp();
              }
            }
          }
          .backgroundColor('#F1F3F5')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
          .width(Constants.FULL_SIZE)
          .contentStartOffset(12)
          .contentEndOffset(12)
          .onWillScroll((scrollOffset: number, scrollState: ScrollState, scrollSource: ScrollSource) => {
            this.scrollOffset = this.scroller.currentOffset().yOffset;
            if (this.scrollOffset <= this.opacityComputeRadix) {
              this.headOpacity = this.scrollOffset / this.opacityComputeRadix;
            } else {
              this.headOpacity = this.opacityDefaultValue;
            }
          })

          NavHeaderBar({ title: $r('app.string.good_details'), headOpacity: this.headOpacity })
          NavHeaderBar({
            title: $r('app.string.good_details'),
            headOpacity: this.opacityDefaultValue,
            hasBgColor: false,
          })
        }.alignContent(Alignment.Top).padding({ bottom: 134 })
        .bindSheet($$this.specSheetFlag, SpecSheetBuilder(this.sheetGood!, (selectSpec?: GoodSpecInfo) => {
          this.closeSpec(selectSpec)
        }, 430, true, this.packageCar.find((item: GoodSpecInfo) => this.sheetGood?.id === item.goodId)), {
          height: 430,
          blurStyle: BlurStyle.Thick,
          backgroundColor: '#E6FFFFFF',
          showClose: false,
        })

        if (this.goodInfo?.specType === GoodSpecEnum.PACKAGE_TYPE) {
          PackageCarListComp({
            packageCarList: this.packageCar, changeCarPanel: (flag: boolean) => {
              this.changeCarPanel(flag)
            }, clearCar: (specId?: string) => {
              this.removeCarSpec(specId)
            },
          }).visibility(this.showCarList ? Visibility.Visible : Visibility.Hidden)
          this.packageFooter()
        } else {
          this.normalFooter()
        }
      }.alignContent(Alignment.Bottom)

    }.hideTitleBar(true).onBackPressed(() => {
      if (this.specSheetFlag) {
        this.specSheetFlag = false
        return true
      }
      if (this.showCarList) {
        this.showCarList = false
        return true
      }
      return false
    })
  }

  @Builder
  goodSpecComp() {
    Column() {
      ForEach(this.goodSpecList, (goodSpec: GoodSpec, index: number) => {
        Row({ space: 16 }) {
          Text(goodSpec.specName)
            .fontSize(16)
            .fontWeight(500)
            .fontColor($r('sys.color.font_primary'))
            .width(64)
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(goodSpec.specVal, (item: GoodSpecVal) => {
              Row() {
                Text(item.specValName)
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.selectSpecArr[index]?.specName === item.specValName ? '#E6FFFFFF' :
                  $r('sys.color.font_primary'))
              }
              .padding({
                left: 12,
                right: 12,
                top: 8,
                bottom: 8,
              })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.selectSpecArr[index]?.specName === item.specValName ? '#61860B' : '#0D000000')
              .borderRadius(20)
              .onClick(() => {
                if (this.selectSpecArr && this.selectSpecArr[index]) {
                  let pkgSpec: PackageSpec = {
                    specName: item.specValName,
                    specNum: Number(item.specValNum),
                  };
                  this.selectSpecArr[index] = pkgSpec;
                  HttpRequest.getGoodSpec(this.goodInfo?.id, this.selectSpecArr).then((resp) => {
                    this.selectSpecInfo = resp;
                    this.goodSinglePrice = Number(resp.money);
                    this.sumPrice = new Decimal(this.goodSinglePrice).mul(this.goodNum).toString()
                  });
                }

              });
            }, (item: GoodSpecVal) => item.specValId);
          }.margin({ left: 16 });

        }
      }, (goodSpec: GoodSpec) => goodSpec.specId);
    }
    .width(Constants.FULL_SIZE)
    .padding(12)
    .margin({
      left: 16,
      right: 16,
      top: 12,
    })
    .borderRadius(16)
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .justifyContent(FlexAlign.Start)
    .backgroundColor($r('sys.color.white'));
  }

  @Builder
  goodPkgComp() {
    Column({ space: 12 }) {
      ForEach(this.goodSpecList, (goodSpec: GoodSpec, index: number) => {
        Column() {
          Text(`${goodSpec.specName}`)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))

          Grid() {
            ForEach(goodSpec.specVal, (item: GoodSpecVal) => {
              GridItem() {
                Column() {
                  Stack() {
                    Image(`${CommonUrl.CLOUD_STORAGE_URL}${item.logo}`).width(80).height(80).borderRadius(8);
                    Text('1')
                      .fontSize(10)
                      .fontColor($r('sys.color.white'))
                      .backgroundColor($r('sys.color.black'))
                      .borderRadius(8)
                      .padding({
                        top: 2,
                        bottom: 2,
                        left: 6,
                        right: 6,
                      })
                      .margin({ top: 2, right: 2 })
                      .visibility(item.selected ? Visibility.Visible : Visibility.None)
                  }
                  .alignContent(Alignment.TopEnd)

                  Text(item.name)
                    .fontSize(14)
                    .fontColor($r('sys.color.font_primary'))
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 8 })
                    .width(80)
                    .height(40)
                    .textAlign(TextAlign.Center)
                  Image($r('app.media.ic_plus_pkg'))
                    .width(24)
                    .height(24)
                    .padding(5)
                    .borderRadius(14)
                    .backgroundColor('#1A000000')
                    .margin({ top: 8 })
                    .onClick(() => {
                      if (goodSpec.selected) {
                        promptAction.showToast({ message: $r('app.string.pkg_spec_selected') })
                        return
                      }
                      HttpRequest.getGoodInfo(item.id).then(res => {
                        this.sheetGood = res
                        this.specSheetFlag = true
                      })
                    })
                    .visibility(item.selected ? Visibility.None : Visibility.Visible)
                  Text($r('app.string.change_spec'))
                    .fontSize(12)
                    .fontColor($r('app.color.fontMainColor'))
                    .padding({ left: 8, right: 8 })
                    .border({ width: 1, color: $r('app.color.fontMainColor'), radius: 11 })
                    .margin({ top: 8 })
                    .height(20)
                    .visibility(item.selected ? Visibility.Visible : Visibility.None)
                    .onClick(() => {
                      HttpRequest.getGoodInfo(item.id).then(res => {
                        this.sheetGood = res
                        this.specSheetFlag = true
                      })
                    })
                }
                .padding(4)
                .backgroundColor(item.selected ? '#1A61860B' : $r('sys.color.background_primary'))
                .borderRadius(8)
              }
            }, (item: GoodSpecVal, index: number) => item.specValId);
          }.margin({ top: 11 }).maxCount(3).rowsGap(12).columnsGap(32)
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .padding(12)
        .borderRadius(16)
        .backgroundColor($r('sys.color.background_primary'))
        .width(Constants.FULL_SIZE)
      }, (goodSpec: GoodSpec) => goodSpec.specId);
    }
    .width(Constants.FULL_SIZE)
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .margin({
      left: 12,
      right: 12,
    })

  }

  @Builder
  normalFooter() {
    Column() {
      Row() {
        Column() {
          Text() {
            Span($r('app.string.currency_symbol'))
              .fontSize($r('sys.float.Caption_M'))
              .fontWeight(FontWeight.Medium)
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
          .margin({ top: 2 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
        }.alignItems(HorizontalAlign.Start).layoutWeight(1);

        Row() {
          Image($r('app.media.ic_subtract_car')).width(22).onClick(() => {
            if (this.goodNum > 1) {
              this.goodNum = this.goodNum - 1
              this.sumPrice = new Decimal(this.goodSinglePrice).mul(this.goodNum).toString()
            }
          });
          Text(this.goodNum.toString())
            .margin({ left: 12, right: 12 })
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.mask_secondary'));
          Image($r('app.media.ic_add_car')).width(22).onClick(() => {
            this.goodNum = this.goodNum + 1
            this.sumPrice = new Decimal(this.goodSinglePrice).mul(this.goodNum).toString()
          });
        }.alignItems(VerticalAlign.Center);
      }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween);

      Button($r('app.string.add_car'))
        .fontSize(14)
        .fontWeight(500)
        .fontColor($r('sys.color.white'))
        .width(336)
        .height(40)
        .margin({ top: 16 })
        .backgroundColor($r('app.color.mainColor'))
        .borderRadius(16)
        .onClick(() => {
          this.clickAddCar();
        });
    }
    .width(Constants.FULL_SIZE)
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .backgroundColor($r('sys.color.background_primary'))
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: this.windowModel.getWindowBottomHeight(),
    })
    .justifyContent(FlexAlign.Start)

  }

  @Builder
  packageFooter() {
    Column() {
      Row() {
        Text() {
          Span($r('app.string.currency_symbol'))
            .fontSize(10)
            .fontColor($r('sys.color.font_primary'))
            .lineHeight(14);
          Span('0')
            .fontSize(16)
            .fontWeight(500)
            .fontColor($r('sys.color.font_primary'))
            .lineHeight(20);
        }

        Text($r('app.string.no_select_item')).fontSize(10).fontColor($r('sys.color.font_secondary'))
      }
      .width(Constants.FULL_SIZE)
      .height(36)
      .visibility(this.packageCar.length === this.goodSpecList.length ? Visibility.None : Visibility.Visible)

      Row({ space: 16 }) {
        Row() {
          Text($r('app.string.btn_package_select'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor('#486602')
            .width(88)
          if (this.packageCar.length) {
            Text(this.packageCar.length.toString())
              .fontSize(10)
              .fontColor($r('sys.color.white'))
              .backgroundColor($r('sys.color.black'))
              .borderRadius(8)
              .padding({
                top: 2,
                bottom: 2,
                left: 6,
                right: 6,
              })
              .margin({ left: 2 })
          }
        }
        .width(148)
        .justifyContent(FlexAlign.Center)
        .padding({
          top: 10,
          bottom: 10,
        })
        .border({ width: 1, radius: 20, color: '#486602' })
        .onClick(() => {
          this.changeCarPanel(!this.showCarList)
        })

        Row() {
          Text($r('app.string.btn_add_pkg_car'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
        }
        .opacity(this.packageCar.length === this.goodSpecList.length ? 1 : 0.4)
        .width(148)
        .justifyContent(FlexAlign.Center)
        .borderRadius(20)
        .backgroundColor('#486602')
        .padding({
          top: 10,
          bottom: 10,
        })
        .onClick(() => {
          if (this.packageCar.length === this.goodSpecList.length) {
            this.clickAddCar();
          }
        });
      }.padding({ top: 8, bottom: 8 })
    }
    .width(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_primary'))
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: 8,
    })
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  goodDetailComp() {
    // 商品详情
    Column() {
      Text($r('app.string.good_details'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
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
    .margin({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH})
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .backgroundColor($r('sys.color.background_primary'));
  }

  clickAddCar() {
    if (this.goodInfo?.specType === GoodSpecEnum.SPEC_TYPE) {
      if (!this.selectSpecInfo) {
        console.error(`add car selectSpecInfo empty.`);
        return;
      }
      HttpRequest.addCarSpec(this.selectSpecInfo, this.goodInfo?.id ?? '', this.goodNum).then((res: string) => {
        promptAction.showToast({ message: $r('app.string.add_success') });
        if (!this.myCarModel.carCheck.includes(res)) {
          this.myCarModel.carCheck.push(res)
        }
        this.pageStack.pop();
      }).catch(() => {
        promptAction.showToast({ message: $r('app.string.add_failed') });
      });
    } else if (this.goodInfo?.specType === GoodSpecEnum.PACKAGE_TYPE) {
      if (!this.packageCar.length) {
        console.error(`add pkg car selectSpecInfo empty.`);
        return;
      }
      let selectSpecInfo = new GoodSpecInfo()
      selectSpecInfo.money = this.goodInfo.money
      selectSpecInfo.specType = this.goodInfo.specType
      selectSpecInfo.combination = this.packageCar.map((item: GoodSpecInfo) => {
        return {
          specName: item.goodName,
          specLogo: item.goodLogo,
          specVal: item.spec,
          specNum: item.num,
        } as PackageSpec
      })
      selectSpecInfo.spec = this.packageCar.map((item: GoodSpecInfo) => `${item.goodId}${item.spec}`).join('/')
      HttpRequest.addCarSpec(selectSpecInfo, this.goodInfo?.id ?? '', 1).then((res: string) => {
        promptAction.showToast({ message: $r('app.string.add_success') });
        if (!this.myCarModel.carCheck.includes(res)) {
          this.myCarModel.carCheck.push(res)
        }
        this.pageStack.pop();
      }).catch(() => {
        promptAction.showToast({ message: $r('app.string.add_failed') });
      });
    }
  }

  closeSpec(selectSpec?: GoodSpecInfo) {
    if (selectSpec) {
      this.goodSpecList.forEach((item: GoodSpec) => {
        let spec = item.specVal.find((spec: GoodSpecVal) => spec.id === this.sheetGood?.id)
        if (spec) {
          spec.selected = true
          item.selected = true
          selectSpec.specId = item.specId
          selectSpec.num = 1
        }
      })

      if (this.packageCar.some((item: GoodSpecInfo) => item.specId === selectSpec.specId)) {
        this.packageCar =
          this.packageCar.map((item: GoodSpecInfo) => item.specId === selectSpec.specId ? selectSpec : item)
      } else {
        this.packageCar.push(selectSpec)
      }

    }
    this.specSheetFlag = false
  }

  removeCarSpec(specId?: string) {
    this.goodSpecList.forEach((item: GoodSpec) => {
      if (specId) {
        if (item.specId === specId) {
          item.specVal.forEach((spec: GoodSpecVal) => {
            spec.selected = false
          })
          item.selected = false
        }
      } else {
        item.specVal.forEach((spec: GoodSpecVal) => {
          spec.selected = false
        })
        item.selected = false
      }

    })
    this.packageCar = this.packageCar.filter(item => specId && item.specId !== specId)
  }

  changeCarPanel(flag: boolean) {
    this.showCarList = flag
  }
}