import { BreakpointModel,
  BreakpointType,
  GlobalContextUtils, PracticeRecordModel, RouterMap, RouterModule } from 'commonlib';
import { ScrollComponent } from './ScrollComponent';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct TableRow {
  @Param @Require infos: PracticeRecordModel;
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  operationWidth: BreakpointType<number> = new BreakpointType<number>({
    sm: 60,
    md: 112,
    lg: 162,
    xl: 162,
  });

  @Computed
  get getOperationWidth() {
    return this.operationWidth.getValue(this.breakpointModel.currentBreakpoint);
  }

  build() {
    Flex({ alignItems: ItemAlign.Center }) {
      ScrollComponent({ stock: this.infos });
      if(this.breakpointModel.currentBreakpoint === 'sm') {
        if(this.infos.totalCount) {
          Text('').shadowStyle()
          Text('查看')
            .fontSize(12)
            .width(this.getOperationWidth)
            .textAlign(TextAlign.Center)
            .height(40)
            .fontColor('rgba(75, 92, 196, 1)')
            .onClick(() => {
              if (this.infos.practiceCount) {
                RouterModule.push({ url: RouterMap.DAY_PRACTICE_DETAILS_PAGE, param: this.infos });
              } else {
                GlobalContextUtils.showToast({ message: '无练习记录' });
              }
            })
        } else {
          Text('').shadowStyle()
          Text('-')
            .fontSize(12)
            .width(this.getOperationWidth)
            .textAlign(TextAlign.Center).height(40)
        }
      }
    }.width('100%');
  }
}

@Extend(Text)
function shadowStyle() {
  .width(1)
  .height(40)
  .shadow({
    radius: 6,
    color: 'rgba(214, 209, 209, 1.00)',
    offsetX: -3,
    offsetY: 0,
  })
}