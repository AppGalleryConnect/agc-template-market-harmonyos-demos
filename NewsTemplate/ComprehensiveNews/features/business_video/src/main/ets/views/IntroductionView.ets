import { CommonConstants } from 'lib_common'
import { FlexLayoutPage } from 'lib_flex_layout'
import { RequestListData } from 'lib_news_api'
import { IntroductionViewVM } from '../viewmodels/IntroductionViewVM'

@ComponentV2
export struct IntroductionView {

  vm: IntroductionViewVM = new IntroductionViewVM()

  aboutToAppear(): void {
    this.vm.init()
  }

  aboutToDisappear(): void {
    this.vm.disappear()
  }

  build() {
    Column() {
      List({ scroller: this.vm.scroller }) {
        LazyForEach(this.vm.introductionDataSource, (item: RequestListData) => {
          ListItem() {
            IntroductionCardItem({
              data: item
            })
          }
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .padding({
        left: CommonConstants.PADDING_L,
        right: CommonConstants.PADDING_L,
      })
    }
    .layoutWeight(1)
  }
}

@ComponentV2
struct IntroductionCardItem {
  @Param @Require data: RequestListData;

  @Computed
  get navInfoSetting() {
    if (this.data?.navInfo?.setting) {
      return this.data.navInfo.setting;
    }
    return '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}'
  }

  build() {
    Row({ space: CommonConstants.SPACE_S }) {
      Image(this.data?.articles?.[0].author.authorIcon ?? $r('app.media.ic_user_unlogin'))
        .width(20)
        .height(20)
        .borderRadius(20)

      Column() {
        Text(this.data?.articles?.[0].author.authorNickName ?? '华为用户')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
          .lineHeight(16)
        if (this.data?.articles && this.data?.extraInfo) {
          FlexLayoutPage({
            setting: JSON.parse(this.navInfoSetting),
            articles: this.data.articles,
            extraInfo: this.data.extraInfo,
          })
        } else {
          Text('冰川如同一面巨大的镜子，反射着天空的蓝，点缀着几朵白云，美得令人窒息。')
            .fontColor($r('sys.color.font_primary'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .padding({top: 8})
        }
      }
      .layoutWeight(1)
      .width(CommonConstants.FULL_PERCENT)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.Center)
    .padding({
      top: CommonConstants.SPACE_S
    })
  }
}