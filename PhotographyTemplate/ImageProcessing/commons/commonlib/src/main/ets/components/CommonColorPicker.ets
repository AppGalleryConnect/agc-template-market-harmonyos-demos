import { CommonConstants } from '../constants/Constants';


@ComponentV2
export struct CommonColorPicker {
  @Event onSelectColor: (color: string) => void;
  @Local private selectedColor: string = '#FFFFFF'

  build() {
    Row() {
      ForEach(CommonConstants.COLOR_LIST, (item: string) => {
        Stack() {
          Circle({ width: 24, height: 24 })
            .fill(item)
            .stroke(item === '#FFFFFF' ? '#000000' : Color.Transparent);

          Circle({ width: 12, height: 12 })
            .fill(item === '#FFFFFF' ? '#000000' : '#FFFFFF')
            .visibility(this.selectedColor === item ? Visibility.Visible : Visibility.None);
        }
        .onClick(() => {
          this.selectedColor = item;
          this.onSelectColor?.(item)
        });
      }, (item: string) => item);
    }
    .justifyContent(FlexAlign.SpaceAround)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height(40)
  }
}