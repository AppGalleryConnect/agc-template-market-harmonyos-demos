import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { NewsSearchEntry } from 'lib_search';
import { InterActionTabContent } from '../components/InterActionTabContent';
import { TabEnum } from '../common/Constants';
import { TopicPageVM } from '../viewmodels/TopicPageVM';

@Builder
export function TopicResultPageBuilder() {
  TopicResultPage()
}

@ComponentV2
struct TopicResultPage {
  @Local vm: TopicPageVM = new TopicPageVM();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          rightPartBuilder: () => {
            this.rightHeadPartBuilder()
          },
        })

        Scroll() {
          Column() {
            this.titleBuilder()
            this.waterFlowBuilder()
          }
          .width(CommonConstants.FULL_PERCENT)
        }
        .width(CommonConstants.FULL_PERCENT)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring)
        .onReachEnd(() => {
          this.vm.showInfoTop = true;
        })
        .onReachStart(() => {
          this.vm.showInfoTop = false;
        })

        this.publishButton()
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((context) => {
      this.vm.initParams(context.pathInfo?.param as Object);
    })
  }

  @Builder
  titleBuilder() {
    Column({ space: 8 }) {
      Text(this.vm.currentTopic.title).fontSize(18).fontColor($r('sys.color.font_primary')).fontWeight(700)
      Row({ space: 8 }) {
        Text('阅读 2028').fontSize(14).fontColor($r('sys.color.font_secondary'))
        Text('讨论 9557').fontSize(14).fontColor($r('sys.color.font_secondary'))
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: this.vm.breakPointModel.pagePadding + 8,
      right: this.vm.breakPointModel.pagePadding + 8,
      top: CommonConstants.PADDING_S,
      bottom: CommonConstants.PADDING_L,
    })

  }

  @Builder
  waterFlowBuilder() {
    Column() {
      if (this.vm.currentTopic.title) {
        InterActionTabContent({
          selectedId: 3,
          resource: { id: TabEnum.Topic, label: '话题' },
          topic: this.vm.currentTopic,
          paddingTop: 0,
        })
      }
    }
    .padding({ bottom: this.vm.windowModel.windowBottomPadding })
  }

  @Builder
  publishButton() {
    Row() {
      Button() {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.pencil_waveform_fill'))
            .fontColor([$r('sys.color.font_on_primary')])
            .fontWeight(FontWeight.Normal)
            .fontSize(24)
          Text('参与讨论')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_on_primary'))
        }
        .width(128)
        .height(40)
        .justifyContent(FlexAlign.Center)
      }
      .onClick(() => {
        this.vm.postPublish();
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(40)
    .justifyContent(FlexAlign.Center)
    .hitTestBehavior(HitTestMode.Transparent)
    .position({
      y: '85%',
    })
  }

  @Builder
  rightHeadPartBuilder() {
    Row() {
      // 话题名称，显示在中间
      Text(this.vm.currentTopic.title)
        .fontSize(18)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .visibility(this.vm.showInfoTop ? Visibility.Visible : Visibility.Hidden)
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
        .margin({
          left: CommonConstants.PADDING_S,
          right: CommonConstants.PADDING_S,
        })

      // 搜索按钮，固定在右边
      NewsSearchEntry({ name: 'topic' })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
  }
}