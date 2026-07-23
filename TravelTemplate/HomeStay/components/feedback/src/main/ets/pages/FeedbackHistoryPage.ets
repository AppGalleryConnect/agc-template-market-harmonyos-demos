import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { FeedbackRecordDTO } from '../models/FeedbackRecordDTO';
import { FeedbackRecordVM } from '../viewmodels/FeedbackRecordVM';
import { PreviewImgType } from '../common/CustomTypes';
import { Api } from '../http/Api';
import { FileUtils } from '../utils/FileUtils';
import { ImagePreviewer } from '../utils/ImagePreviewer';
import { GridRowColSetting } from '../common/GridRowColSetting';

@ComponentV2
struct FeedbackHistoryPage {
  @Local
  private feedbacks: FeedbackRecordVM[] = [];
  @Local
  private isInitializing: boolean = true;
  @Local
  private breakpoint: string = 'sm';
  @Local
  private selectedCardId: string = '';
  private readonly TITLE_BAR_HEIGHT: number = 56;
  private navPathStack: NavPathStack = new NavPathStack();
  private imagePreviewer: ImagePreviewer = new ImagePreviewer(this.getUIContext());
  @Local
  private windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 0;
  @Local
  private windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 0;

  public aboutToAppear(): void {
    FileUtils.init(this.getUIContext().getHostContext() as common.UIAbilityContext);
    Api.listFeedbacks()
      .then((records: FeedbackRecordDTO[]) => {
        for (const dto of records) {
          this.feedbacks.push(new FeedbackRecordVM(dto));
        }
      })
      .finally(() => this.isInitializing = false);
  }

  public build(): void {
    NavDestination() {
      Column() {
        this.buildTitleBar()
        GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
          GridCol({
            span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS,
          }) {
            if (!this.isInitializing) {
              if (this.feedbacks.length === 0) {
                Column() {
                  Text('暂无反馈记录')
                    .fontColor($r('sys.color.font_secondary'))
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Regular)
                }
                .width('100%')
                .layoutWeight(1)
                .padding({ bottom: this.TITLE_BAR_HEIGHT })
                .justifyContent(FlexAlign.Center)
              } else {
                WaterFlow({
                  layoutMode: WaterFlowLayoutMode.SLIDING_WINDOW,
                  footer: this.buildWaterFlowFooter()
                }) {
                  ForEach(this.feedbacks, (feedback: FeedbackRecordVM) => {
                    this.buildFeedbackCard(feedback, util.generateRandomUUID(false))
                  }, (feedback: FeedbackRecordVM) => feedback.id)
                }
                .width('100%')
                .height('100%') // 设置为 '100%' 将瀑布流溢出屏幕以实现底部沉浸式，使用 footer 代替 padding bottom 进行避让
                .columnsTemplate(GridRowColSetting.getWaterFloColumns(this.breakpoint))
                .rowsGap(GridRowColSetting.getGutter(this.breakpoint))
                .columnsGap(GridRowColSetting.getGutter(this.breakpoint))
                .scrollBar(BarState.Off)
                .edgeEffect(EdgeEffect.Spring)
              }
            } else {
              Column({ space: 8 }) {
                LoadingProgress()
                  .width(72)
                  .height(72)
                Text('正在加载...')
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Regular)
              }
              .width('100%')
              .layoutWeight(1)
              .padding({ bottom: this.TITLE_BAR_HEIGHT })
              .justifyContent(FlexAlign.Center)
            }
          }
        }
        .onBreakpointChange((breakpoints: string) => {
          this.breakpoint = breakpoints;
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .padding({
        left: GridRowColSetting.getPageMargin(this.breakpoint),
        right: GridRowColSetting.getPageMargin(this.breakpoint),
      })
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => this.navPathStack = ctx.pathStack)
  }

  @Builder
  private buildFeedbackCard(feedback: FeedbackRecordVM, cardId: string): void {
    Column() {
      Text(feedback.displayDate)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .margin({ bottom: 12 })
      Text('问题描述')
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .margin({ bottom: 8 })
      Text(feedback.description)
        .width('100%')
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular)
        .margin({ bottom: 12 })
      Grid() {
        ForEach(feedback.images, (uri: string, index: number) => {
          GridItem() {
            Column() {
              Image(uri)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Contain)
                .draggable(false)
            }
            .id(cardId + index + JSON.stringify(uri))
            .width('100%')
            .aspectRatio(1)
            .borderRadius(16)
            .backgroundColor($r('sys.color.background_secondary'))
            .clip(true)
            .visibility(
              index === this.imagePreviewer.previewIndex && cardId === this.selectedCardId ?
                Visibility.Hidden : Visibility.Visible
            )
            .onClick(() => {
              this.selectedCardId = cardId;
              this.imagePreviewer
                .updateImagesByUris(feedback.images)
                .previewImage(index, (item: PreviewImgType, index: number) => {
                  return cardId + index + JSON.stringify(item);
                });
            })
          }
        }, (uri: string) => uri)
      }
      .width('100%')
      .height('auto')
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(8)
      .columnsGap(8)
    }
    .width('100%')
    .padding(12)
    .margin({ top: 8 })
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildWaterFlowFooter(): void {
    Column()
      .width('100%')
       .height(this.TITLE_BAR_HEIGHT + this.windowBottomHeight + 12)
  }

  /**
   * todo: 如果需要自定义标题栏样式，可以从以下代码着手修改
   */
  @Builder
  private buildTitleBar(): void {
    Row() {
      /**
       * 页面返回按钮
       */
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
          .fontWeight(FontWeight.Normal)
      }
      .width(40)
      .height(40)
      .margin({ right: 8 })
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => this.navPathStack.pop())

      /**
       * 标题文本
       */
      Text('反馈记录')
        .layoutWeight(1)
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .maxLines(1)
    }
     .width('100%')
     .height(this.TITLE_BAR_HEIGHT)
     .margin({ top: this.windowTopHeight })
  }
}

@Builder
export function buildFeedbackHistoryPage(): void {
  FeedbackHistoryPage()
}
