import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { BreakpointModel, SettingModel, CommonConfirmDialog, GlobalContextUtils, NewsEnum } from 'lib_common';
import { MineServiceApi, NewsResponse } from 'lib_news_api';
import { CardRegisterEngine } from 'lib_native_components';
import { FlexLayout, FlexLayoutEngine, LayoutSetting } from 'module_flexlayout';
import { RendNewsInfo } from '../model/Model';
import { ContentFeedbackDialogParams, ContentFeedbackView } from './ContentFeedbackDialog';

const TAG = '[FlexLayoutPage]'

/**
 * 动态布局组件
 * 核心逻辑参考FrameNodeFactory.ets/NativeNodeFactory.ets
 */
@ComponentV2
export struct FlexLayoutPage {
  @Param channelItem: RendNewsInfo | undefined = undefined
  @Param setting: LayoutSetting = new LayoutSetting()
  @Param articles: NewsResponse[] = []
  @Param flowIndex: number = 0
  @Param extraInfo: Record<string, number | string | boolean | Record<string, string | boolean>[] | Function> = {}
  @Event ignoreNews: () => void = () => {
  };
  @Event ignoreAuthor: (authorId: string) => void = () => {
  };
  @Local private settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  @Local private flexLayoutEngine: FlexLayoutEngine = new FlexLayoutEngine()
  @Local private breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local private showFeedbackSheet: boolean = false;
  @Local private detents: [(SheetSize | Length), (SheetSize | Length), (SheetSize | Length)?] = [360, 361];
  @Local private contentDialogParams: ContentFeedbackDialogParams = new ContentFeedbackDialogParams({})

  @Monitor('settingInfo.darkSwitch')
  darkSwitch() {
    /**
     * 调用rebuild接口通知NodeContainer组件重新回调makeNode方法，更新子节点。
     */
    this.flexLayoutEngine.frameController.rebuild();
  }

  aboutToAppear(): void {
    this.extraInfo.flowIndex = this.flowIndex
    this.extraInfo.channelId = this.channelItem?.id ?? ''
    this.extraInfo.onMoreClick = () => {
      this.showContentFeedbackSheet()
    }
    // 注册本地卡片
    CardRegisterEngine.CardRegister()
    // 初始化断点
    this.flexLayoutEngine.setBreakpointModel(this.breakpointModel)
    // 初始化本地数据
    this.flexLayoutEngine.createJsonLoader(this.setting, this.articles, this.extraInfo)
  }

  handleBlockNews() {
    this.showFeedbackSheet = false;
    this.ignoreNews();
    MineServiceApi.blockNews(this.articles[0]?.id);
    GlobalContextUtils.showToast({ message: '将减少此类内容推荐' });
  }

  handleBlockAuthor() {
    this.showFeedbackSheet = false;
    const authorId = this.articles[0]?.author?.authorId;
    this.ignoreAuthor(authorId);
    MineServiceApi.blockAuthor(authorId);
    GlobalContextUtils.showToast({ message: '将不再展示该作者的新闻' });
  }

  showContentFeedbackSheet() {
    this.contentDialogParams = new ContentFeedbackDialogParams({
      authorName: this.articles[0].author.authorNickName ?? '',
      blockParams: {
        keywords: this.articles[0].tags || ['五险一金', '公积金', '社保', '退休'],
        onBlockKeyword: () => {
          this.handleBlockNews();
        },
        onSubmitFeedback: () => {
          this.handleBlockNews();
        },
      },
      reportParams: {
        reasons: ['标题夸张', '旧闻重复', '封面反感', '内容质量差'],
        onReport: () => {
          this.handleBlockNews();
        },
      },
      onNotInterested: () => {
        this.handleBlockNews();
      },
      onBlockAuthor: () => {
        this.showFeedbackSheet = false;
        CommonConfirmDialog.show({
          primaryTitle: '确定拉黑该用户？',
          content: '拉黑后，将不再看到该用户的内容，也不会收到该用户的任何信息。',
          confirm: () => {
            this.handleBlockAuthor();
          },
        })
      },
    })
    this.contentDialogParams.changeSheetHeight = (keyboardH: number) => {
      this.detents = keyboardH > 0 ? [650, 651] : [360, 361];
    };
    this.showFeedbackSheet = true;
  }

  @Builder
  feedbackBuilder() {
    ContentFeedbackView({
      contentParams: this.contentDialogParams,
    })
  }

  build() {
    FlexLayout({
      flexLayoutEngine: this.flexLayoutEngine,
    })
      .bindSheet($$this.showFeedbackSheet, this.feedbackBuilder(), {
        showClose: true,
        detents: this.detents,
        preferType: SheetType.CENTER,
        backgroundColor: $r('app.color.common_sheet_bg'),
        scrollSizeMode: ScrollSizeMode.CONTINUOUS,
        onTypeDidChange: (type: SheetType) => {
          this.contentDialogParams.sheetType = type;
        },
        onWillDisappear: () => {
          this.showFeedbackSheet = false;
        },
      })
      .gesture(
        GestureGroup(GestureMode.Exclusive,
          LongPressGesture().onAction(() => {
            if (this.articles.length !== 1) {
              return;
            }
            // 互动卡片类型支持长按
            let isNeedAuthor = this.articles[0].extraInfo?.isNeedAuthor as boolean;
            if (this.articles[0].navInfo?.setting.includes('TopTextBottomVideoCard')) {
              isNeedAuthor = isNeedAuthor ?? true;
            }
            if (this.articles[0].navInfo?.setting.includes('FeedDetailsCard') || isNeedAuthor) {
              this.showContentFeedbackSheet();
            }
          }),
        ),
      )
  }
}