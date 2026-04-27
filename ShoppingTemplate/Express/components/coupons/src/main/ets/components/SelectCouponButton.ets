import { SegmentButtonV2Items, TabSegmentButtonV2 } from '@kit.ArkUI';

/** 可用/不可用分段切换按钮 */
@ComponentV2
export struct SelectCouponButton {
  @Local options: SegmentButtonV2Items = new SegmentButtonV2Items([
    { text: '可用' },
    { text: '不可用' },
  ]);
  @Local selectedIndex: number = 0;
  @Event onIndexChange: (index: number) => void = (_index: number) => {
  };

  @Monitor('selectedIndex')
  onSelectedIndexChange(_monitor: ESObject) {
    this.onIndexChange(this.selectedIndex);
  }

  build() {
    Row() {
      TabSegmentButtonV2({
        items: this.options,
        selectedIndex: this.selectedIndex!!,
      })
        .layoutWeight(1)
    }
    .padding({
      left: $r('app.float.padding_16'),
      right: $r('app.float.padding_16')
    })
  }
}
