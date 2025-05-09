import { TicketStatus, TimeTicketInfo, TimeSegment, BuyStatus, TicketTypeInfo } from '../types/Index';
import { BuyVM } from '../viewModels/BuyVM';
import { RouterMap, RouterModule, FormatUtil, CommonConstants } from 'commonlib';
import { UICalendarPicker, TypePicker, DialogType, SwiperDirection } from 'uicalendarpicker';
import { NumberBox } from '../component/NumberBox';

@Builder
export function BuyTicketBuilder() {
  BuyTicket();
}


@Entry
@ComponentV2
struct BuyTicket {
  vm: BuyVM = BuyVM.instance;

  aboutToAppear(): void {
    this.vm.initData();
    this.vm.getTimeTicketInfo();
  }

  isRequired(): boolean {
    if (this.vm.totalTicket <= 0) {
      return false;
    }
    if (!this.vm.selectedTime) {
      return false;
    }
    if (!this.vm.currentSelected) {
      return false;
    }
    return true;
  }

  @Builder
  noticeDialogBuilder() {
    Column() {

      ForEach(this.vm.notice, (item: string) => {
        Text(item).fontSize(CommonConstants.FONT_SIZE_L).fontColor(CommonConstants.FONT_COLOR_BLACK);
      }, (item: string) => item);

    }.width('100%').padding({ left: 20, right: 20 }).alignItems(HorizontalAlign.Start);
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Column() {
              Column() {
                Text('参观日期').margin({ bottom: 10 });
                Row({ space: 10 }) {
                  ForEach(this.vm.dayList, (item: TimeTicketInfo) => {
                    Column() {
                      Text(item.day)
                        .fontColor($r('app.color.font_color_green'))
                        .fontSize($r('sys.float.ohos_id_text_size_body2'));
                      Text(FormatUtil.dateAsMD(item.date))
                        .fontColor($r('app.color.font_color_green'))
                        .fontSize($r('sys.float.ohos_id_text_size_body3'))
                        .margin(2);
                      Text(item.statusCn)
                        .fontColor($r('app.color.font_color_green'))
                        .fontSize($r('sys.float.ohos_id_text_size_caption'));
                    }
                    .checkBoxStyle()
                    .justifyContent(FlexAlign.Center)
                    .backgroundColor(this.vm.currentSelected?.date === item.date ?
                    $r('sys.color.ohos_id_color_palette_aux3') : '')
                    .opacity(item.status !== TicketStatus.HAVE ? $r('sys.float.ohos_id_alpha_disabled') : 1)
                    .enabled(item.status === TicketStatus.HAVE ? true : false)
                    .onClick(() => {
                      if (this.vm.currentSelected?.date !== item.date) {
                        this.vm.currentSelected = item;
                        this.vm.selectedTime = '';
                      }
                    });
                  }, (item: TimeTicketInfo, index: number) => item.date.toString());

                  Column() {
                    UICalendarPicker({
                      type: TypePicker.SINGLE,
                      dialogType: DialogType.SHEET,
                      enableSelectTime: true,
                      customColor: $r('app.color.font_color_green'),
                      swiperDirection: SwiperDirection.VERTICAL,
                      selected: this.vm.selected,
                      disabledDates: this.vm.disableData,
                      ableDates: this.vm.ableData,
                      customBuildPanel: (): void => {
                        this.customPanelBuilder();
                      },
                      onSelected: (res) => {
                        this.vm.selected = res as Date;
                        this.vm.getCurrentPickDay(res as Date);
                      },
                    });
                  }.checkBoxStyle();

                }.margin({ bottom: 24 }).height(70);

                //  参观时间
                if (this.vm.currentSelected) {
                  Text('参观时间').margin({ bottom: 10 });
                  Row({ space: 10 }) {
                    ForEach(this.vm.currentSelected.timeSegment, (item: TimeSegment) => {
                      Column() {
                        Text(item.label)
                          .fontColor($r('app.color.font_color_green'))
                          .fontSize($r('sys.float.ohos_id_text_size_body2'));
                        Text(item.buyStatusCn)
                          .fontColor($r('app.color.font_color_green'))
                          .fontSize($r('sys.float.ohos_id_text_size_caption'));
                      }
                      .TimeBoxStyle()
                      .backgroundColor(this.vm.selectedTime === item.label ?
                      $r('sys.color.ohos_id_color_palette_aux3') : '')
                      .justifyContent(FlexAlign.Center)
                      .opacity(this.vm.currentSelected?.status !== BuyStatus.ABLE ?
                      $r('sys.float.ohos_id_alpha_disabled') : 1)
                      .enabled(this.vm.currentSelected?.status === BuyStatus.ABLE)
                      .onClick(() => {
                        this.vm.selectedTime = item.label;
                      });
                    }, (item: TimeSegment) => item.label);


                  }.margin({ bottom: 14 });
                }
              }.alignItems(HorizontalAlign.Start).padding(10).width('100%');
            }.backgroundColor($r('sys.color.ohos_id_color_background')).constraintSize({ minHeight: 270 });

            if (this.vm.currentSelected && this.vm.selectedTime) {
              this.selectTicketBuilder();
            }

          }.constraintSize({
            minHeight: '100%',
          });
        }.height('calc(100% - 65vp)').scrollBar(BarState.Off).padding({ bottom: 40 });

        this.buttonBarBuilder();

      }
      .width('100%')
      .height(CommonConstants.FULL_HEIGHT)
      .backgroundColor(CommonConstants.BG_COLOR_GRAY)
      .padding({ top: 10 });

    }.title('购票信息').onReady(() => {
      this.vm.getTicketType();
    });
  }

  @Builder
  selectTicketBuilder() {
    Column() {
      Text('选择票种')
        .margin({ top: 5, bottom: 5 })
        .fontSize(16)
        .fontColor(CommonConstants.FONT_COLOR_BLACK)
        .fontWeight(500)
        .width('100%');
      ForEach(this.vm.selectTicketInfo, (item: TicketTypeInfo, index: number) => {
        if (index !== 0) {
          Divider();
        }
        Column() {
          Row() {
            Text(item.typeCn)
              .fontSize(CommonConstants.FONT_SIZE_M)
              .fontColor(CommonConstants.FONT_COLOR_BLACK)
              .fontWeight(500);
            Text('¥' + item.price)
              .fontColor(CommonConstants.FONT_COLOR_GREEN)
              .fontSize(CommonConstants.FONT_SIZE_M)
              .fontWeight(500);
          }.width('100%').justifyContent(FlexAlign.SpaceBetween);

          Row() {
            Column() {
              Text(item.des)
                .fontSize(CommonConstants.FONT_SIZE_S)
                .fontColor(CommonConstants.FONT_COLOR_GRAY)
                .fontWeight(500)
                .width(192)
                .margin({ top: 6, bottom: 8 });
              Row() {
                Text('购买须知')
                  .fontWeight(500)
                  .fontSize(CommonConstants.FONT_SIZE_S)
                  .fontColor(CommonConstants.FONT_COLOR_GREEN);
                Image($r('app.media.icon_public_arrow_right')).width(10);
              }.onClick(() => {
                this.vm.dialogVisible = true;
                this.vm.notice = item.notice;
              });
            }.width(192).alignItems(HorizontalAlign.Start);

            NumberBox({
              value: item.count, limit: item.limit, onchange: (value) => {
                this.vm.selectTicketInfo[index].count = value;
                this.vm.getTotalTicket();
              },
            }).alignSelf(ItemAlign.End);
          }.width('100%').justifyContent(FlexAlign.SpaceBetween);
        }.alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.SpaceBetween).margin({ top: 10, bottom: 10 });
      }, (item: TicketTypeInfo, index: number) => item.typeCn + item.count);
    }
    .padding(10)
    .backgroundColor(CommonConstants.BG_COLOR_WHITE)
    .width('100%')
    .margin({ top: 10 })
    .bindSheet($$this.vm.dialogVisible, this.noticeDialogBuilder(),
      { title: { title: '购票须知' }, detents: [SheetSize.MEDIUM, SheetSize.LARGE, 400] });
  }

  @Builder
  buttonBarBuilder() {
    Row() {
      Row() {
        Text('总计').fontWeight(500).fontSize(CommonConstants.FONT_SIZE_M).fontColor(CommonConstants.FONT_COLOR_BLACK);
        Text(this.vm.totalTicket.toString())
          .fontSize(20)
          .fontWeight(500)
          .fontColor(CommonConstants.FONT_COLOR_BLACK)
          .margin({ top: 2, left: 2, right: 2 });
        Text('张').fontWeight(500).fontSize(CommonConstants.FONT_SIZE_M).fontColor(CommonConstants.FONT_COLOR_BLACK);
      }.height(24).alignItems(VerticalAlign.Bottom);

      Button('购票')
        .width(120)
        .backgroundColor(this.isRequired() ? CommonConstants.FONT_COLOR_GREEN : CommonConstants.BG_COLOR_GREEN)
        .borderRadius(20)
        .onClick(() => {
          if (this.isRequired()) {
            RouterModule.push({ url: RouterMap.BUY_INFO });
          }
        });
    }
    .width('100%')
    .height(65)
    .padding({
      top: 15,
      bottom: 10,
      left: 10,
      right: 10,
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(CommonConstants.BG_COLOR_WHITE);
  }

  @Styles
  checkBoxStyle() {
    .borderRadius(4)
    .border({ width: 1, color: $r('sys.color.ohos_id_color_palette_aux3') })
    .height(70)
    .width(60);
  }

  @Styles
  TimeBoxStyle() {
    .borderRadius(4)
    .border({ width: 1, color: $r('sys.color.ohos_id_color_palette_aux3') })
    .height(70)
    .width(100);
  }

  @Builder
  customPanelBuilder() {
    Row() {
      Text('指定日期')
        .fontColor($r('app.color.font_color_green'))
        .width(28)
        .fontSize($r('sys.float.ohos_id_text_size_body2'));
      Image($r('app.media.icon_public_arrow_right')).width(12);
    }.height(70).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center).width(60);
  }
}
