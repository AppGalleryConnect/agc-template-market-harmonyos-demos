import { CommonDivider, CommonBanner, CommonScroll } from 'componentlib';
import { TelUtil } from 'commonlib';

import { RoomCard } from '../components/RoomCard';

import { MappedRoom } from '../models/MappedRoom';
import { DatePickerPanel } from '../components/DatePickerPanel';
import { RoomListPageVM } from '../viewmodels/RoomListPageVM';

@ComponentV2
struct RoomListPage {
  vm: RoomListPageVM = RoomListPageVM.instance;

  build() {
    NavDestination() {
      CommonScroll({ title: '酒店详情' }) {
        Column() {
          CommonBanner({
            x: 4,
            y: 3,
            covers: this.vm.topBannerList,
          });
          Column() {
            this.hotelInfoBuilder();

            CommonDivider({ strokeWidth: 6 });

            DatePickerPanel({
              showTopLabel: false,
              paramChangeCallback: () => {
                this.vm.getRoomList();
              },
            }).margin({ left: $r('app.string.margin_s'), right: $r('app.string.margin_s') });

            CommonDivider({ strokeWidth: 6 });

            ForEach(this.vm.roomList, (room: MappedRoom) => {
              RoomCard({ room: room, hotel: this.vm.hotel });
            }, (item: MappedRoom) => JSON.stringify(item));
          };
        }
        .width($r('app.string.width_percent_full'));
      };
    }
    .hideTitleBar(true)
    .onShown(() => {
      this.vm.initData();
    });
  }

  @Builder
  hotelInfoBuilder() {
    Column() {
      Row() {
        Text(this.vm.hotel?.name ?? '')
          .fontSize($r('app.string.font_size_36'))
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(500)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
        Row() {
          Image($r('app.media.icon_phone'))
            .height($r('app.integer.icon_size_12'))
            .fillColor($r('app.color.system_color_focus'))
            .margin({ right: $r('app.string.margin_xs') });
          Text('联系商家')
            .fontSize($r('app.string.font_size_24'))
            .fontColor($r('app.color.system_color_focus'));
        }
        .alignItems(VerticalAlign.Bottom)
        .onClick(() => {
          TelUtil.makeCall(this.vm.hotel?.phoneNumber);
        });
      }
      .width($r('app.string.width_percent_full'))
      .justifyContent(FlexAlign.SpaceBetween);

      Row() {
        Image($r('app.media.icon_local'))
          .height(12)
          .fillColor($r('app.color.icon_color_level2'))
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .margin({ right: $r('app.string.margin_xs') });
        Text(this.vm.hotel?.address ?? '--')
          .fontSize($r('app.string.font_size_24'))
          .fontColor($r('app.color.font_color_level2'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .width($r('app.string.width_percent_full'))
      .margin({ top: $r('app.string.margin_s') })
      .justifyContent(FlexAlign.Start);
    }
    .width($r('app.string.width_percent_full'))
    .padding($r('app.string.padding_s'))
    .margin({ top: $r('app.string.margin_s') });
  }
}

@Builder
export function roomListPageBuilder() {
  RoomListPage();
}