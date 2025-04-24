import {
  AvoidArea,
  CommonConstants,
  FavoriteDatabase,
  LeftReturnComponent,
  promptFun,
  SearchType,
} from '@ohos_agcit/common_component';
import { JobListItem } from '@ohos_agcit/common_component';
import { AppStorageV2, PersistenceV2, router } from '@kit.ArkUI';

@Entry
@ComponentV2
export struct JobDetail {
  @Local jobInfo: JobListItem = router.getParams() as JobListItem;
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local favoriteDatabase: FavoriteDatabase =
    PersistenceV2.connect(FavoriteDatabase, () => new FavoriteDatabase())!;
  addressList: SearchType[] = CommonConstants.ADDRESS_COLLECTION;
  addressMap: Map<number, SearchType> = new Map<number, SearchType>(
    this.addressList.map(item => [item.index, item])
  );

  build() {
    Column() {
      Column() {
        Row() {
          LeftReturnComponent()
            .onClick(() => {
              router.back();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
      }
      .height('8%')
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Column() {
        Text(this.jobInfo.jobName)
          .fontSize($r('app.float.font_size_20'))
          .fontWeight(CommonConstants.FONT_WEIGHT_600)
        Text(this.addressMap.get(this.jobInfo.address)?.title + ' · ' + this.jobInfo.jobType)
          .fontSize($r('app.float.font_size_16'))
          .fontColor($r('app.color.common_gray'))
          .margin({ top: '3%' })
        Row()
          .height(0.8)
          .backgroundColor($r('app.color.button_gray'))
          .width('93%')
          .margin({ top: 10 })
      }
      .height('12%')
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text('工作职责')
          .fontSize($r('app.float.font_size_20'))
          .fontWeight(CommonConstants.FONT_WEIGHT_700)
          .margin({ bottom: '2.5%' })
        Scroll() {
          Text(this.jobInfo.responsibility)
            .fontSize($r('app.float.font_size_15'))
        }
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)


      Column() {
        Text('职位要求')
          .fontSize($r('app.float.font_size_20'))
          .fontWeight(CommonConstants.FONT_WEIGHT_700)
          .margin({ bottom: '2.5%' })
        Scroll() {
          Text(this.jobInfo.requirements)
            .fontSize($r('app.float.font_size_15'))
        }
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({top: '10%'})

      Text('发布于' + this.jobInfo.publishTime)
        .width('100%')
        .fontSize($r('app.float.font_size_15'))
        .fontColor($r('app.color.common_gray'))
        .margin({top: '10%'})

      Blank()

      Row() {
        Image(this.favoriteDatabase.favoriteList.includes(this.jobInfo.jobId) ?
        $r('app.media.active_collection_star') :
        $r('app.media.star'))
          .height('80%')
          .onClick(() => {
            let jobId: string = this.jobInfo.jobId;
            if (this.favoriteDatabase.favoriteList.includes(jobId)) {
              this.favoriteDatabase.favoriteList.splice(this.favoriteDatabase.favoriteList.indexOf(jobId), 1)
              promptFun('取消收藏', 1500)
              return;
            }
            this.favoriteDatabase.favoriteList.push(jobId)
            promptFun('收藏成功', 1500)
          })
        Blank()

        Button('简历投递')
          .fontSize($r('app.float.font_size_17'))
          .backgroundColor($r('app.color.common_blue'))
          .height('100%')
          .width('75%')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/jobRoute/JobDelivery',
              params: this.jobInfo
            }, router.RouterMode.Standard)
          })
      }
      .height('6%')
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.common_background'))
    .padding({
      top: px2vp(this.avoidArea.topRectHeight) + 10,
      bottom: px2vp(this.avoidArea.bottomRectHeight),
      left: '6%',
      right: '6%'
    })
  }
}
