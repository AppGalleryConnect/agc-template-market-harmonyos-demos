import { Logger } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { BlockReasonView, IBlockReasonDialogParams, BlockReasonDialogParams } from './BlockReasonDialog';
import { IReportReasonDialogParams, ReportReasonView, ReportReasonDialogParams } from './ReportReasonDialog';

const TAG = '[ContentFeedbackDialog]'

export class FeedbackItemParams {
  icon: ResourceStr = '';
  title: string = '';
  subtitle?: string = '';
  showArrow?: boolean = false;
  showDivider?: boolean = true;
  onClick: () => void = () => {
  };
}

export interface IContentFeedbackDialogParams {
  authorName?: string;
  blockParams?: IBlockReasonDialogParams;
  reportParams?: IReportReasonDialogParams;
  onNotInterested?: () => void;
  onBlockAuthor?: () => void;
  onBlockKeywords?: () => void;
  onReport?: () => void;
}

@ObservedV2
export class ContentFeedbackDialogParams implements IContentFeedbackDialogParams {
  authorName: string = '';
  blockParams: IBlockReasonDialogParams = {};
  reportParams: IReportReasonDialogParams = {};
  @Trace sheetType: SheetType = SheetType.BOTTOM;
  onNotInterested: () => void = () => {
  };
  onBlockAuthor: () => void = () => {
  };
  onBlockKeywords: () => void = () => {
  };
  onReport: () => void = () => {
  };
  changeSheetHeight: (height: number) => void = () => {
  };

  constructor(item: IContentFeedbackDialogParams) {
    if (item.authorName) {
      this.authorName = item.authorName;
    }
    if (item.blockParams) {
      this.blockParams = item.blockParams;
    }
    if (item.reportParams) {
      this.reportParams = item.reportParams;
    }
    if (item.onNotInterested) {
      this.onNotInterested = item.onNotInterested;
    }
    if (item.onBlockAuthor) {
      this.onBlockAuthor = item.onBlockAuthor;
    }
    if (item.onBlockKeywords) {
      this.onBlockKeywords = item.onBlockKeywords;
    }
    if (item.onReport) {
      this.onReport = item.onReport;
    }
  }
}

@Builder
export function contentFeedbackView(contentParams: ContentFeedbackDialogParams) {
  ContentFeedbackView({ contentParams })
}

@ComponentV2
export struct ContentFeedbackView {
  @Require @Param contentParams: ContentFeedbackDialogParams;
  @Local paddingTop: number = 0;
  private pageStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.pageStack.pushPathByName('FeedbackListView', null, false);
    this.contentParams.onBlockKeywords = () => {
      this.pageStack.pushPathByName('Block', null);
    };
    this.contentParams.onReport = () => {
      this.pageStack.pushPathByName('Report', null);
    };
    this.onSheetTypeChange();
  }

  @Monitor('contentParams.sheetType')
  onSheetTypeChange() {
    this.paddingTop = this.contentParams.sheetType === SheetType.CENTER ? 16 : 0;
  }

  @Builder
  pageMap(pageName: string) {
    if (pageName === 'FeedbackListView') {
      FeedbackListView({ contentParams: this.contentParams })
    } else if (pageName === 'Block') {
      BlockReasonView({
        params: new BlockReasonDialogParams(this.contentParams.blockParams),
        changeSheetHeight: (keyboardH: number) => {
          this.contentParams.changeSheetHeight(keyboardH);
        },
      })
    } else if (pageName === 'Report') {
      ReportReasonView({ params: new ReportReasonDialogParams(this.contentParams.reportParams) })
    }
  }

  build() {
    Navigation(this.pageStack) {
    }
    .hideTitleBar(true)
    .hideNavBar(true)
    .navDestination(this.pageMap)
    .padding({ top: this.paddingTop })
  }
}

@ComponentV2
struct FeedbackListView {
  @Require @Param contentParams: ContentFeedbackDialogParams;

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '反馈',
          isSubTitle: false,
          showBackBtn: false,
          headerBarHeight: 40,
          customPadding: {
            top: 0,
            bottom: 8,
            left: 0,
            right: 0,
          },
        })
        Column() {
          FeedbackItem({
            itemParams: {
              icon: $r('sys.symbol.xmark_circle'),
              title: '不感兴趣',
              subtitle: '减少这类内容',
              showArrow: false,
              showDivider: true,
              onClick: () => {
                Logger.info(TAG, 'Not interested clicked');
                this.contentParams.onNotInterested();
              },
            },
          })
          FeedbackItem({
            itemParams: {
              icon: $r('sys.symbol.person_badge_nosign_fill_1'),
              title: `拉黑作者:  ${this.contentParams.authorName}`,
              showArrow: false,
              showDivider: true,
              onClick: () => {
                Logger.info(TAG, 'Block author clicked');
                this.contentParams.onBlockAuthor();
              },
            },
          })
          FeedbackItem({
            itemParams: {
              icon: $r('sys.symbol.nosign'),
              title: '屏蔽',
              subtitle: this.contentParams.blockParams.keywords?.join('、'),
              showArrow: true,
              showDivider: true,
              onClick: () => {
                this.contentParams.onBlockKeywords();
              },
            },
          })
          FeedbackItem({
            itemParams: {
              icon: $r('sys.symbol.exclamationmark_circle'),
              title: '举报',
              subtitle: '标题夸张、内容质量差等',
              showArrow: true,
              showDivider: false,
              onClick: () => {
                this.contentParams.onReport();
              },
            },
          })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.common_sheet_bg'))
  }
}

@ComponentV2
struct FeedbackItem {
  @Param itemParams: FeedbackItemParams = new FeedbackItemParams()

  build() {
    Column() {
      Row() {
        SymbolGlyph(this.itemParams.icon as Resource)
          .fontColor([$r('sys.color.font_primary')])
          .fontWeight(FontWeight.Normal)
          .fontSize(24)

        Column() {
          Text(this.itemParams.title)
            .fontSize(16)
            .fontColor($r('sys.color.font_primary'))
          if (this.itemParams.subtitle) {
            Text(this.itemParams.subtitle)
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 2 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })
        .layoutWeight(1)

        if (this.itemParams.showArrow) {
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontColor([$r('sys.color.font_secondary')])
            .fontWeight(FontWeight.Normal)
            .fontSize(24)
        }
      }
      .width('100%')
      .height(56)

      if (this.itemParams.showDivider) {
        Divider().margin({ left: 40 })
      }
    }
    .onClick(() => {
      this.itemParams.onClick();
    })
  }
}