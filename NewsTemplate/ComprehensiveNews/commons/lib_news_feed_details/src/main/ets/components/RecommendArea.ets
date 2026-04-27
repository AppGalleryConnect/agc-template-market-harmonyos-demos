import { CommonBreakpoint, SettingModel } from 'lib_common'
import { NewsFeedInfo } from '../model/Model'
import { FeedBreakPointVM } from '../viewmodel/FeedBreakPointVM'
import NewsFeedVM from '../viewmodel/NewsFeedVM'

@ComponentV2
export struct RecommendArea {
  @Param newsFeedVM: NewsFeedVM = new NewsFeedVM()
  @Require @Param settingInfo: SettingModel
  @Param isFolderStatus: boolean = false
  @Local newsBreakPoint: FeedBreakPointVM = new FeedBreakPointVM()
  @Local lanesCount: CommonBreakpoint<number> = new CommonBreakpoint<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });

  build() {
    Column() {
      Column() {
        Text('相关推荐')
          .fontSize(18 * this.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
      }
      .margin({ top: 16, bottom: 8 })
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      List() {
        ForEach(this.newsFeedVM.articleDetails.recommends, (item: NewsFeedInfo, index: number) => {
          ListItem() {
            Flex({ justifyContent: FlexAlign.SpaceBetween }) {
              Column({ space: 5 }) {
                Text(item.title)
                  .maxLines(2)
                  .fontColor($r('sys.color.font_primary'))
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .fontWeight(FontWeight.Medium)
                  .fontSize(16 * this.settingInfo.fontSizeRatio)
                Row() {
                  Text(item?.author?.authorNickName)
                    .fontSize(12 * this.settingInfo.fontSizeRatio).fontColor($r('sys.color.font_tertiary'))
                  Text(item?.publishTime)
                    .fontSize(12 * this.settingInfo.fontSizeRatio)
                    .fontColor($r('sys.color.font_tertiary'))
                    .margin({ left: 8 })
                }
              }
              .width('65%')
              .alignItems(HorizontalAlign.Start)

              Column() {
                if (item.postImgList?.[0]?.surfaceUrl) {
                  Stack() {
                    Image(item.postImgList?.[0]?.surfaceUrl)
                      .size({ width: 96, height: 72 })
                      .borderRadius(8)
                      .clip(true)
                    Image($r('app.media.play')).width(23).height(23)
                  }
                } else {
                  Image(item.postImgList?.[0].picVideoUrl)
                    .size({ width: 96, height: 72 })
                    .borderRadius(8)
                    .clip(true)
                }
              }
            }
            .id('recommend_' + index + item.id)
            .padding({ top: 12, bottom: 12 })
            .onClick(() => {
              this.newsFeedVM.pushToNewsDetails(item, 'recommend_' + index + item.id)
            })
            .backgroundColor($r('sys.color.background_primary'))
          }
        }, (item: NewsFeedInfo, index: number) => index + item.id)
      }
      .scrollBar(BarState.Off)
      .lanes(this.isFolderStatus ? 1 : this.lanesCount.getLanes(), 16)
      .edgeEffect(EdgeEffect.None)
    }
    .padding({
      left: this.newsBreakPoint.breakpointModel.pagePadding,
      right: this.newsBreakPoint.breakpointModel.pagePadding,
    })
    .backgroundColor($r('sys.color.background_primary'))
    .margin({ top: 8 })
  }
}