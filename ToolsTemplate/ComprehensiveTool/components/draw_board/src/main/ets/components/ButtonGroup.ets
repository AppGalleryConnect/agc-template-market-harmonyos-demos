import { ItemRestriction, SegmentButton, SegmentButtonOptions, SegmentButtonTextItem } from '@kit.ArkUI';

export interface IButtonItem {
  id: string;
  label: string;
}

@ComponentV2
export struct ButtonGroup {
  @Param buttonList: IButtonItem[] = [];
  @Param selectedId: string = '';
  @Event $selectedId: (value: string) => void = () => {};
  @Param currentIndex: number = 0;


  build() {
    Row() {
      CustomSegment({
        currentIndex: this.currentIndex,
        rawList: this.buttonList,
        onChange: (index: number) => {
          this.$selectedId(this.buttonList[index]?.id);
        },
      })
    }
  }
}

@Component
struct CustomSegment {
  @State currentIndex: number = 0;
  @State tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '' }, { text: '' }] as ItemRestriction<SegmentButtonTextItem>,
    fontSize: $r('sys.float.Body_M'),
    selectedFontSize: $r('sys.float.Body_M'),
    fontColor: $r('sys.color.font_secondary'),
    selectedFontColor: $r('sys.color.font_primary'),
    fontWeight: FontWeight.Medium,
    selectedFontWeight: FontWeight.Medium,
    backgroundColor: $r('sys.color.comp_background_tertiary'),
    selectedBackgroundColor: $r('sys.color.ohos_id_color_foreground_contrary_disable'),
    textPadding: {
      top: 8,
      bottom: 8,
      right: 16,
      left: 16
    },
  })
  @State @Watch('onSegmentButtonChange') tabSelectedIndexes: number[] = [this.currentIndex];
  rawList: IButtonItem[] = [];
  onChange: (index: number) => void = () => {
  };

  aboutToAppear(): void {
    const newList: SegmentButtonTextItem[] = [];
    this.rawList.forEach(v => {
      const item = {
        text: v.label
      } as SegmentButtonTextItem
      newList.push(item);
    })
    this.tabOptions.buttons = newList;
  }

  onSegmentButtonChange() {
    this.currentIndex = this.tabSelectedIndexes[0];
    this.onChange(this.currentIndex);
  }

  build() {
    SegmentButton({ options: this.tabOptions, selectedIndexes: this.tabSelectedIndexes })
      .width('100%')
  }
}