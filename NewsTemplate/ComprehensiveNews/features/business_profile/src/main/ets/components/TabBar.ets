import { CommonConstants } from 'lib_common'
import { TabItem, TAB_LIST } from '../common/Constants'

@ComponentV2
export struct TabBar {
  @Param selectedId: number = 0;
  @Param fontSizeRatio: number = 1;
  @Event onClickBar: (selectedId: number) => void = () => {
  };

  build() {
    Row({ space: CommonConstants.SPACE_L }) {
      ForEach(TAB_LIST, (v: TabItem) => {
        Column({ space: CommonConstants.SPACE_S }) {
          Text(v.label)
            .fontSize(16 * this.fontSizeRatio)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(this.selectedId === v.id ? FontWeight.Bold : FontWeight.Regular)
          Row()
            .width(16)
            .height(2)
            .backgroundColor($r('sys.color.font_primary'))
            .visibility(this.selectedId === v.id ? Visibility.Visible : Visibility.Hidden)
        }
        .padding({
          top: CommonConstants.SPACE_L,
          bottom: CommonConstants.SPACE_S
        })
        .onClick(() => {
          this.onClickBar(v.id);
        })
      }, (v: TabItem) => v.id + v.label)
    }
  }
}