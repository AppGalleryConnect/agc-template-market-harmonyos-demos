let storageLocal = new LocalStorage();

@Entry(storageLocal)
@Component
@Preview
struct AppointmentStatusWidgetCard {
  @LocalStorageProp('hasData') hasData: boolean = false
  @LocalStorageProp('departmentName') departmentName: string = '发热门诊'
  @LocalStorageProp('datetime') datetime: string = '2024-12-11 15:22'
  @LocalStorageProp('status') status: string = '已支付'

  build() {
    Column() {
      Text('挂号记录')
        .alignStartText()
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .fontSize(14)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ bottom: 8 })

      Text(!this.hasData ? '暂无挂号记录' : this.departmentName)
        .alignStartText()
        .maxLines(1)
        .fontSize(18)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (!this.hasData) {
        Column() {
          Blank()
            .layoutWeight(1)

          Button('预约挂号')
            .borderRadius(50)
            .fontColor($r('sys.color.ohos_id_color_text_primary_contrary'))
            .backgroundColor($r('sys.color.ohos_id_color_palette4'))
            .width('100%')
            .height(36)
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .layoutWeight(1)
      } else {
        Column({ space: 8 }) {
          Blank()
            .layoutWeight(1)

          Text(this.status)
            .fontSize(14)
            .alignStartText()

          Text(this.datetime)
            .fontSize(12)
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .alignStartText()
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .onClick(() => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
        params: {
          hasData: this.hasData
        }
      });
    })
  }
}

@Extend(Text)
function alignStartText() {
  .width('100%')
  .textAlign(TextAlign.Start)
}
