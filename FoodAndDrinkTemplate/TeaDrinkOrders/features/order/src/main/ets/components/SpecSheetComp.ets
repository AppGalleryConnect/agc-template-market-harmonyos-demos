import {
  CommonUrl,
  Constants,
  Good,
  GoodSpec,
  GoodSpecInfo,
  GoodSpecVal,
  HttpRequest,
  MyCarModel,
  PackageSpec,
  SheetHeaderComp,
  WindowModel,
} from 'common';
import { Decimal } from '@kit.ArkTS';
import { AppStorageV2, promptAction } from '@kit.ArkUI';

@Builder
export function SpecSheetBuilder(item: Good, close: (selectSpec?: GoodSpecInfo) => void, sheetHeight: number = 500,
  isPkg: boolean = false, specInfoOri?: GoodSpecInfo) {
  SpecSheet({
    good: item,
    sheetHeight,
    isPkg,
    specInfoOri,
    close: (selectSpec?: GoodSpecInfo) => {
      close(selectSpec)
    },
  })
}

@ComponentV2
struct SpecSheet {
  @Local myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Param @Require good: Good;
  @Param sheetHeight: number = 500;
  @Param isPkg: boolean = false;
  @Param specInfoOri?: GoodSpecInfo = undefined;
  @Local goodSpecList: Array<GoodSpec> = [];
  @Local selectSpecInfo?: GoodSpecInfo = undefined;
  @Local goodSinglePrice: number = 0;
  @Local sumPrice: string = '0';
  @Local goodNum: number = 1;
  @Local selectSpecArr: Array<PackageSpec> = [];
  @Event close: (selectSpecArr?: GoodSpecInfo) => void = () => {
  }

  aboutToAppear(): void {
    this.sumPrice = this.good?.money ?? '0';
    HttpRequest.getGoodInfo(this.good.id).then((resp: Good) => {
      this.goodSpecList = resp.spec ?? [];
      this.selectSpecArr = this.goodSpecList.map((item: GoodSpec) => {
        let specValId = item.specValId
        if (this.specInfoOri) {
          specValId =
            this.specInfoOri.combination?.find((pkgSpec: PackageSpec) => item.specId === pkgSpec.specId)?.specValId ??
            item.specValId
        }
        let goodSpec = item.specVal.find((spec: GoodSpecVal) => specValId === spec.specValId);
        let result: PackageSpec = {
          specId: item.specId,
          specValId: goodSpec?.specValId ?? item.specVal[0].specValId,
          specName: goodSpec?.specValName ?? item.specVal[0].specValName,
          specNum: Number(goodSpec?.specValNum ?? 0),
        };
        return result;
      });
      this.getGoodSpecInfo()
    });
  }

  getGoodSpecInfo() {
    HttpRequest.getGoodSpec(this.good.id, this.selectSpecArr).then((resp) => {
      this.selectSpecInfo = resp;
      this.goodSinglePrice = Number(resp.money);
      this.sumPrice = new Decimal(this.goodSinglePrice).mul(this.goodNum).toString();
    });
  }

  build() {
    Stack() {
      Column() {
        Column() {
          SheetHeaderComp({
            close: () => {
              this.close()
            },
          })
          Column() {
            Row() {
              Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.good.logo}`).width(80).height(80);
              Column() {
                Column() {
                  Text(this.good.name)
                    .fontSize($r('sys.float.Subtitle_L'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                    .lineHeight(20);
                  Text() {
                    Span($r('app.string.selected'));
                    Span(this.selectSpecArr.map(spec => spec.specName).join(' | '));
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
                    .fontColor('#61860B')
                  Span(`${Number(this.sumPrice)}`)
                    .fontSize($r('sys.float.Subtitle_L'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#61860B')
                }
              }.alignItems(HorizontalAlign.Start).margin({ left: 8 }).justifyContent(FlexAlign.SpaceBetween).height(80)
            }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.Start)

            List({ space: 12 }) {
              ForEach(this.goodSpecList, (goodSpec: GoodSpec, index: number) => {
                ListItem() {
                  Row() {
                    Text(goodSpec.specName)
                      .fontSize($r('sys.float.Body_M'))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .width(60)
                    Flex({ wrap: FlexWrap.Wrap }) {
                      ForEach(goodSpec.specVal, (goodSpecInfo: GoodSpecVal) => {
                        Row() {
                          Text(goodSpecInfo.specValName)
                            .fontSize($r('sys.float.Caption_L'))
                            .fontWeight(FontWeight.Medium)
                            .fontColor(this.selectSpecArr[index].specName === goodSpecInfo.specValName ?
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
                        .backgroundColor(this.selectSpecArr[index].specName === goodSpecInfo.specValName ?
                          '#61860B' : $r('sys.color.comp_background_tertiary'))
                        .borderRadius(12)
                        .onClick(() => {
                          let pkgSpec: PackageSpec = {
                            specId: goodSpec.specId,
                            specLogo: this.good.logo,
                            specValId: goodSpecInfo.specValId,
                            specName: goodSpecInfo.specValName,
                            specNum: Number(goodSpecInfo.specValNum),
                          };
                          this.selectSpecArr[index] = pkgSpec;
                          this.getGoodSpecInfo()
                        });
                      }, (goodSpecInfo: GoodSpecVal) => goodSpecInfo.specValId);
                    }.margin({ left: 12 })
                  }
                }
              }, (goodSpec: GoodSpec) => goodSpec.specId);
            }
            .contentStartOffset(39)
            .contentEndOffset(16)
            .layoutWeight(1)
            .scrollBar(BarState.Off);

            if (!this.isPkg) {
              Column() {
                Row() {
                  Text($r('app.string.good_number'))
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))

                  Row() {
                    Image($r('app.media.ic_subtract')).width(24).onClick(() => {
                      if (this.goodNum > 1) {
                        this.goodNum = this.goodNum - 1
                        this.sumPrice = new Decimal(this.goodSinglePrice).mul(this.goodNum).toString();
                      }
                    });
                    Text(this.goodNum.toString())
                      .fontSize($r('sys.float.Body_L'))
                      .fontColor($r('sys.color.font_primary'))
                      .fontWeight(FontWeight.Medium)
                      .margin({ left: 12, right: 12 })
                    Image($r('app.media.ic_add_car')).width(24).onClick(() => {
                      this.goodNum = this.goodNum + 1
                      this.sumPrice = new Decimal(this.goodSinglePrice).mul(this.goodNum).toString();
                    });
                  }
                }.width(Constants.FULL_SIZE).margin({ top: 20 }).justifyContent(FlexAlign.SpaceBetween).height(43)

                Button($r('app.string.add_car'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_on_primary'))
                  .width(Constants.FULL_SIZE)
                  .constraintSize({ maxWidth: Constants.FULL_SIZE })
                  .backgroundColor('#486602')
                  .onClick(() => {
                    if (!this.selectSpecInfo) {
                      console.info(`add car empty.`);
                      return;
                    }
                    HttpRequest.addCarSpec(this.selectSpecInfo, this.good.id, this.goodNum).then((res: string) => {
                      promptAction.showToast({ message: $r('app.string.add_success') });
                      this.goodNum = 1;
                      if (!this.myCarModel.carCheck.includes(res)) {
                        this.myCarModel.carCheck.push(res)
                      }
                      this.close()
                    });
                  })
                  .margin({ top: 35 })
              }
            }
          }
          .layoutWeight(1)
          .backgroundColor($r('sys.color.background_primary'))
          .borderRadius({ topLeft: 12, topRight: 12 })
          .padding({
            top: 32,
            left: 12,
            right: 12,
          })
          .margin({ top: 8 })

        }
        .width(Constants.FULL_SIZE)
        .padding({
          left: Constants.BORDER_WIDTH,
          right: Constants.BORDER_WIDTH,
          top: 8,
          bottom: this.isPkg ? 100 : this.windowModel.getWindowBottomHeight(),
        })
        .backgroundColor($r('sys.color.background_secondary'))
      }

      Column() {
        Row() {
          Text() {
            Span($r('app.string.selected'));
            Span(this.selectSpecArr.map(spec => spec.specName).join(' | '));
          }
          .fontSize($r('sys.float.Caption_L'))
          .fontColor($r('sys.color.font_secondary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .padding({ top: 8, bottom: 12 })
        .margin({ left: 10 })
        .width(Constants.FULL_SIZE)
        .constraintSize({ maxWidth: Constants.FULL_SIZE })

        Row({ space: 16 }) {
          Button($r('app.string.revert_select'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.fontMainColor'))
            .backgroundColor($r('sys.color.background_primary'))
            .width(148)
            .height(40)
            .border({ width: 1, color: $r('app.color.fontMainColor') })
            .onClick(() => {
              this.selectSpecArr = this.goodSpecList.map((item: GoodSpec) => {
                let goodSpec = item.specVal.find((spec: GoodSpecVal) => item.specValId === spec.specValId);
                let result: PackageSpec = {
                  specId: item?.specId ?? this.goodSpecList[0].specId,
                  specValId: goodSpec?.specValId ?? item.specVal[0].specValId,
                  specName: goodSpec?.name ?? item.specVal[0].specValName,
                  specNum: Number(goodSpec?.specValNum ?? 0),
                };
                return result;
              })
              this.getGoodSpecInfo()
            })
          Button($r('app.string.confirm_select'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .width(148)
            .height(40)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor('#486602')
            .onClick(() => {
              if (!this.selectSpecInfo) {
                console.error(`select spec empty.`);
                return;
              }
              this.close(this.selectSpecInfo)
            })
        }.justifyContent(FlexAlign.Center)
      }
      .width(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.background_primary'))
      .shadow({
        radius: 30,
        color: '#33000000',
        offsetX: 0,
        offsetY: 10,
      })
      .visibility(this.isPkg ? Visibility.Visible : Visibility.None)
      .padding({ bottom: this.windowModel.getWindowBottomHeight() })
    }.width(Constants.FULL_SIZE)
    .height(this.sheetHeight)
    .borderRadius({ topLeft: 32, topRight: 32 })
    .alignContent(Alignment.Bottom)
  }
}