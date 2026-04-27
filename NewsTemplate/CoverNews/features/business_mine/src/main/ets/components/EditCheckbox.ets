import { CommonConstants } from 'lib_common';

@ComponentV2
export struct EditCheckbox {
  @Event onChange: (value: boolean) => void = () => {
  };

  build() {
    Row() {
      Checkbox()
        .width(24)
        .select(false)
        .shape(CheckBoxShape.CIRCLE)
        .onChange((value: boolean) => {
          this.onChange(value);
        })
    }
    .padding({
      right: CommonConstants.PADDING_L,
    })
  }
}