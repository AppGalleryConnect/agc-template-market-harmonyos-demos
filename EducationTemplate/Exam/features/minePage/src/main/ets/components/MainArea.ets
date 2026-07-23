import { BreakpointModel, BreakpointType, PracticeRecordModel } from 'commonlib';
import { TableRow } from '../components/TableRow';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct MainArea {
  private scroller: Scroller = new Scroller();
  private settings: string[] = ['日期', '练习时长', '总题数', '错题数', '正确率'];
  @Consumer('offset') offsetX: number | undefined = undefined;
  @Param practiceRecordModels: PracticeRecordModel[] = [];
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


  // 监听滑动距离
  @Monitor ('offsetX')
  onCountUpdated(monitor: IMonitor) {
    if (this.offsetX) {
      this.scroller.scrollTo({
        xOffset: this.scroller.currentOffset()?.xOffset - this.offsetX * 50, // 滑动距离可根据实际情况设置
        yOffset: 0,
        animation: { duration: 1000, curve: Curve.Ease }
      });
    }
  }

  // table header
  @Builder
  tabHeader() {
    Column() {
      Flex({ alignItems: ItemAlign.Center }) {
        Scroll(this.scroller) {
          Row() {
            ForEach(this.settings, (setting: string) => {
              Text(setting)
                .width(this.getRowWidth)
                .textAlign(TextAlign.Center)
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .fontColor('rgba(0, 0, 0, 0.9)')
                .height(40)
            });
            if(this.breakpointModel.currentBreakpoint !== 'sm') {
              Text('操作')
                .fontSize(14)
                .width(this.breakpointModel.currentBreakpoint === 'md' ? 112 : 162)
                .fontWeight(500)
                .fontFamily('HarmonyHeiTi')
                .height(40)
                .textAlign(TextAlign.Center)
            }
          };
        }
        .scrollable(ScrollDirection.Horizontal) // 滚动方向纵向
        .width('100%')
        .scrollBar(BarState.Off) // 滚动条常驻显示
        .edgeEffect(EdgeEffect.None)
        // 禁止scroll滚动
        .enabled(false);

        if(this.breakpointModel.currentBreakpoint === 'sm') {
          Text('')
            .width(1)
            .height(40)
            .shadow({
              radius: 6,
              color: 'rgba(214, 209, 209, 1.00)',
              offsetX: -3,
              offsetY: 0,
            })

          Text('操作')
            .fontSize(14)
            .width(60)
            .fontWeight(500)
            .fontFamily('HarmonyHeiTi')
            .height(40)
            .textAlign(TextAlign.Center)
        }
      }
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }

  build() {
    List() {
      ListItemGroup({ header: this.tabHeader() }) {
        ForEach(this.practiceRecordModels, (item: PracticeRecordModel, index: number) => {
          ListItem() {
            Column() {
              TableRow({ infos: item })
            }
            .backgroundColor(index % 2 === 0 ? $r('sys.color.comp_background_primary') :
              $r('sys.color.comp_background_tertiary'))
          };
        });
      };
    }
    .scrollBar(BarState.Off)
    .sticky(StickyStyle.Header)
    .borderRadius(12)
    .border({width: 1, color: 'rgba(0, 0, 0, 0.2)'})
  }
}