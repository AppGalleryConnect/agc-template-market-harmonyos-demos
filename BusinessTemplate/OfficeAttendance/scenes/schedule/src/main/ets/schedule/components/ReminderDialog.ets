
@CustomDialog
export struct ReminderDialog {
  private controller: CustomDialogController;
  scroller: Scroller = new Scroller();
  protected reminderTypes: Map<number, Resource> = new Map();
  private items: Array<number> = [];
  protected selectedItems: Set<number> = new Set();
  protected callback: (value: Set<number>) => void = () => {
  };

  aboutToAppear(): void {
    this.items = Array.from(this.reminderTypes.keys());
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.reminder_title')).fontSize(24).fontWeight(10)
      }.width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .height(60)

      Scroll(this.scroller) {
        Column({ space: 8 }) {
          ForEach(this.items, (item: number) => {
            Row() {
              Row() {
                Text(this.reminderTypes.get(item))
              }.alignItems(VerticalAlign.Center)
              .alignItems(VerticalAlign.Center)

              Row() {
                Checkbox().select(this.selectedItems.has(item)).onChange((value: boolean) => {
                  if (value) {
                    this.selectedItems.add(item);
                  } else {
                    this.selectedItems.delete(item);
                  }
                })
              }.layoutWeight(1)
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.End)
            }

            Divider();
          })
        }
      }.layoutWeight(1)
      .scrollBar(BarState.Off)

      Row() {
        Row() {
          Text('取消').onClick(() => {
            this.controller.close();
          })
        }.width('50%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)

        Line()
          .width(1)
          .height('40%')
          .backgroundColor(Color.Grey)

        Row() {
          Text('确定').onClick(() => {
            this.callback(this.selectedItems);
            this.controller.close();
          })
        }.width('50%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }.height(60)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .height('50%')
    .width('100%')
    .padding({ left: 12, right: 12 })
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}