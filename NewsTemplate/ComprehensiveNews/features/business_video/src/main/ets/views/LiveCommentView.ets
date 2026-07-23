import { MeasureOptions } from '@kit.ArkUI';
import { CommonConstants, CommonDataSource } from 'lib_common';
import { CommentInfo } from 'lib_news_feed_details';
import { LiveCommentViewVM } from '../viewmodels/LiveCommentViewVM';

@ObservedV2
export class LivestreamCommentListScroller {
  scroller?: Scroller
}

@ComponentV2
export struct LiveCommentView {
  @Param commentListScroller: LivestreamCommentListScroller = new LivestreamCommentListScroller();
  @Consumer() commentListDataSource: CommonDataSource<CommentInfo> = new CommonDataSource<CommentInfo>();
  scroller: Scroller = new Scroller()
  vm: LiveCommentViewVM = new LiveCommentViewVM()

  aboutToAppear(): void {
    this.commentListScroller.scroller = this.scroller;
  }

  build() {
    Column() {
      List({ space: CommonConstants.SPACE_M, scroller: this.scroller }) {
        if (!this.commentListDataSource.totalCount()) {
          ListItem() {
            Column({ space: 16 }) {
              Text('还没有人评论，快来抢沙发吧')
                .fontWeight(FontWeight.Medium)
                .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
                .fontColor($r('sys.color.font_primary'))
            }
          }
          .width('100%')
          .height('100%')
        } else {
          LazyForEach(this.commentListDataSource, (item: CommentInfo, index: number) => {
            ListItem() {
              CommentItem({
                commentData: item,
              })
            }
          }, (item: CommentInfo) => JSON.stringify(item))
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .padding({
        left: CommonConstants.PADDING_L,
        right: CommonConstants.PADDING_L,
        top: CommonConstants.PADDING_M,
      })
    }
    .layoutWeight(1)
  }
}

@ComponentV2
struct CommentItem {
  @Param @Require commentData: CommentInfo
  @Local maxTextWidth: number = 10;

  build() {
    Row({ space: CommonConstants.SPACE_S }) {
      Image(this.commentData.author.authorIcon)
        .width(16)
        .height(16)
        .borderRadius(16)

      Row() {
        Text() {
          Span(this.authorNickName)
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
          Span(' ')
          Span(this.commentData.commentBody)
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
        }
      }
      .layoutWeight(1)
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.maxTextWidth = newValue.width as number
      })
    }
    .padding(CommonConstants.PADDING_S)
    .borderRadius(16)
    .backgroundColor($r('app.color.comment_input_bg'))
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Top)
  }

  @Computed
  get authorNickName() {
    const size = this.measureTextSize();
    if (size.width <= this.maxTextWidth) {
      return this.commentData.author.authorNickName;
    }
    return this.commentData.author.authorNickName.slice(0, 16) + '...';
  }

  measureTextSize(): Size {
    const option: MeasureOptions = {
      textContent: this.commentData.author.authorNickName,
      fontSize: 14,
      maxLines: 1,
    };
    const measureUtils = this.getUIContext().getMeasureUtils();
    return {
      width: this.getUIContext().px2vp(measureUtils.measureTextSize(option).width as number),
      height: this.getUIContext().px2vp(measureUtils.measureTextSize(option).height as number),
    }
  }
}