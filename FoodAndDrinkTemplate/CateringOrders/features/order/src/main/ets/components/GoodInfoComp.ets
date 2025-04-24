import {
  addCarSpecUtil,
  addCarUtil,
  CarGoodInfo,
  CommonUrl,
  Constants,
  getGoodInfoUtil,
  GetGoodSpecResp,
  getGoodSpecUtil,
  GetMyCarResp,
  Good,
  GoodRouter,
  GoodSpec,
  GoodSpecEnum,
  GoodSpecInfo,
  PackageSpec,
  SheetHeaderComp,
  updateMyCarUtil,
} from 'common/Index';
import { MeasureText, promptAction } from '@kit.ArkUI';
import { MustGoodsController } from '../models/MustGoodsController';
import { Decimal } from '@kit.ArkTS';

// 子列表
@Component
export struct GoodInfoComp {
  @StorageProp('myCar') @Watch('myCarChange') myCar: GetMyCarResp = new GetMyCarResp();
  @Consume('pageStack') pageStack: NavPathStack;
  @Consume('mustGoodsCtrl') mustGoodsCtrl: MustGoodsController;
  @Prop item: Good;
  @State carGoodInfo?: CarGoodInfo = undefined;
  @State goodNum: string = '1';
  @State windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @State goodSpecList: Array<GoodSpec> = [];
  @State sumPrice: string = this.item?.money ?? '0';
  @State selectSpecArr: Array<PackageSpec> = [];
  @State selectSpecInfo?: GetGoodSpecResp = undefined;
  @State goodSinglePrice: number = 0;
  @State specSheetFlag: boolean = false;
  @State showGoodContent: boolean = true;
  @State goodTextWidth: number = 0;
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.myCarChange();
  }

  myCarChange() {
    this.carGoodInfo = this.myCar.res?.find((item: CarGoodInfo) => item.goodId === this.item.id);
    console.info(`carGoodInfo: ${JSON.stringify(this.carGoodInfo)}.`);
  }

  goodChange() {
    let nameWidth: number = MeasureText.measureText({
      textContent: this.item.name,
      fontSize: '14px',
    });
    if (nameWidth > this.goodTextWidth) {
      this.showGoodContent = false;
    } else {
      this.showGoodContent = true;
    }
  }

  goGoodDetail() {
    this.pageStack.pushPath({ name: 'GoodDetailPage', param: { goodInfo: this.item } as GoodRouter });
  }

  build() {
    Row() {
      // 基础URL拼接返回的imageURL地址
      Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.item?.logo}`).width(82).height(82).borderRadius(8).onClick(() => {
        this.goGoodDetail();
      });
      Column() {
        Column() {
          Text(this.item?.name)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          if (this.showGoodContent) {
            Text(this.item?.content)
              .fontSize($r('sys.float.Caption_M'))
              .lineHeight(14)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 2 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
          }
          Text(Number(this.item?.sales) > 100 ? $r('app.string.sales_more') :
          $r('app.string.month_sale', this.item?.sales))
            .fontSize($r('sys.float.Caption_M'))
            .lineHeight(14)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ top: 2 });
        }.alignItems(HorizontalAlign.Start).onClick(() => {
          this.goGoodDetail();
        });

        Row() {
          Row() {
            Text() {
              Span($r('app.string.currency_symbol'))
                .fontSize($r('sys.float.Caption_S'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
              Span(`${Number(this.item?.money)}`)
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
            };

            if (this.item.specType === GoodSpecEnum.PACKAGE_TYPE) {
              Text($r('app.string.discount', this.item.discount))
                .fontSize($r('sys.float.Caption_L'))
                .fontColor($r('sys.color.multi_color_09'))
                .padding({
                  left: 4,
                  right: 4,
                  top: 2,
                  bottom: 2,
                })
                .borderWidth(1)
                .borderColor($r('sys.color.multi_color_09'))
                .borderRadius(4)
                .margin({ left: 4 });
              Text($r('app.string.currency_symbol_post_params', this.item?.money2))
                .fontSize($r('sys.float.Caption_S'))
                .fontColor($r('sys.color.font_primary'))
                .lineHeight(14)
                .margin({ left: 4 })
                .decoration({
                  type: TextDecorationType.LineThrough,
                  color: $r('sys.color.font_secondary'),
                });
            }

          };


          if (this.item?.specType === GoodSpecEnum.NORMAL) {
            Row() {
              Image($r('app.media.ic_subtract'))
                .width(24)
                .height(24)
                .onClick(() => {
                  if (this.carGoodInfo?.id && this.carGoodInfo?.num && this.carGoodInfo?.num !== '0') {
                    updateMyCarUtil(this.carGoodInfo?.id, Number(this.carGoodInfo?.num) - 1)
                  }
                })
                .visibility(this.carGoodInfo?.num && this.carGoodInfo?.num !== '0' ? Visibility.Visible :
                Visibility.Hidden);
              Text(this.carGoodInfo?.num)
                .margin({ left: 8, right: 8 })
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_secondary'))
                .fontWeight(FontWeight.Medium)
                .visibility(this.carGoodInfo?.num && this.carGoodInfo?.num !== '0' ? Visibility.Visible :
                Visibility.Hidden);
              Image($r('app.media.add_car')).width(24).height(24).onClick(() => {
                addCarUtil(this.item)
              });
              // .visibility(this.carGoodInfo?.num && this.carGoodInfo?.num !== '0' ? Visibility.Visible :
            }.padding({ right: 1 });

          } else {
            Row() {
              Text(this.item?.specType === GoodSpecEnum.PACKAGE_TYPE ? $r('app.string.select_package') :
              $r('app.string.select_spec'))
                .fontSize($r('sys.float.Caption_M'))
                .fontColor($r('sys.color.background_primary'))
                .padding({
                  top: 4,
                  bottom: 4,
                  left: 8,
                  right: 8,
                });
            }
            .borderRadius(14)
            .backgroundColor($r('sys.color.multi_color_09'))
            .onClick(() => {
              if (this.item?.specType === GoodSpecEnum.PACKAGE_TYPE) {
                this.goGoodDetail();
                return;
              }
              getGoodInfoUtil(this.item.id).then((resp: Good) => {
                this.goodSpecList = resp.spec ?? [];
                this.selectSpecArr = this.goodSpecList.map((item: GoodSpec) => {
                  let goodSpec = item.specVal.find((spec: GoodSpecInfo) => item.specValId === spec.specValNum);
                  let result: PackageSpec = {
                    specName: goodSpec?.specValName ?? item.specVal[0].specValName,
                    specNum: Number(goodSpec?.specValNum ?? 0),
                  };
                  return result;
                });
                getGoodSpecUtil(this.item.id, this.selectSpecArr).then((resp) => {
                  this.selectSpecInfo = resp;
                  this.goodSinglePrice = Number(resp.money);
                  this.sumPrice = new Decimal(this.goodSinglePrice).mul(this.goodNum).toString();
                });
                this.goodNum = '1'
                this.specSheetFlag = true;
              });
            });

          }
        }.margin({ top: 6 }).width(Constants.FULL_SIZE).height(22).justifyContent(FlexAlign.SpaceBetween);

      }
      .layoutWeight(1)
      .height(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ left: 5.5, top: 1, bottom: 1 })
      .alignItems(HorizontalAlign.Start)
      .onAreaChange((oldValue, newValue) => {
        if (newValue.width && oldValue.width !== newValue.width) {
          this.goodTextWidth = Number(newValue.width);
          this.goodChange();
        }
      });
    }
    .alignItems(VerticalAlign.Top)
    .width(Constants.FULL_SIZE)
    .height(80)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.item.isMust === Constants.GOODS_MUST && this.mustGoodsCtrl.showMustGoods ? '#0FF9A01E' :
      '#FFFFFF')
    .justifyContent(FlexAlign.SpaceBetween)
    .bindSheet($$this.specSheetFlag, this.specSheet(() => {
      this.specSheetFlag = false
    }), {
      height: 462,
      blurStyle: BlurStyle.Thick,
      showClose: false,
    });
  }

  @Builder
  specSheet(close: () => void) {
    Column() {
      SheetHeaderComp({
        close: () => {
          close()
        },
      })
      Column() {
        Row() {
          Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.item.logo}`).width(80).height(80);
          Column() {
            Column() {
              Text(this.item.name)
                .fontSize($r('sys.float.Subtitle_L'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .lineHeight(20);
              Text() {
                Span($r('app.string.selected'));
                Span(this.selectSpecArr.map(item => item.specName).join(' | '));
              }
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 2 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
            }.alignItems(HorizontalAlign.Start)

            Text() {
              Span($r('app.string.currency_symbol'))
                .fontSize($r('sys.float.Caption_M'))
                .fontColor($r('sys.color.multi_color_09'))
              Span(`${Number(this.sumPrice)}`)
                .fontSize($r('sys.float.Subtitle_L'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.multi_color_09'))
            }
          }.alignItems(HorizontalAlign.Start).margin({ left: 8 }).justifyContent(FlexAlign.SpaceBetween).height(80)
        }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.Start).padding({ left: 12, right: 12 })

        Scroll(this.scroller) {
          Column() {
            ForEach(this.goodSpecList, (goodSpec: GoodSpec, index: number) => {
              Column() {
                Text(goodSpec.specName)
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(goodSpec.specVal, (item: GoodSpecInfo) => {
                    Row() {
                      Text(item.specValName)
                        .fontSize($r('sys.float.Caption_M'))
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.selectSpecArr[index].specName === item.specValName ?
                        $r('sys.color.font_on_primary') :
                        $r('sys.color.font_primary'))
                    }
                    .padding({
                      left: 12,
                      right: 12,
                      top: 4,
                      bottom: 4,
                    })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(this.selectSpecArr[index].specName === item.specValName ?
                    $r('sys.color.multi_color_09') : $r('sys.color.comp_background_tertiary'))
                    .borderRadius(12)
                    .onClick(() => {
                      let pkgSpec: PackageSpec = {
                        specName: item.specValName,
                        specNum: Number(item.specValNum),
                      };
                      this.selectSpecArr[index] = pkgSpec;
                      getGoodSpecUtil(this.item.id, this.selectSpecArr).then((resp) => {
                        this.selectSpecInfo = resp;
                        this.goodSinglePrice = Number(resp.money);
                        this.sumPrice = new Decimal(this.goodSinglePrice).mul(this.goodNum).toString();
                      });
                    });
                  }, (item: GoodSpecInfo) => item.specValId);
                }.margin({ top: 12 })

              }.alignItems(HorizontalAlign.Start).margin({ top: 20 });
            }, (goodSpec: GoodSpec, index: number) => goodSpec.specId);
            Row() {
              Text($r('app.string.good_number'))
                .fontSize($r('sys.float.Body_S'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))

              Row() {
                Image($r('app.media.ic_subtract')).width(24).onClick(() => {
                  if (Number(this.goodNum) > 1) {
                    this.goodNum = `${Number(this.goodNum) - 1}`;
                    this.sumPrice = new Decimal(this.goodSinglePrice).mul(this.goodNum).toString();
                  }
                });
                Text(this.goodNum)
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor($r('sys.color.font_secondary'))
                  .fontWeight(FontWeight.Medium)
                  .margin({ left: 8, right: 8 })
                Image($r('app.media.add_car')).width(24).onClick(() => {
                  this.goodNum = `${Number(this.goodNum) + 1}`;
                  this.sumPrice = new Decimal(this.goodSinglePrice).mul(this.goodNum).toString();
                });
              }
            }.width(Constants.FULL_SIZE).margin({ top: 20 }).justifyContent(FlexAlign.SpaceBetween).height(43)
          };
        }
        .layoutWeight(1)
        .padding({ left: 12, right: 12 })
        .scrollBar(BarState.Off);

        Row() {
          Button($r('app.string.add_car'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .margin(2)
            .width(Constants.FULL_SIZE)
            .constraintSize({ maxWidth: Constants.FULL_SIZE })
            .backgroundColor($r('sys.color.multi_color_09'))
            .onClick(() => {
              if (!this.selectSpecInfo) {
                console.info(`add car empty.`);
                return;
              }
              addCarSpecUtil(this.selectSpecInfo, this.item.id, Number(this.goodNum)).then(() => {
                promptAction.showToast({ message: $r('app.string.add_success') });
                if (this.selectSpecInfo?.isMust === Constants.GOODS_MUST) {
                  this.mustGoodsCtrl.addIsMust();
                }
                this.goodNum = '1';
                this.specSheetFlag = false;
              });
            });
        }.margin({ top: 24, bottom: 32 })
      }
      .layoutWeight(1)
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius({ topLeft: 12, topRight: 12 })
      .padding({ top: 16 })
      .margin({ top: 8 })

    }
    .width(Constants.FULL_SIZE)
    .padding({ left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH, top: 8 })
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius({ topLeft: 32, topRight: 32 })
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
  }
}