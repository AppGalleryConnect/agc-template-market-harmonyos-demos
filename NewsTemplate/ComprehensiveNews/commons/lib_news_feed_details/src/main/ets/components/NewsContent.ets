import { PersistenceV2 } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb'
import { BusinessError } from '@kit.BasicServicesKit'
import {
  FontPinchGestureUtils,
  FormatCount,
  GlobalContextUtils,
  Logger,
  RouterMap,
  RouterUtils,
  SettingModel,
  TimeUtils,
} from 'lib_common'
import { BaseAgent, Share, ShareContentType, ShareUtils } from 'lib_widget'
import { ImagePreview, ImagePreviewOptions, SourceImageModel } from 'module_imagepreview'
import { handlerCoverImage } from '../utils/Utils'
import NewsFeedVM from '../viewmodel/NewsFeedVM'
import { FeedBreakPointVM } from '../viewmodel/FeedBreakPointVM'

class Native {
  preview = (srcList: string[], index: number) => {
  }
  keywordExplain = (keyword: string) => {
  }
}

const TAG = '[NewsContent]';

@ComponentV2
export struct NewsContent {
  @Param fontSizeRatio: number = 1
  @Param newsFeedVM: NewsFeedVM = new NewsFeedVM()
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  webViewController: webview.WebviewController = new webview.WebviewController();
  @Local nativeObj: Native = new Native();
  @Local isExpand: boolean = false
  @Event onAddLike: () => void = () => {
  }
  @Event onAddWatch: () => void = () => {
  }
  @Event onComment: () => void = () => {
  }
  @Event onQuestionExpand: (isShow: boolean) => void = () => {
  };
  @Local isQuestionExpanded: boolean = false;
  @Local isShow: boolean = false;
  @Local webFontPinchUtils: FontPinchGestureUtils = new FontPinchGestureUtils();
  @Local currentFontScale: number = 1;
  @Local timer: number = 0
  @Local richTextHeight: number = 300
  @Local newsBreakPoint: FeedBreakPointVM = new FeedBreakPointVM()

  @Monitor('settingInfo.darkSwitch')
  darkSwitch() {
    this.webViewController.runJavaScript(`setWebFontColor(${this.settingInfo.darkSwitch})`)
      .catch((e: BusinessError) => {
        Logger.error(TAG, 'runJavaScript fail, error: ' + JSON.stringify(e));
      });
  }

  @Monitor('settingInfo.fontSizeRatio')
  onFontSizeRatioChange() {
    if (this.settingInfo.fontSizeRatio !== 1) {
      // 应用内设置了字体大小，禁用手势缩放
      this.webFontPinchUtils.setGestureEnabled(false);
      this.currentFontScale = 1;
    } else {
      // 应用内字体大小为 1（正常），启用手势缩放
      this.webFontPinchUtils.setGestureEnabled(true);
      this.currentFontScale = 1;
    }
  }

  expandAnimation() {
    if (this.timer) {
      clearTimeout(this.timer)
    }
    this.getUIContext().animateTo({
      duration: 500,
      curve: Curve.EaseOut,
      playMode: PlayMode.Normal,
    }, () => {
      this.isExpand = true
      this.timer = setTimeout(() => {
        this.isExpand = false
      }, 2000)
    })
  }

  @Builder
  authorBuilder() {
    Flex({ alignItems: ItemAlign.Center }) {
      Row({ space: 4 }) {
        Image(this.newsFeedVM.articleDetails.author.authorIcon).width(24).height(24).borderRadius(12).clip(true)
        Text(this.newsFeedVM.articleDetails.author.authorNickName)
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize(16 * this.fontSizeRatio)
      }

      Row() {
        Text() {
          Span(this.newsFeedVM.isWatch() ? '已关注' : '关注')
        }
        .fontSize(14 * this.fontSizeRatio)
        .fontColor(this.newsFeedVM.isWatch() ? $r('app.color.app_theme') : $r('sys.color.font_on_primary'))
        .onClick(() => {
          this.onAddWatch()
        })
      }
      .width(72)
      .height(28)
      .margin({ left: 16 })
      .backgroundColor(this.newsFeedVM.isWatch() ? $r('sys.color.background_primary') : $r('app.color.app_theme'))
      .borderRadius(14)
      .justifyContent(FlexAlign.Center)
      .visibility(!this.newsFeedVM.isFeedSelf ? Visibility.Visible : Visibility.None)
    }
    .visibility(this.isExpand ? Visibility.None : Visibility.Visible)
  }

  @Builder
  operationBuilder() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row({ space: 5 }) {
        Row() {
          Image(this.isExpand ? $r('app.media.down') : $r('app.media.up')).width(17).height(9)
        }
        .width(24).height(24)
        .borderRadius(12)
        .backgroundColor($r('sys.color.comp_background_tertiary'))

        Text(this.isExpand ? '收起' : '展开').fontColor($r('sys.color.font_on_primary'))
          .fontSize(16 * this.fontSizeRatio)
      }
      .onClick(() => {
        this.getUIContext().animateTo({
          duration: 500,
          curve: Curve.EaseOut,
          playMode: PlayMode.Normal,
        }, () => {
          this.isExpand = !this.isExpand
        })
      })

      Row({ space: 25 }) {
        Column({ space: 5 }) {
          Image($r('app.media.image_comment')).width(20).height(20)
          Text(this.newsFeedVM.articleDetails.commentCount?.toString())
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize(10 * this.fontSizeRatio)
        }
        .onClick(() => {
          ImagePreview.close()
          this.onComment()
        })

        Column({ space: 5 }) {
          Image(this.newsFeedVM.articleDetails.isLiked ? $r('app.media.like_active') : $r('app.media.preview_like'))
            .width(23)
            .height(20)
          Text(this.newsFeedVM.articleDetails.likeCount?.toString())
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize(10 * this.fontSizeRatio)
        }
        .onClick(() => {
          this.onAddLike()
        })

        this.shareBuilder()
      }
      .visibility(!this.isExpand ? Visibility.Visible : Visibility.None)
    }
  }

  aboutToAppear(): void {
    this.nativeObj.preview = this.preview
    this.nativeObj.keywordExplain = this.showKeywordSheet
    webview.WebviewController.setWebDebuggingAccess(false);

    // 初始化手势缩放工具类
    this.webFontPinchUtils
      .setOnFontSizeChange((scale: number) => {
        this.currentFontScale = scale;
      })
      .setOnReachMinScale(() => {
        GlobalContextUtils.showToast({ message: '已缩至最小' });
      })
      .setOnReachMaxScale(() => {
        GlobalContextUtils.showToast({ message: '已放至最大' });
      });

    // 根据应用内设置判断是否启用手势缩放
    if (this.settingInfo.fontSizeRatio !== 1) {
      this.webFontPinchUtils.setGestureEnabled(false);
    }
  }

  aboutToDisappear(): void {
    if (this.timer) {
      clearTimeout(this.timer);
      this.timer = 0;
    }
    try {
      this.webViewController.deleteJavaScriptRegister('native');
    } catch (e) {
      Logger.error(TAG, 'deleteJavaScriptRegister fail, error: ' + JSON.stringify(e));
    }
  }

  preview = (srcList: string[], index: number) => {
    const options = new ImagePreviewOptions()
    options
      .setImageList(srcList.map(v => new SourceImageModel({ imageUrl: v })))
      .setInitIndex(index)
      .setLoop(true)
      .setLongTake(false)
      .setImageActionListener({
        onLongPress: (index: number) => {
          new ShareUtils().openSheet(this.getUIContext(),
            {
              shareType: ShareContentType.IMAGE,
              imageUrl: srcList[index],
              title: '',
            },
          );
        },
      })
    ImagePreview.open(this.getUIContext(), options)
  }
  showKeywordSheet = (keyword: string) => {
    this.newsFeedVM.keyword = keyword;
    this.isShow = true;
  }

  @Builder
  shareCommentBuilder() {
    Column({ space: 5 }) {
      Image($r('app.media.image_forward'))
        .width(21)
        .height(21)
      Text(FormatCount.formatToK(this.newsFeedVM.articleDetails.shareCount))
        .fontSize(10 * this.fontSizeRatio)
        .fontColor($r('sys.color.font_on_primary'))
    }
  }

  @Builder
  shareBuilder() {
    Share({
      shareData: {
        recordId: this.newsFeedVM.articleDetails.id,
        title: this.newsFeedVM.articleDetails.title,
        subTitle: this.newsFeedVM.articleDetails.author?.authorNickName,
        createTime: this.newsFeedVM.articleDetails.createTime,
        coverUrl: handlerCoverImage(this.newsFeedVM.articleDetails),
      },
      shareRenderBuilder: () => {
        this.shareCommentBuilder()
      },
    })
  }

  @Computed
  get setWebFontSize() {
    if (this.settingInfo.fontSizeRatio < 1) {
      return this.settingInfo.fontSizeRatio
    } else if (this.settingInfo.fontSizeRatio > 1) {
      return this.settingInfo.fontSizeRatio * 2
    }
    return this.settingInfo.fontSizeRatio * 1.2 * this.currentFontScale
  }

  @Builder
  authorInfoBuilder() {
    Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      Row({ space: 4 }) {
        Image(this.newsFeedVM.articleDetails.author.authorIcon)
          .width(40)
          .height(40)
          .borderRadius(20)
          .clip(true)
          .accessibilityText(this.newsFeedVM.articleDetails.author.authorNickName + '头像')
          .onClick(() => {
            RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, this.newsFeedVM.articleDetails.author.authorId)
          })
        Column({ space: 4 }) {
          Text(this.newsFeedVM.articleDetails.author.authorNickName)
            .fontSize(14 * this.fontSizeRatio)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .constraintSize({ maxWidth: 'calc(100% - 44vp)' })
          Text(TimeUtils.formatDate(this.newsFeedVM.articleDetails.createTime))
            .fontSize(12 * this.fontSizeRatio)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .alignItems(HorizontalAlign.Start)
      }

      Row() {
        Text() {
          Span(this.newsFeedVM.isWatch() ? '已关注' : '关注')
        }
        .fontSize(14 * this.fontSizeRatio)
        .fontColor(this.newsFeedVM.isWatch() ? $r('app.color.app_theme') : $r('sys.color.font_on_primary'))
        .onClick(() => {
          this.newsFeedVM.watchOperation()
        })
      }
      .width(72)
      .height(28)
      .margin({ left: 16 })
      .visibility(!this.newsFeedVM.isFeedSelf ? Visibility.Visible : Visibility.None)
      .backgroundColor(this.newsFeedVM.isWatch() ? $r('sys.color.comp_background_tertiary') : $r('app.color.app_theme'))
      .borderRadius(14)
      .justifyContent(FlexAlign.Center)
    }
    .margin({ top: 12, bottom: 12 })
  }

  @Builder
  sheetBuilder() {
    Column() {
      Text(this.newsFeedVM.findKeywordExplain())
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(20).margin({ bottom: 24 });
      BaseAgent({ queryText: this.newsFeedVM.keyword });
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      top: 16,
      bottom: this.newsFeedVM.windowModel.windowBottomPadding + 8,
      left: 16,
      right: 16
    });
  }

  @Builder
  questionAndAnswerInfoBuilder() {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.TopStart }) {
          Text(`·${this.newsFeedVM.articleDetails.questionAndAnswer.question}`)
            .fontColor($r('sys.color.font_primary'))
            .textIndent(32);

          Row() {
            Text('问AI')
              .fontWeight(FontWeight.Medium)
              .blendMode(BlendMode.DST_IN, BlendApplyType.OFFSCREEN);
          }
          .linearGradient({
            angle: 90,
            direction: GradientDirection.Right,
            colors: [['rgb(61, 125, 231)', 0.0], ['rgb(70, 179, 251)', 1.0]],
          })
          .blendMode(BlendMode.SRC_OVER, BlendApplyType.OFFSCREEN);
        }.constraintSize({ maxWidth: 'calc(100% - 36vp)' });

        SymbolGlyph(this.isQuestionExpanded ? $r('sys.symbol.chevron_up') : $r('sys.symbol.chevron_down'))
          .fontSize(24)
          .fontColor([$r('sys.color.font_primary')])
          .fontWeight(FontWeight.Normal).onClick(() => {
          this.isQuestionExpanded = !this.isQuestionExpanded;
          this.onQuestionExpand(this.isQuestionExpanded);
        });
      }.width('100%').justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Top);

      if (this.isQuestionExpanded) {
        Text(this.newsFeedVM.articleDetails.questionAndAnswer.answer)
          .fontSize(14).lineHeight(20)
          .fontColor($r('sys.color.font_primary')).margin({ top: 16, bottom: 16 });

        Row() {
          BaseAgent({ queryText: this.newsFeedVM.articleDetails.questionAndAnswer.question });
        };
      }
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .margin({ top: 8 })
    .padding(12)
    .borderRadius(16);
  }

  build() {
    Column() {
      Column() {
        Column() {
          Text(this.newsFeedVM.articleDetails.title)
            .fontSize(20 * this.settingInfo.fontSizeRatio)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .padding({
        top: 8,
        bottom: 8,
      })
      .backgroundColor($r('sys.color.background_primary'))

      Column() {
        this.authorInfoBuilder()
      }
      .backgroundColor($r('sys.color.background_primary'))

      if (this.newsFeedVM.articleDetails?.questionAndAnswer) {
        this.questionAndAnswerInfoBuilder();
      }

      Column() {
        Web({
          src: '',
          controller: this.webViewController,
          renderMode: RenderMode.SYNC_RENDER,
        })
          .fileAccess(false)
          .layoutMode(WebLayoutMode.FIT_CONTENT)
          .geolocationAccess(false)
          .defaultFontSize(14 * this.setWebFontSize)
          .backgroundColor($r('sys.color.background_primary'))
          .accessibilityGroup(true)
          .onControllerAttached(() => {
            try {
              this.webViewController.loadData(
                this.newsFeedVM.setRichToHtml(),
                'text/html',
                'UTF-8',
              );
              this.webViewController.registerJavaScriptProxy(this.nativeObj, 'native', ['preview', 'keywordExplain']);
            } catch (error) {
              Logger.error(TAG,
                `ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
            }
          })
          .onPageEnd(async () => {
            this.webViewController.runJavaScript(`setKeywordColor()`)
              .catch((e: BusinessError) => {
                Logger.error(TAG, 'runJavaScript fail, error: ' + JSON.stringify(e));
              });
            this.webViewController.runJavaScript(`getSize()`)
              .then((result: string) => {
                let res: Record<string, number> = JSON.parse(result)
                this.richTextHeight = this.getUIContext().px2vp(res.height) * 1.2
              }).catch((e: BusinessError) => {
              Logger.error(TAG, 'runJavaScript fail, error: ' + JSON.stringify(e));
            });
            this.webViewController.runJavaScript(`setWebFontColor(${this.settingInfo.darkSwitch})`)
              .catch((e: BusinessError) => {
                Logger.error(TAG, 'runJavaScript fail, error: ' + JSON.stringify(e));
              });
          })
          .parallelGesture(
            PinchGesture({ fingers: 2 })
              .onActionStart(() => this.webFontPinchUtils.onActionStart())
              .onActionUpdate((event: GestureEvent) => this.webFontPinchUtils.onActionUpdate(event))
              .onActionEnd(() => this.webFontPinchUtils.onActionEnd()),
          )
      }.bindSheet($$this.isShow, this.sheetBuilder(), {
        height: SheetSize.FIT_CONTENT,
        title: { title: this.newsFeedVM.keyword },
        preferType: SheetType.CENTER,
        showClose: true,
      })
    }
    .padding({
      left: this.newsBreakPoint.breakpointModel.pagePadding,
      right: this.newsBreakPoint.breakpointModel.pagePadding,
    })
    .backgroundColor($r('sys.color.background_primary'))
  }
}