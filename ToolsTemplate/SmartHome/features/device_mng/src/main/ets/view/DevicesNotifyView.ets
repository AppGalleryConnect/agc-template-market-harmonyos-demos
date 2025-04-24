import { Constants } from 'utils';
import { DeviceNotifyViewModel, DevicesNotifyViewModel } from '../viewmodel/DevicesNotifyViewModel';

export enum ShowType {
  ALL,
  READ,
  UNREAD,
}

@ComponentV2
export struct DevicesNotifyView {
  @Require @Param showType: ShowType = ShowType.ALL;
  @Require @Param pathStack: NavPathStack = new NavPathStack();
  devicesNotifyViewModel: DevicesNotifyViewModel = new DevicesNotifyViewModel();
  private listScroller: Scroller = new Scroller();

  @Computed
  get getCount() {
    let count = 0;
    this.devicesNotifyViewModel.addedDevices.forEach((item) => {
      if (this.isMatch(item)) {
        count++;
      }
    });
    return count;
  }

  isMatch(item: DeviceNotifyViewModel): boolean {
    if (item.deviceLatestNotifyRecord === undefined) {
      return false;
    }
    if (this.showType === ShowType.ALL) {
      return true;
    }
    if (this.showType === ShowType.READ && item.isDeviceNotifyRecordsRead) {
      return true;
    }
    if (this.showType === ShowType.UNREAD && !item.isDeviceNotifyRecordsRead) {
      return true;
    }
    return false;
  }

  @Builder
  BuildNotifyCardsList() {
    List({ space: 15, scroller: this.listScroller }) {
      ForEach(this.devicesNotifyViewModel.addedDevices, (item: DeviceNotifyViewModel, index: number) => {
        if (this.isMatch(item)) {
          DeviceNotifyCardView({ addedDevice: item, pathStack: this.pathStack })
            .width('100%');
        }
      }, (item: DeviceNotifyViewModel, index: number) => item.deviceId);
    }
    .alignListItem(ListItemAlign.Center);
  }

  @Builder
  BuildEmptyNotify() {
    Column() {
      Image($r('app.media.empty_notify'))
        .size({ width: 120, height: 120 });
    }
    .height('100%')
    .justifyContent(FlexAlign.Center);
  }

  build() {
    Column() {
      if (this.getCount === 0) {
        this.BuildEmptyNotify();
      } else {
        this.BuildNotifyCardsList();
      }
    }
    .height('100%');
  }
}

@ComponentV2
struct DeviceNotifyCardView {
  @Require @Param pathStack: NavPathStack;
  @Require @Param addedDevice: DeviceNotifyViewModel;

  @Computed
  get getBadgeSize() {
    if (!this.addedDevice.isDeviceNotifyRecordsRead) {
      return 6;
    } else {
      return 0;
    }
  }

  @Builder
  BuildDeviceTextLine1() {
    Row() {
      Text(this.addedDevice.deviceName)
        .textOverflow({ overflow: TextOverflow.MARQUEE })
        .maxLines(1)
        .fontSize(14);
      Blank();
      Text(this.addedDevice.deviceLatestNotifyRecord!.time)
        .fontSize(14)
        .margin({ right: 0 })
        .fontColor('#333333');
    }
    .width('100%');
  }

  @Builder
  BuildDeviceTextLine2() {
    Row() {
      Text(this.addedDevice.deviceLatestNotifyRecord!.message)
        .textOverflow({ overflow: TextOverflow.MARQUEE })
        .maxLines(1)
        .fontColor(16);
    }
    .width('100%');
  }

  @Builder
  BuildDeviceText() {
    Column({ space: 15 }) {
      this.BuildDeviceTextLine1();
      this.BuildDeviceTextLine2();
    }
    .alignItems(HorizontalAlign.Start)
    .width('72%')
    .margin({ left: 15 });
  }

  @Builder
  BuildDeviceImage() {
    Badge({
      value: '',
      position: BadgePosition.Left,
      style: { badgeSize: this.getBadgeSize, badgeColor: Color.Red },
    }) {
      Column() {
        Image(this.addedDevice.deviceImage)
          .objectFit(ImageFit.Contain);
      }
      .borderRadius(4)
      .width(60)
      .height(60)
      .justifyContent(FlexAlign.Center)
      .margin({ left: 10 })
      .backgroundColor('#F1F3F5');
    }
    .width(70)
    .height(60);
  }

  build() {
    Row() {
      Row() {
        this.BuildDeviceImage();
        this.BuildDeviceText();
      }
      .width('95%');
    }
    .onClick(() => {
      this.addedDevice.isDeviceNotifyRecordsRead = true;
      this.pathStack.pushPathByName('MessageListPage', this.addedDevice.deviceId);
    })
    .justifyContent(FlexAlign.Center)
    .height(95)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16);
  }
}