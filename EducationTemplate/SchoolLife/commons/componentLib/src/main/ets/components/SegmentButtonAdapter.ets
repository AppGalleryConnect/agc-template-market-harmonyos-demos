import { ItemRestriction, SegmentButton, SegmentButtonOptions, SegmentButtonTextItem } from '@kit.ArkUI';

@Component
export struct SegmentButtonAdapter {
  @State options: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '页签按钮1' }, { text: '页签按钮2' }] as ItemRestriction<SegmentButtonTextItem>,
  });

  @State tabSelectedIndexes: number[] = [];

  onItemClicked?: Callback<number>;

  build() {
    SegmentButton({
      options: this.options,
      selectedIndexes: $tabSelectedIndexes,
      onItemClicked: this.onItemClicked,
    })
  }
}