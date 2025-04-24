import {
  AvoidArea,
  CommonConstants,
  FavoriteDatabase,
  LeftReturnComponent,
  promptFun,
  TitleBar
} from '@ohos_agcit/common_component';
import { AppStorageV2, PersistenceV2, router } from '@kit.ArkUI';

@Entry
@ComponentV2
export struct MyFavorite {
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local favoriteDatabase: FavoriteDatabase =
    PersistenceV2.connect(FavoriteDatabase, () => new FavoriteDatabase())!;
  favoriteListMirror: Array<string> = this.favoriteDatabase.favoriteList.slice()

  build() {
    Column() {
      Row() {
        LeftReturnComponent()
          .onClick(() => {
            router.back();
          })
        TitleBar({ text: '我的收藏' })
      }
      .height('5%')
      .width(CommonConstants.FULL_WIDTH)
      .alignItems(VerticalAlign.Center)

      List({ space: '2%' }) {
        ForEach(this.favoriteListMirror, (jobId: string) => {
          ListItem() {
            Row() {
              Column() {
                Text(CommonConstants.JOB_LIST_MAP.get(jobId)?.jobName)
                  .fontWeight(CommonConstants.FONT_WEIGHT_600)
                  .fontSize($r('app.float.font_size_18'))
                Text(CommonConstants.ADDRESS_MAP.get(CommonConstants.JOB_LIST_MAP.get(jobId)?.address) + ' · ' +
                  CommonConstants.JOB_LIST_MAP.get(jobId)?.jobType)
                  .fontSize($r('app.float.font_size_14'))
                  .fontColor($r('app.color.common_gray'))
                  .margin({ top: '3%' })
              }
              .width('70%')
              .alignItems(HorizontalAlign.Start)
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/jobRoute/JobDetail',
                  params: CommonConstants.JOB_LIST_MAP.get(jobId)
                }, router.RouterMode.Standard)
              })

              Blank()

              Image(this.favoriteDatabase.favoriteList.includes(jobId) ?
              $r('app.media.active_collection_star') :
              $r('app.media.star'))
                .objectFit(ImageFit.Contain)
                .width('10%')
                .height('30%')
                .onClick(() => {
                  if (this.favoriteDatabase.favoriteList.includes(jobId)) {
                    this.favoriteDatabase.favoriteList.splice(this.favoriteDatabase.favoriteList.indexOf(jobId), 1)
                    promptFun('取消收藏', 1500)
                    return;
                  }
                  this.favoriteDatabase.favoriteList.push(jobId)
                  promptFun('收藏成功', 1500)
                })

            }
            .borderRadius(20)
            .backgroundColor(Color.White)
            .padding({
              left: 15,
              right: 10,
              top: 5,
              bottom: 5
            })
            .width('100%')
            .height('10%')
          }
        })
      }
      .padding({ top: '8%', left: '2%', right: '2%' })
      .height('95%')
      .width('100%')

    }
    .backgroundColor($r('app.color.common_background'))
    .padding({
      top: px2vp(this.avoidArea.topRectHeight) + 10,
      left: '6%',
      right: '6%'
    })

  }
}