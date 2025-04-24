@ComponentV2
export struct CheckInTimeDetailItem {
  @Param time: string = '--:--:--';
  @Param location: string = '--------'
  @Param isFirst: boolean = false;
  @Param isLast: boolean = false;
  @Consumer('isHistoryChecked') isChecked: boolean = false;

  buildTextPrefix(): string | Resource {
    if (this.isFirst) {
      return $r('app.string.first_checkin_prefix');
    }

    if (this.isLast) {
      return $r('app.string.last_checkin_prefix')
    }
    return '';
  }

  showTimeDetail(): boolean {
    if (this.isFirst || this.isLast) {
      return true;
    }

    return this.isChecked;
  }

  build() {
    if (this.showTimeDetail()) {
      Flex() {
        Text(this.buildTextPrefix())
          .width(42)
          .height(20)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .fontColor($r('app.string.black_90'))
          .flexShrink(0)
        Text(this.time)
          .width(56)
          .height(20)
          .fontSize(14)
          .fontColor($r('app.color.light_gray'))
          .maxLines(1)
          .margin({ left: 8 })
          .flexShrink(0)
        Text(this.location)
          .fontSize(14)
          .height(20)
          .fontColor($r('app.color.light_gray'))
          .margin({ left: 8 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .flexGrow(1)
          .flexShrink(1)
      }.margin({ top: 8 }).height(20)
    }
  }
}