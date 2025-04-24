import { CommonButton, CommonDivider, CommonBanner, CommonScroll } from 'componentlib';

import { LengthUnit } from '@ohos.arkui.node';

import { DatePickerPanel } from '../components/DatePickerPanel';
import { RoomInfoPageVM } from '../viewmodels/RoomInfoPageVM';
import { TagGrid } from '../components/TagGrid';

@ComponentV2
struct RoomInfoPage {
  vm: RoomInfoPageVM = RoomInfoPageVM.instance;

  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column }) {
        CommonScroll({ title: '房间详情' }) {
          Column() {
            CommonBanner({
              covers: this.vm.roomDetail?.banners ?? [],
            });
            this.hotelCardBuilder();

            CommonDivider({ strokeWidth: 5 });

            DatePickerPanel({
              showTopLabel: false,
              paramChangeCallback: () => {
                this.vm.getRoomInfo();
              },
            })
              .margin({
                left: $r('app.string.margin_s'),
                right: $r('app.string.margin_s'),
              });
            CommonDivider({ strokeWidth: 5 });

            this.iconTagsBuilder();

            CommonDivider({ strokeWidth: 5 });

            this.descriptionBuilder();
          };
        };

        Blank();
        Row() {
          CommonButton({
            title: '预订房间',
            handleClick: () => {
              this.vm.jumpToHotelOrder();
            },
          });
        }
        .padding({
          left: $r('app.string.padding_s'),
          right: $r('app.string.padding_s'),
          top: $r('app.string.padding_m'),
        })
        .borderWidth({ top: 1 })
        .borderColor($r('app.color.system_color_grey_level1'))
        .backgroundColor($r('app.color.system_color_background_white'));
      }
      .height($r('app.string.height_percent_full'));
    }
    .hideTitleBar(true)
    .onShown(() => {
      this.vm.initData();
    })
    .onHidden(() => {
      this.vm.clearData();
    });
  }

  @Builder
  hotelCardBuilder() {
    Row() {
      if (this.vm.room && this.vm.roomRate) {
        Column() {
          Row() {
            Text(this.vm.room.name)
              .fontSize($r('app.string.font_size_32'))
              .fontColor($r('app.color.font_color_level1'))
              .fontWeight(500)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ right: $r('app.string.margin_s') });
            TagGrid({
              gridMaxLines: 1,
              data: this.vm.room.tags,
            })
              .width($r('app.string.width_percent_half'));
          };

          Text('价格可能浮动，建议尽快预定~')
            .fontSize($r('app.string.font_size_20'))
            .fontColor($r('app.color.system_color_highlight'))
            .margin({ top: $r('app.string.margin_s') })
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .alignItems(HorizontalAlign.Start);

        Text() {
          Span('￥');
          Span(this.vm.roomRate.rate.toString()).fontSize($r('app.string.font_size_48'));
        }
        .fontSize($r('app.string.font_size_24'))
        .fontColor($r('app.color.system_color_highlight'));
      }
    }
    .width($r('app.string.width_percent_full'))
    .padding($r('app.string.padding_s'))
    .margin({
      top: $r('app.string.margin_s'),
    })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  iconTagsBuilder() {
    Row() {
      if (this.vm.roomDetail?.iconTags) {
        Grid() {
          ForEach(this.vm.roomDetail.iconTags, (item: [ResourceStr, string]) => {
            GridItem() {
              Column() {
                Image(item[0])
                  .height($r('app.integer.icon_size_32'))
                  .margin({ bottom: $r('app.string.margin_s') });
                Text(item[1])
                  .fontSize($r('app.string.font_size_20'))
                  .fontColor($r('app.color.font_color_level1'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
              };
            };
          }, (item: ResourceStr) => JSON.stringify(item));
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr');
      }
    };
  }

  @Builder
  labelBuilder(title: string, label: string) {
    Row() {
      Row() {
        Text(title)
          .fontColor($r('app.color.font_color_level2'))
          .fontSize($r('app.string.font_size_24'));
      }
      .width($r('app.string.height_percent_25'));

      Row() {
        Text(label ? label : '暂无')
          .fontColor($r('app.color.font_color_level1'))
          .fontSize($r('app.string.font_size_24'))
          .lineSpacing({ value: 4, unit: LengthUnit.VP });
      }
      .justifyContent(FlexAlign.Start)
      .layoutWeight(1);
    }
    .alignItems(VerticalAlign.Top)
    .width($r('app.string.width_percent_full'))
    .margin({ bottom: $r('app.string.margin_m') });
  }

  @Builder
  descriptionBuilder() {
    Column() {
      if (this.vm.roomDetail && this.vm.roomRate) {
        this.labelBuilder('优惠来源', this.vm.roomRate.name);
        this.labelBuilder('便利设施', this.vm.roomDetail.amenities);
        this.labelBuilder('床位', this.vm.roomDetail.beds);
        this.labelBuilder('媒体技术', this.vm.roomDetail.mediaTech);
        this.labelBuilder('食品饮品', this.vm.roomDetail.foodDrink);
        this.labelBuilder('洗漱用品', this.vm.roomDetail.toiletries);
        this.labelBuilder('浴室', this.vm.roomDetail.bath);
        this.labelBuilder('其他', this.vm.roomDetail.other);
      }
    }
    .padding($r('app.string.padding_s'));
  }
}

@Builder
export function roomInfoPageBuilder() {
  RoomInfoPage();
}