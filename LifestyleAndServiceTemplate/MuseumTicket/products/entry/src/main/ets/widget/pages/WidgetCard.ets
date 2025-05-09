let storageLocal = new LocalStorage();

@Preview
@Entry(storageLocal)
@Component
struct WidgetCard {
  @LocalStorageProp('hasData') hasData: boolean = false;
  @LocalStorageProp('performanceName') performanceName: string = '下河文明巡回展';
  @LocalStorageProp('visitTime') visitTime: string = '2025-01-01 下午';
  @LocalStorageProp('orderNo') orderNo: string = '1';
  readonly actionType: string = 'router';
  readonly abilityName: string = 'EntryAbility';
  readonly message: string = 'add detail';

  build() {

    Column() {
      if (this.hasData) {
        Text(this.performanceName)
          .fontSize(14)
          .fontColor(Color.Black)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .maxLines(1);
        Text('预约成功').fontSize(12).fontColor(Color.Black).width('100%').margin({ top: 30, bottom: 10 });
        Text(this.visitTime)
          .fontSize(12)
          .fontColor(Color.Black)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .maxLines(1);

      } else {
        Text('暂无预约记录')
          .fontSize(14)
          .fontColor(Color.Black)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .maxLines(1);
        Button('预约')
          .borderRadius(50)
          .fontColor($r('sys.color.ohos_id_color_text_primary_contrary'))
          .backgroundColor($r('sys.color.ohos_id_color_palette4'))
          .width('100%')
          .height(36)
          .margin({ top: 40 });
      }


    }
    .padding(20)
    .backgroundImage($r('app.media.card_bg'))
    .backgroundImageSize(ImageSize.Cover)
    .width('100%')
    .height('100%')
    .onClick(() => {
      postCardAction(this, {
        action: this.actionType,
        abilityName: this.abilityName,
        params: {
          hasData: this.hasData,
          orderNo: this.orderNo,
        },
      });
    });
  }
}