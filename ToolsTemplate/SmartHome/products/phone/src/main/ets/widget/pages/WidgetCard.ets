
const local = new LocalStorage();

@Entry(local)
@Component
struct WidgetCard {
  @LocalStorageProp('deviceId') deviceId: string = '';
  @LocalStorageProp('deviceImage') deviceImage: string = '';
  @LocalStorageProp('deviceName') deviceName: string = '';
  @LocalStorageProp('isDeleted') isDeleted: boolean = false;

  build() {
    Row() {
      Column() {
        Image(this.deviceImage).size({ width: 80 });
        if (this.isDeleted) {
          Text(this.deviceName + '(已删除)');
        } else {
          Text(this.deviceName);
        }
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%');

    }
    .height('100%')
    .onClick(() => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'PhoneAbility',
        params: {
          deviceId: this.isDeleted ? '' : this.deviceId,
        },
      });
    });
  }
}