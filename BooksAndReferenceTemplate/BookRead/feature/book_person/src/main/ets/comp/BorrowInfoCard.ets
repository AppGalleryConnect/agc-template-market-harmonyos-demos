import { BorrowInfo, BorrowStatus, Constants, StatusInfo, TCRouter, TimeUtils } from 'common';


@ComponentV2
export struct BorrowInfoCard {
  @Param @Require info: BorrowInfo;
  private context: Context = this.getUIContext().getHostContext() as Context;
  private resourceManager = this.context.resourceManager;
  aboutToAppear(): void {
    this.info.statusInfo = new StatusInfo(this.info.status);
  }
  private getString(name: string) {
    try {
      return this.resourceManager.getStringByNameSync(name);
    } catch (error) {
      console.error('BorrowInfoCard', ` getString error = ${JSON.stringify(error)}`)
      return name;
    }
  }
  build() {
    Column() {
      Column() {
        Row() {
          Text(TimeUtils.timestamp2YMD(this.info.borrowBegin))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text(this.info.statusInfo.statusText)
            .fontSize($r('sys.float.Body_L'))
            .fontColor(this.info.statusInfo.statusColor)
            .width(72)
            .height(28)
            .borderRadius(8)
        }.width(Constants.FULL_SIZE)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: 8, bottom: 8 })
      }

      Row() {
        Text(`${this.getString('borrow_time')}: ${TimeUtils.timestamp2YMD(this.info.borrowBegin)}`)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
      }
      .justifyContent(FlexAlign.Start)
      .width(Constants.FULL_SIZE)
      .padding({ top: 8, bottom: 8 })

      Row() {
        Text(`${this.getString('borrow_deadline')}: ${TimeUtils.timestamp2YMD(this.info.borrowBegin)}-${TimeUtils.timestamp2YMD(this.info.borrowDeadline)}`)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
      }
      .width(Constants.FULL_SIZE)
      .padding({ top: 8, bottom: 8 })

      if (this.info.status === BorrowStatus.RETURNED) {
        Row() {
          Text(`${this.getString('borrow_return_time')}: ${TimeUtils.timestamp2YMD(this.info.borrowEnd)}`)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
        }
        .width(Constants.FULL_SIZE)
        .padding({ top: 8, bottom: 8 })
      }

      Row() {
        Text(`${this.getString('borrow_count')}: ${this.info.borrowNum}`)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
      }
      .width(Constants.FULL_SIZE)
      .padding({ top: 8, bottom: 8 })
    }
    .width(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .height(this.info.status === BorrowStatus.RETURNED ? 200 : 167)
    .alignSelf(ItemAlign.Center)
    .borderRadius(16)
    .padding({
      left: 18,
      right: 18,
    })
    .margin({ bottom: 15 })
    .onClick(() => {
      TCRouter.push(Constants.BORROW_DETAIL_ROUTE, this.info);
    })
  }
}

export { BorrowInfo };
