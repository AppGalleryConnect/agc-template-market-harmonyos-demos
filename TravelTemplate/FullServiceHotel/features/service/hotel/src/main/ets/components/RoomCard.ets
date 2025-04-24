import { util } from '@kit.ArkTS';

import { MappedRoom, MappedRoomRate } from '../models/MappedRoom';
import { MappedHotel } from '../models/MappedHotel';
import { HotelBookingVM } from '../viewmodels/HotelBookingVM';
import { RouterMap, RouterModule } from 'commonlib';
import { TagGrid } from './TagGrid';
import { CommonButton, CommonDivider } from 'componentlib';

@ComponentV2
export struct RoomCard {
  @Param
  room: MappedRoom | undefined = undefined;
  @Param
  hotel: MappedHotel | undefined = undefined;
  @Local
  private _name: string = this.room!.name;
  @Local
  private _basePrice: string | number = this.room!.basePrice;
  @Local
  private _cover: PixelMap | ResourceStr | DrawableDescriptor = this.room!.cover;
  @Local
  private _tags: string[] = this.room!.tags;
  @Local
  private _showRoomRateList: boolean = false;
  private readonly _ID: string = util.generateRandomUUID(false);

  build() {
    Column() {
      Row() {
        Image(this._cover)
          .width($r('app.string.width_percent_25'))
          .aspectRatio(4 / 3)
          .objectFit(ImageFit.Fill)
          .draggable(false)
          .borderRadius($r('app.string.border_radius_8'))
          .margin({ right: $r('app.string.margin_s') })
          .alt($r('app.media.ic_no_data'))
          .id(this._ID);
        Column() {
          this.titleBuilder();
          Row() {
            TagGrid({
              fontSize: 10,
              gridMaxLines: 2,
              data: this._tags,
            })
              .margin({ top: $r('app.string.margin_s') })
              .width($r('app.string.width_percent_half'));
            Blank();
            Column() {
              Image($r('app.media.icon_down'))
                .height($r('app.integer.icon_size_20'))
                .fillColor($r('app.color.icon_color_level1'))
                .margin({ right: $r('app.string.margin_s'), bottom: $r('app.string.margin_s') });
              Blank();

              this.basePriceBuilder();
            }
            .justifyContent(FlexAlign.End)
            .alignItems(HorizontalAlign.End);
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
          .justifyContent(FlexAlign.Start);
        }
        .layoutWeight(1)
        .padding({ left: $r('app.string.padding_s') })
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start);
      }
      .width($r('app.string.width_percent_full'))
      .alignItems(VerticalAlign.Top)
      .height('auto')
      .onClick(() => this._showRoomRateList = !this._showRoomRateList);

      if (this._showRoomRateList) {
        ForEach(this.room!.mappedRoomRateList, (item: MappedRoomRate, index: number) => {
          if (index > 0) {
            CommonDivider();
          } else {
            Blank()
              .margin({ top: $r('app.string.margin_s') });
          }
          Row() {
            Text(item.name)
              .fontSize($r('app.string.font_size_28'))
              .fontColor($r('app.string.font_size_28'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1);
            Row() {
              Text() {
                Span('¥');
                Span(item.rate.toString())
                  .fontSize($r('app.string.font_size_28'));
              }
              .fontSize($r('app.string.font_size_20'))
              .fontColor($r('app.color.system_color_highlight'));
            }
            .alignItems(VerticalAlign.Bottom)
            .margin({right:$r('app.string.margin_s')})

            Row() {
              Text('预订')
                .fontSize($r('app.string.font_size_28'))
                .fontColor($r('app.color.font_color_level1_invert'))
                .fontWeight(FontWeight.Medium);
            }
            .backgroundColor($r('app.color.font_color_link'))
            .borderRadius($r('app.string.border_radius_capsule'))
            .padding({
              left: $r('app.string.padding_s'),
              right: $r('app.string.padding_s'),
              top: $r('app.string.padding_xs'),
              bottom: $r('app.string.padding_xs'),
            });
          }
          .width($r('app.string.width_percent_full'))
          .padding($r('app.string.padding_s'))
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            HotelBookingVM.instance.setRoomInfo(this.room, item);
            this.onPageStackPush();
            RouterModule.push({ url: RouterMap.HOTEL_ROOM_DETAIL, param: [this.hotel, this.room, item] });
          });
        }, (item: MappedRoomRate) => JSON.stringify(item));
      }

      CommonDivider();
    }
    .width($r('app.string.width_percent_full'))
    .padding({
      left: $r('app.string.padding_s'),
      right: $r('app.string.padding_s'),
    })
    .margin({ top: $r('app.string.margin_s'), bottom: $r('app.string.margin_s') });
  }

  @Builder
  basePriceBuilder() {
    Row() {
      Text() {
        Span('¥');
        Span(this._basePrice.toString())
          .fontSize($r('app.string.font_size_28'));
        Span('起');
      }
      .fontColor($r('app.color.system_color_highlight'))
      .fontSize($r('app.string.font_size_20'));
    }
    .alignItems(VerticalAlign.Bottom);
  }

  @Builder
  titleBuilder() {
    Text(this._name)
      .fontSize($r('app.string.font_size_28'))
      .fontColor($r('app.color.font_color_level1'))
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .width($r('app.string.width_percent_full'));
  }

  @Event
  private onPageStackPush: () => void = () => {
  };
}