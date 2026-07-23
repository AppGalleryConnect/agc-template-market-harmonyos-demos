import { BreakpointModel, BreakpointType,
  GlobalContextUtils,
  PracticeRecordModel, RouterMap, RouterModule } from 'commonlib';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct ScrollComponent {
  scroller: Scroller = new Scroller();
  @Param @Require stock: PracticeRecordModel;
  @Consumer('offset') offsetX: number | undefined = undefined;
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  tableRowWidth: BreakpointType<number> = new BreakpointType<number>({
    sm: 70,
    md: 112,
    lg: 180,
    xl: 180,
  });

  @Computed
  get getRowWidth() {
    return this.tableRowWidth.getValue(this.breakpointModel.currentBreakpoint);
  }

  @Monitor('offsetX')
  // 监听滑动距离
  onCountUpdated(monitor: IMonitor) {
    if (this.offsetX) {
      this.scroller.scrollTo({
        xOffset: this.scroller.currentOffset()?.xOffset - this.offsetX * 50, // 滑动距离可根据实际情况设置
        yOffset: 0,
        animation: { duration: 1000, curve: Curve.Ease }
      });
    }
  }

  build() {
    Scroll(this.scroller) {
      Row() {
        Text(this.stock.date).textStyles(this.getRowWidth)
        Text(this.stock.practiceDuration ?? '-').textStyles(this.getRowWidth)
        Text(this.stock.totalCount ?? '-').textStyles(this.getRowWidth)
        Text(this.stock.wrongCount ?? '-').textStyles(this.getRowWidth)
        Text(this.stock.correctRate ?? '-').textStyles(this.getRowWidth)
        if(this.breakpointModel.currentBreakpoint !== 'sm') {
          if(this.stock.totalCount) {
            Text('查看')
              .fontSize(12)
              .width(this.breakpointModel.currentBreakpoint === 'md' ? 112 : 162)
              .textAlign(TextAlign.Center)
              .height(40)
              .fontColor('rgba(75, 92, 196, 1)')
              .onClick(() => {
                if (this.stock.practiceCount) {
                  RouterModule.push({ url: RouterMap.DAY_PRACTICE_DETAILS_PAGE, param: this.stock });
                } else {
                  GlobalContextUtils.showToast({ message: '无练习记录' });
                }
              })
          } else {
            Text('-')
              .fontSize(12)
              .width(this.breakpointModel.currentBreakpoint === 'md' ? 112 : 162)
              .textAlign(TextAlign.Center).height(40)
          }
        }
      }
      .padding({ top: 4, bottom: 4 })
    }
    .scrollable(ScrollDirection.Horizontal) // 滚动方向纵向
    .scrollBar(BarState.Off) // 滚动条常驻显示
    .edgeEffect(EdgeEffect.None)
    .width('100%')
    // 禁止scroll滚动
    .enabled(this.breakpointModel.currentBreakpoint === 'sm' ? false : true);
  }
}

@Extend(Text)
function textStyles(getRowWidth: number) {
  .width(getRowWidth)
  .textAlign(TextAlign.Center)
  .fontSize($r('sys.float.Caption_L'))
  .fontWeight(FontWeight.Regular)
  .fontColor($r('sys.color.font_secondary'));
}