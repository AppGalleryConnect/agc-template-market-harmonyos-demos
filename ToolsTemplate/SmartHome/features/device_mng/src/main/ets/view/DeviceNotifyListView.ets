import { DeviceMessageListRecordViewModel, DeviceNotifyListViewModel } from '../viewmodel/DeviceNotifyListViewModel';

@ComponentV2
export struct DeviceNotifyListView {
  @Require @Param messageListViewModel: DeviceNotifyListViewModel;
  private listScroller: Scroller = new Scroller();

  @Builder
  BuildMessageList() {
    List({ space: 20, scroller: this.listScroller }) {
      ForEach(this.messageListViewModel.deviceMessageRecords,
        (item: DeviceMessageListRecordViewModel, index: number) => {
          ListItem() {
            DeviceNotifyListItemView({ item: item });
          };
        }, (item: Object, index: number) => index + '__' + JSON.stringify(item));
    }
    .scrollBar(BarState.Off);
  }

  build() {
    Column() {
      Row() {
        Column() {
          this.BuildMessageList();
        }
        .width('90%')
        .margin({ top: 20, bottom: 20 });
      }
      .justifyContent(FlexAlign.Center)
      .width('90%')
      .backgroundColor('#FFFFFF')
      .borderRadius(16);
    }
    .height('80%');
  }
}

@ComponentV2
export struct DeviceNotifyListItemView {
  @Require @Param item: DeviceMessageListRecordViewModel;
  diameter = 10;
  radius = this.diameter / 2;
  @Local textHeight: number = 0

  @Builder
  BuildTime() {
    Row() {
      Circle()
        .width(this.diameter)
        .height(this.diameter)
        .fill('#999999')
        .opacity(0.5);
      Text(this.item.day)
        .fontColor('#999999')
        .fontSize(16)
        .margin({ left: 15 });
      Text(this.item.hourMinute)
        .fontColor('#999999')
        .fontSize(16)
        .margin({ left: 10 });
      Blank();
      Text(this.item.week)
        .fontColor('#999999')
        .fontSize(16);
    }
    .width('100%');
  }

  @Builder
  BuildEvent() {
    Row() {
      Divider()
        .vertical(true)
        .height(this.textHeight + 10)
        .strokeWidth(1)
        .margin({ left: this.radius })
        .color('#999999')
        .opacity(0.2);
      Column() {
        Text(this.item.message)
          .fontColor('#333333')
          .fontSize(18)
          .margin({ top: 16, bottom: 16 })
          .onAreaChange((oldValue: Area, newValue: Area) => {
            this.textHeight = Number(newValue.height);
          });
        Divider()
          .width('100%')
          .strokeWidth(1)
          .color('#999999')
          .opacity(0.2)
      }
      .margin({ left: 15 + this.radius })
      .alignItems(HorizontalAlign.Start)
      .width('90%');
    }
    .width('100%');
  }

  build() {
    Column() {
      this.BuildTime();
      this.BuildEvent();
    }
  }
}