import { FeedbackRecordDTO } from '../models/FeedbackRecordDTO';
import { FeedbackRecordVM } from '../viewmodels/FeedbackRecordVM';
import { BreakpointType } from '../common/CustomTypes';
import { Api } from '../http/Api';
import { FileUtils } from '../utils/FileUtils';

@ComponentV2
struct FeedbackHistoryPage {

  private navPathStack: NavPathStack = new NavPathStack();

  @Local
  private feedbacks: FeedbackRecordVM[] = [];

  @Local
  private isInitializing: boolean = true;

  @Local
  private templateForGrid: string = '1fr '.repeat(4);

  @Local
  private templateForWaterFlow: string = '1fr';

  @Local
  private imagesGap: number = 8;

  private readonly TITLE_BAR_HEIGHT: number = 56;

  public aboutToAppear(): void {
    FileUtils.initUIContext(this.getUIContext());
    Api.listFeedbacks()
      .then((records: FeedbackRecordDTO[]) => {
        for (const dto of records) {
          const feedback: FeedbackRecordVM = new FeedbackRecordVM();
          feedback.assignFromDTO(dto);
          this.feedbacks.push(feedback);
        }
      })
      .finally(() => this.isInitializing = false);
  }

  public build(): void {
    NavDestination() {
      Column() {
        this.buildTitleBar()
        GridRow({
          columns: 12,
          breakpoints: { value: [ '320vp', '600vp', '840vp', '1440vp' ] }
        }) {
          GridCol({
            span: { xs: 12, sm: 12, md: 10, lg: 12 },
            offset: { xs: 0, sm: 0, md: 1, lg: 0 }
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
                    this.buildFeedbackCard(feedback)
                  }, (feedback: FeedbackRecordVM) => feedback.id)
                }
                .width('100%')
                .height('100%') // 设置为 '100%' 将瀑布流溢出屏幕以实现底部沉浸式，使用 footer 代替 padding bottom 进行避让
                .columnsTemplate(this.templateForWaterFlow)
                .columnsGap(12)
                .padding({ left: 16, right: 16 })
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
          if (breakpoints === BreakpointType.XS || breakpoints === BreakpointType.SM) {
            this.templateForGrid = '1fr '.repeat(4);
            this.imagesGap = 8;
            this.templateForWaterFlow = '1fr';
          } else if (breakpoints === BreakpointType.MD) {
            this.templateForGrid = '1fr '.repeat(6);
            this.imagesGap = 12;
            this.templateForWaterFlow = '1fr';
          } else {
            this.templateForGrid = '1fr '.repeat(4);
            this.imagesGap = 8;
            this.templateForWaterFlow = '1fr '.repeat(3);
          }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => this.navPathStack = ctx.pathStack)
  }

  @Builder
  private buildFeedbackCard(feedback: FeedbackRecordVM): void {
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
        ForEach(feedback.images, (uri: string) => {
          GridItem() {
            Column() {
              Image(uri)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Contain)
                .draggable(false)
            }
            .width('100%')
            .aspectRatio(1)
            .borderRadius(16)
            .backgroundColor($r('sys.color.background_secondary'))
            .clip(true)
          }
        }, (uri: string, index: number) => index + '_' + uri)
      }
      .width('100%')
      .height('auto')
      .columnsTemplate(this.templateForGrid)
      .rowsGap(this.imagesGap)
      .columnsGap(this.imagesGap)
    }
    .width('100%')
    .padding(12)
    .margin({ top: 12 })
    .borderRadius(16)
    .backgroundColor($r('sys.color.background_primary'))
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildWaterFlowFooter(): void {
    Column()
      .width('100%')
      .height(this.TITLE_BAR_HEIGHT + 12)
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
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .maxLines(1)
    }
    .width('100%')
    .height(this.TITLE_BAR_HEIGHT)
    .padding({ left: 16, right: 16 })
  }
}

@Builder
export function buildFeedbackHistoryPage(): void {
  FeedbackHistoryPage()
}
