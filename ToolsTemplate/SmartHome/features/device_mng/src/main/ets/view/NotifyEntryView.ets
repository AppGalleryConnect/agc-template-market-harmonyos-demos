import { NotifyEntryViewModel } from '../viewmodel/NotifyEntryViewModel';

@ComponentV2
export struct NotifyEntryView {
  @Require @Param pathStack: NavPathStack;
  notifyEntryViewModel: NotifyEntryViewModel = new NotifyEntryViewModel();
  @Param px: number = 24;

  @Computed
  get getBadgeSize() {
    if (!this.notifyEntryViewModel.isDevicesNotifyRecordsRead) {
      return 6;
    } else {
      return 0;
    }
  }

  build() {
    Column() {
      Badge({
        value: '',
        style: { badgeSize: this.getBadgeSize, badgeColor: Color.Red },
      }) {
        Image($r('app.media.notify_icon'))
          .width(this.px)
          .height(this.px);
      }
      .width(this.px)
      .height(this.px);
    }
    .onClick(() => {
      this.pathStack.pushPathByName('NotifyPage', null);
    });
  }
}
