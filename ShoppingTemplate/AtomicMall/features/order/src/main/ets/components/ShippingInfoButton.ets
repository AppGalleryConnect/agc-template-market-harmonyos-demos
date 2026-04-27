import { ItemRestriction, SegmentButton, SegmentButtonOptions, SegmentButtonTextItem } from '@kit.ArkUI';
import { ShippingOption } from 'lib_network';

@Component
export struct ShippingInfoButton {
  @State
  shippingOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '快递发货' }, { text: '到店自提' }] as ItemRestriction<SegmentButtonTextItem>,
    backgroundColor: $r('sys.color.comp_background_tertiary'),
    selectedBackgroundColor: $r('sys.color.comp_background_primary'),
    textPadding: 8,
  });
  @State
  shippingIndex: ShippingOption[] = [ShippingOption.EXPRESS];
  onShippingIndexChange: (index: number) => void = (index: number) => {
  };

  build() {
    Column() {
      SegmentButton({
        options: this.shippingOptions,
        selectedIndexes: $shippingIndex,
        onItemClicked: (index: number) => {
          const shippingIndex = index === 0 ? ShippingOption.EXPRESS : ShippingOption.SELF_PICK_UP;
          this.onShippingIndexChange?.(shippingIndex);
        },
      });
    };
  }
}