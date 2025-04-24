import {
  AvoidArea,
  CommonConstants,
  DeliveryDatabase,
  DeliveryRecord,
  JobListItem,
  LeftReturnComponent,
  TitleBar
} from '@ohos_agcit/common_component';
import { AppStorageV2, PersistenceV2, router } from '@kit.ArkUI';


@Entry
@ComponentV2
export struct MyDelivery {
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local deliveryDatabase: DeliveryDatabase =
    PersistenceV2.connect(DeliveryDatabase, () => new DeliveryDatabase())!;
  @Local isSubscribe: boolean = this.deliveryDatabase.isSubscribe

  aboutToAppear(): void {
    if (this.deliveryDatabase.deliveryList.filter(item => item.status === 2).length === 0) {
      let record = new DeliveryRecord();
      record.jobId = '10'
      record.submitTime = '2025.03.21'
      record.status = 2
      this.deliveryDatabase.deliveryList.push(record)
    }
  }

  build() {
    Column() {
      Row() {
        LeftReturnComponent()
          .onClick(() => {
            router.back();
          })
        TitleBar({ text: '投递记录' })
      }
      .height('5%')
      .width(CommonConstants.FULL_WIDTH)
      .alignItems(VerticalAlign.Center)

      List({ space: '3%' }) {
        ForEach(this.deliveryDatabase.deliveryList, (item: DeliveryRecord) => {
          JobDeliveryCard({ deliveryInfo: item })
        })
      }
      .scrollBar(BarState.Off)
      .padding({ top: '8%', bottom: '5%' })
      .height('88%')
      .width('100%')

      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceEvenly, alignItems: ItemAlign.Center }) {
        if (!this.isSubscribe) {
          Text('订阅流程状态')
            .fontColor(Color.White)
            .fontSize($r('app.float.font_size_16'))
            .fontWeight(CommonConstants.FONT_WEIGHT_600)

          Text('授权后可收到面试邀约')
            .fontColor(Color.White)
            .fontSize($r('app.float.font_size_14'))
            .fontWeight(CommonConstants.FONT_WEIGHT_500)
        } else {
          Text('已订阅')
            .fontColor(Color.White)
            .fontSize($r('app.float.font_size_16'))
            .fontWeight(CommonConstants.FONT_WEIGHT_600)
        }
      }
      .backgroundColor($r('app.color.common_blue'))
      .borderRadius(24)
      .height('7%')
      .width('100%')
      .onClick(() => {
        this.isSubscribe = true
        this.deliveryDatabase.isSubscribe = true
      })

    }
    .backgroundColor($r('app.color.common_background'))

    .padding({
      top: px2vp(this.avoidArea.topRectHeight) + 10,
      bottom: px2vp(this.avoidArea.bottomRectHeight),
      left: '8%',
      right: '6%'
    })
  }
}

@ComponentV2
struct JobDeliveryCard {
  @Param @Require deliveryInfo: DeliveryRecord
  jobInfo: JobListItem | undefined = undefined

  aboutToAppear(): void {
    this.jobInfo = CommonConstants.JOB_LIST_MAP.get(this.deliveryInfo.jobId)
  }

  build() {
    if (this.jobInfo !== undefined) {
      Column() {
        // title
        Row() {
          Text(this.jobInfo?.jobName)
            .fontSize($r('app.float.font_size_18'))
            .fontWeight(CommonConstants.FONT_WEIGHT_600)
            .width('75%')
            .opacity(this.deliveryInfo.status === 2 ? CommonConstants.TRANSPARENCY_HALF :
            CommonConstants.TRANSPARENCY_FULL)
          Blank()
          Text(CommonConstants.DELIVERY_STATUS_MAP.get(this.deliveryInfo.status))
            .fontSize($r('app.float.font_size_12'))
            .width('15%')
            .opacity(this.deliveryInfo.status === 2 ? CommonConstants.TRANSPARENCY_HALF :
            CommonConstants.TRANSPARENCY_FULL)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)

        // desc
        Column() {
          this.SimpleText('职位类型：' + this.jobInfo.jobType)
          this.SimpleText('工作地点：' + CommonConstants.ADDRESS_MAP.get(this.jobInfo.address))
          this.SimpleText('投递时间：' + this.deliveryInfo.submitTime)
        }
        .margin({ top: '3.5%' })
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .borderRadius(20)
      .backgroundColor(Color.White)
      .padding({
        left: 20,
        right: 5,
        top: 15,
        bottom: 10
      })
      .height('20%')
      .width('100%')
    }
  }

  @Builder
  SimpleText(text: string | undefined) {
    Text(text)
      .fontSize($r('app.float.font_size_14'))
      .margin({ bottom: '2.5%' })
      .opacity(this.deliveryInfo.status === 2 ? CommonConstants.TRANSPARENCY_HALF : CommonConstants.TRANSPARENCY_FULL)
  }
}

