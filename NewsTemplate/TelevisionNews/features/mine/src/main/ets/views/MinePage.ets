import { Constants, GridRowColSetting, NavHeaderTitleBar } from 'lib_common';
import { PersonalInfoCard } from '../components/PersonalInfoCard';
import { UsedServices } from '../components/UsedServices';

@ComponentV2
export struct MinePage {
  @Local breakpoint: string = '';

  build() {
    GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
      GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS }) {
        Column() {
          NavHeaderTitleBar({
            title: '我的',
            hasBackButton: false,
            bgColor: $r('sys.color.background_secondary'),
          })
            .padding({ left: 16 })
          Scroll() {
            Column() {
              PersonalInfoCard()
              UsedServices({ breakpoint: this.breakpoint })
              Blank().layoutWeight(1)
            }
          }
          .margin({
            left: 16,
            right: 16,
          })
          .padding({ top: 12 })
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
          .edgeEffect(EdgeEffect.Spring);

          Blank().layoutWeight(1)
        }
        .alignItems(HorizontalAlign.Start)
        .width(Constants.FULL_SIZE)
        .backgroundColor($r('sys.color.background_secondary'))
      }
    }.onBreakpointChange((bp) => {
      this.breakpoint = bp;
    })
  }
}