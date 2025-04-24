import { CommonBanner, CommonScroll } from 'componentlib';
import { DatePickerPanel } from '../components/DatePickerPanel';
import { MappedHotel } from '../models/MappedHotel';
import { HotelListPageVM } from '../viewmodels/HotelListPageVM';
import { TagGrid } from '../components/TagGrid';
import { RelativeAnchorMap } from '../constants/Constants';

@ComponentV2
struct HotelListPage {
  vm: HotelListPageVM = HotelListPageVM.instance;

  aboutToAppear(): void {
    this.vm.resetRoomCount()
  }

  build() {
    NavDestination() {
      CommonScroll({ title: '会员订房' }) {
        Column() {
          this.topBannerBuilder();
          ForEach(this.vm.hotelList, (item: MappedHotel, index: number) => {
            this.hotelCardBuilder(item, index);
          }, (item: MappedHotel) => JSON.stringify(item));
        }
        .height('100%')
        .backgroundColor($r('app.color.system_color_background_auxiliary'));
      };
    }
    .hideTitleBar(true)
    .onShown(() => {
      this.vm.initData();
    });

  }

  @Builder
  topBannerBuilder() {
    RelativeContainer() {
      CommonBanner({
        x: 4,
        y: 3,
        covers: [this.vm.topBanner],
        color: $r('app.color.system_color_background_auxiliary'),
      })
        .id(RelativeAnchorMap.HOTEL_LIST_BANNER_CONTAINER);
      DatePickerPanel({
        paramChangeCallback: () => {
          this.vm.getHotelList();
        },
      })
        .height(125)
        .margin({
          left: $r('app.string.margin_m'),
          right: $r('app.string.margin_m'),
        })
        .padding({
          top: $r('app.string.padding_s'),
          bottom: $r('app.string.padding_s'),
        })
        .shadow({ radius: $r('app.string.border_radius_8'), color: $r('app.color.system_color_grey_level1') })
        .alignRules({
          'center': { 'anchor': RelativeAnchorMap.HOTEL_LIST_BANNER_CONTAINER, 'align': VerticalAlign.Bottom },
          'left': { 'anchor': RelativeAnchorMap.HOTEL_LIST_BANNER_CONTAINER, 'align': HorizontalAlign.Start },
        });
    }
    .width($r('app.string.width_percent_full'))
    .height('auto');
  }

  @Builder
  dividerBuilder() {
    Divider()
      .vertical(false)
      .color($r('app.color.system_color_grey_level1'))
      .strokeWidth(1)
      .margin({ bottom: $r('app.string.margin_s') });
  }

  @Builder
  hotelCardBuilder(hotel: MappedHotel, index: number) {
    Column() {
      if (index > 0) {
        this.dividerBuilder();
      }
      RelativeContainer() {
        Image(hotel.cover)
          .height(80)
          .aspectRatio(4 / 3)
          .borderRadius($r('app.string.border_radius_8'))
          .objectFit(ImageFit.Cover)
          .padding({ right: $r('app.string.padding_s') })
          .alignRules({
            left: { anchor: RelativeAnchorMap.HOTEL_CARD_CONTAINER, align: HorizontalAlign.Start },
            top: { anchor: RelativeAnchorMap.HOTEL_CARD_CONTAINER, align: VerticalAlign.Top },
          })
          .id(RelativeAnchorMap.HOTEL_ITEM_COVER);


        Text(hotel.name)
          .fontSize($r('app.string.font_size_28'))
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(500)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
          .layoutWeight(1)
          .alignRules({
            left: { anchor: RelativeAnchorMap.HOTEL_ITEM_COVER, align: HorizontalAlign.End },
            top: { anchor: RelativeAnchorMap.HOTEL_CARD_CONTAINER, align: VerticalAlign.Top },
          })
          .id(RelativeAnchorMap.HOTEL_ITEM_TITLE);

        Text(hotel.distanceInMeters)
          .fontSize($r('app.string.font_size_20'))
          .fontColor($r('app.color.font_color_level2'))
          .alignRules({
            right: { anchor: RelativeAnchorMap.HOTEL_CARD_CONTAINER, align: HorizontalAlign.End },
            top: { anchor: RelativeAnchorMap.HOTEL_CARD_CONTAINER, align: VerticalAlign.Top },
          })
          .id(RelativeAnchorMap.HOTEL_ITEM_DISTANCE);

        Text(hotel.address)
          .fontSize($r('app.string.font_size_20'))
          .fontColor($r('app.color.font_color_level2'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .margin({ top: $r('app.string.margin_s') })
          .alignRules({
            left: { anchor: RelativeAnchorMap.HOTEL_ITEM_COVER, align: HorizontalAlign.End },
            top: { anchor: RelativeAnchorMap.HOTEL_ITEM_TITLE, align: VerticalAlign.Bottom },
          })
          .id(RelativeAnchorMap.HOTEL_ITEM_ADDRESS);

        TagGrid({ gridMaxLines: 2, data: hotel.tags })
          .margin({ top: $r('app.string.margin_s') })
          .width('60%')
          .alignRules({
            left: { anchor: RelativeAnchorMap.HOTEL_ITEM_COVER, align: HorizontalAlign.End },
            top: { anchor: RelativeAnchorMap.HOTEL_ITEM_ADDRESS, align: VerticalAlign.Bottom },
          })
          .id(RelativeAnchorMap.HOTEL_ITEM_TAG);

        Text() {
          Span(hotel.basePrice === '--' ? '' : '¥');
          Span(hotel.basePrice.toString())
            .fontSize($r('app.string.font_size_32'));
          Span(hotel.basePrice === '--' ? '' : '起');
        }
        .fontSize($r('app.string.font_size_20'))
        .fontColor($r('app.color.system_color_highlight'))
        .alignRules({
          right: { anchor: RelativeAnchorMap.HOTEL_CARD_CONTAINER, align: HorizontalAlign.End },
          bottom: { anchor: RelativeAnchorMap.HOTEL_ITEM_COVER, align: VerticalAlign.Bottom },
        })
        .id(RelativeAnchorMap.HOTEL_ITEM_PRICE);
      }
      .id(RelativeAnchorMap.HOTEL_CARD_CONTAINER)
      .height(100)
      .width($r('app.string.width_percent_full'))
      .padding($r('app.string.padding_s'));
    }
    .margin($r('app.string.margin_s'))
    .onClick(() => {
      this.vm.jumpToRoomList(hotel);
    });
  }
}

@Builder
export function hotelListPageBuilder() {
  HotelListPage();
}