/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { goToAddressListPage } from 'address_management';
import { BreakpointNameEnum, CommonConstants, GridRowColSetting, RouterModule, WindowUtils } from 'lib_foundation';
import { IServiceDetail, IServiceDetailItem, WindowUtil } from 'module_base';
import { TimeSelect } from 'module_time_select';
import { ServiceText } from '../components/ServiceText';
import { OrderVM } from '../viewmodel/OrderVM';

@Builder
export function OrderPageBuilder() {
  OrderPage()
}

@Extend(Column)
function cardContainer() {
  .width(CommonConstants.FULL_PERCENT)
  .padding(12)
  .borderRadius(16)
  .backgroundColor(Color.White)
  .alignItems(HorizontalAlign.Start)
}

@ComponentV2
export struct OrderPage {
  @Local breakpoint: string = '';
  orderVM: OrderVM = OrderVM.instance(true);

  aboutToAppear(): void {
    WindowUtil.initWindowUtil(this.getUIContext());
    const context = this.getUIContext();
    this.orderVM.init(context);
  }

  onPageShow(): void {
    this.orderVM.getDefaultAddr()
  }

  @Monitor('Api.addressListMock[0].updatedAt')
  onAddressChange() {
    this.orderVM.getDefaultAddr()
  }

  build() {
    NavDestination() {
      Column() {
        GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
          GridCol({
            span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
            offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
          }) {
            Scroll() {
              Column({ space: 12 }) {
                this.CardCore()
                this.CardNote()
                this.CardPay()
              }.width(CommonConstants.FULL_PERCENT)
            }
            .margin({
              top: 8,
              left: GridRowColSetting.getPageMargin(this.breakpoint),
              right: GridRowColSetting.getPageMargin(this.breakpoint)
            })
            .height(`calc(100% - 40vp - ${WindowUtils.windowBottomPadding}vp - 2*${GridRowColSetting.getButtonGutter(
              this.breakpoint)}vp)`)
            .align(Alignment.Top)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
          }

          GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS, }) {
            this.BottomBar()
          }
        }
        .onBreakpointChange((bp) => {
          this.breakpoint = bp;
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .padding({ top: WindowUtils.windowTopPadding })
    .title('立即预约', {
      paddingStart: { value: GridRowColSetting.getPageMargin(this.breakpoint), unit: 1 },
      backgroundColor: $r('sys.color.background_secondary')
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  CardCore() {
    Column({ space: 12 }) {
      this.FormAddr()
      if (this.orderVM.showServiceSelect()) {
        this.SelectService()
      }
      if (this.orderVM.showGoodCard()) {
        this.CardGood()
      }
      if (this.orderVM.showTimeSelect()) {
        this.ServiceTime()
      }
    }
  }

  @Builder
  CardGood() {
    Column({ space: 12 }) {
      Text() {
        Span('服务方式')
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Bold)
          .lineHeight(21)
        Span('（此类服务只有一种服务方式）')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_secondary'))
      }

      Row() {
        SymbolGlyph($r('sys.symbol.clean_light'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_secondary')])
          .margin({ right: 8 })

        Column({ space: 4 }) {
          Text(this.orderVM.goodInfo.title)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .lineHeight(21)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text() {
            Span('￥')
            Span(this.orderVM.getTotalCash())
          }
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.multi_color_08'))
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
    }
    .cardContainer()
  }

  @Builder
  CardNote() {
    Column({ space: 4 }) {
      Text('备注信息')
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Bold)
        .lineHeight(21)
      TextArea({
        placeholder: '请输入您的备注信息',
        text: this.orderVM.remark
      })
        .width('100%')
        .height(114)
        .borderRadius(8)
        .padding({
          top: 8,
          bottom: 8,
          right: 12,
          left: 12
        })
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({ size: $r('sys.float.Body_M'), weight: FontWeight.Regular })
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_M'))
        .lineHeight(19)
        .maxLength(100)
        .showCounter(true)
        .onChange((value) => this.orderVM.remark = value)
    }
    .cardContainer()
  }

  @Builder
  CardPay() {
    Row() {
      Image($r('app.media.ic_huawei_pay')).width(40).height(40).borderRadius(12)
      Text('华为支付').fontSize($r('sys.float.Subtitle_M')).fontWeight(FontWeight.Medium)
        .margin({ left: 12 }).layoutWeight(1)
      Checkbox().select($$this.orderVM.selectPayment)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding(12)
    .margin({ bottom: 6 })
    .borderRadius(16)
    .backgroundColor(Color.White)
  }

  @Builder
  BottomBar() {
    Row() {
      Text() {
        Span('合计：').fontSize($r('sys.float.Body_M')).margin({ right: 2 })
        Span('￥').fontSize($r('sys.float.Body_L')).fontColor($r('sys.color.multi_color_08'))
        Span(this.orderVM.selectService ? this.orderVM.getTotalCash() : '0')
          .fontSize($r('sys.float.Body_L')).fontColor($r('sys.color.multi_color_08'))
      }
      .fontWeight(FontWeight.Medium)

      Blank()
      Button() {
        Text('支付并预约')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(500)
          .fontColor($r('sys.color.font_on_primary'))
      }
      .backgroundColor($r('app.color.common_theme_color'))
      .height(40)
      .padding({
        top: 10,
        bottom: 9,
        left: 40,
        right: 40
      })
      .onClick(() => {
        this.orderVM.onSubmit();
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: GridRowColSetting.getButtonGutter(this.breakpoint),
      bottom: GridRowColSetting.getButtonGutter(this.breakpoint) + WindowUtils.windowBottomPadding,
      left: 16,
      right: 16
    })
    .backgroundColor(Color.White)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  FormAddr() {
    Column({ space: 12 }) {
      Text('请选择服务地址')
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Bold)
        .lineHeight(21)

      if (!this.orderVM.getAddressName().length) {
        Row() {
          Button('添加地址')
            .height(40)
            .width(CommonConstants.FULL_PERCENT)
            .constraintSize({ maxWidth: 448 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Row() {
          SymbolGlyph($r('sys.symbol.local_fill'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_secondary')])
            .margin({ right: 8 })
          Column({ space: 2 }) {
            Text(this.orderVM.getAddressName()[0] ?? '')
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .lineHeight(21)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(this.orderVM.getAddressName()[1])
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_secondary'))
              .lineHeight(19)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontColor([$r('sys.color.icon_secondary')])
            .fontSize(24)
            .margin({ left: 8 })
        }
      }
    }
    .cardContainer()
    .onClick(() => {
      goToAddressListPage(RouterModule.getStack(), {
        onAddressSelected: this.orderVM.jumpAddressManage,
        updateAddress: this.orderVM.updateAddress,
        deleteAddress: this.orderVM.deleteAddress,
        windowTopPadding: WindowUtils.windowTopPadding,
        windowBottomPadding: WindowUtils.windowBottomPadding
      });
    })
  }

  @Builder
  ServiceContentDetailCard() {
    Column({ space: 12 }) {
      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.orderVM.goodInfo.serviceDetailList, (v: IServiceDetail, indexOut: number) => {
            Column({ space: 12 }) {
              Row({ space: 12 }) {
                Text(v.title).fontSize($r('sys.float.Body_M'))
                Text(v.subTitle).fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_secondary'))
              }
              .alignSelf(ItemAlign.Start)

              Grid() {
                ForEach(v.prices, (item: IServiceDetailItem, indexInside: number) => {
                  GridItem() {
                    Column() {
                      ServiceText({ content: item })
                    }
                    .justifyContent(FlexAlign.Center)
                    .height(28)
                    .width(CommonConstants.FULL_PERCENT)
                    .borderRadius(20)
                    .backgroundColor(this.orderVM.isServiceItemSelected(indexOut, indexInside) ?
                      $r('app.color.common_theme_color_5') : $r('sys.color.comp_background_tertiary'))
                    .borderWidth(2)
                    .borderColor(this.orderVM.isServiceItemSelected(indexOut, indexInside) ?
                      $r('sys.color.comp_background_emphasize') : Color.Transparent)
                    .onClick(() => {
                      this.orderVM.onClickServiceItem(indexOut, indexInside);
                    })
                  }
                }, (item: number) => item.toString())
              }
              .columnsTemplate('1fr 1fr')
              .columnsGap(12)
              .rowsGap(12)

              if (indexOut !== this.orderVM.goodInfo.serviceDetailList!.length - 1) {
                Divider()
              }
            }
          }, (v: IServiceDetail) => v.title + v.subTitle)

          Blank().layoutWeight(1)
        }
        .justifyContent(FlexAlign.Start)
      }
      .margin({ top: 12 })
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      Row() {
        Button('确定')
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .width(CommonConstants.FULL_PERCENT)
          .height(40)
          .backgroundColor($r('app.color.common_theme_color'))
          .onClick(() => {
            this.orderVM.onClickServiceButton();
          })
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .padding({ left: 16, right: 16, bottom: this.breakpoint === BreakpointNameEnum.SM ? 40 : 16 })
  }

  @Builder
  SelectService() {
    Column({ space: 12 }) {
      Text('请选择服务')
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Bold)
        .lineHeight(21)

      Row() {
        SymbolGlyph($r('sys.symbol.clean_light'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_secondary')])
          .margin({ right: 8 })

        if (!this.orderVM.selectService) {
          Text('请选择您想要的服务')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .lineHeight(21)
            .layoutWeight(1)
        } else {
          Column({ space: 4 }) {
            Row({ space: 8 }) {
              Text(this.orderVM.getSelectServiceOut()[0] ?? '')
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Medium)
                .lineHeight(21)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(this.orderVM.getSelectServiceOut()[1] ?? '')
                .fontSize($r('sys.float.Body_S'))
                .fontColor($r('sys.color.font_secondary'))
            }

            ServiceText({ content: this.orderVM.getSelectServiceInside() })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontColor([$r('sys.color.icon_secondary')])
          .fontSize(24)
          .margin({ left: 8 })
      }
      .bindSheet($$this.orderVM.showServiceDetail, this.ServiceContentDetailCard(), {
        height: SheetSize.MEDIUM,
        preferType: this.breakpoint === BreakpointNameEnum.SM ? SheetType.BOTTOM : SheetType.CENTER,
        blurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
        title: { title: '选择服务' },
      })
      .onClick(() => {
        this.orderVM.showServiceDetail = true;
      })
    }
    .cardContainer()
  }

  @Builder
  ServiceTime() {
    Column({ space: 12 }) {
      Text('请选择上门时间')
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Bold)
        .lineHeight(21)

      TimeSelect({
        breakpoint: this.breakpoint,
        timeOptions: {
          days: 7,
          startTime: '06:59:00',
          endTime: '19:30:00',
        },
        onTimeSelect: (dateTime: Date | null) => {
          this.orderVM.selectedDateTime = dateTime;
        },
      })
    }
    .cardContainer()
  }
}
