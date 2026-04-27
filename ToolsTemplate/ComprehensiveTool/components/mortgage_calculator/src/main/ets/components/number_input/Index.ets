import { NumberKeyboardBuilder } from '../number_keyboard/Index';

@ComponentV2
export struct NumberInput {
  controller: TextInputController = new TextInputController();
  @Param value: string = '';
  @Param max: number = 10000;
  @Param maxLen: number = 10;
  @Param isInteger: boolean = true;
  @Param isSmallHeight:boolean = false
  @Event handleChange: (value: string) => void;

  handleInputChange(value: string) {
    if (value === '-') {
      return;
    }
    if (value === 'Del' && this.value.length) {
      const newValue = this.value.slice(0, this.value.length - 1)
      this.handleChange(newValue);
      return;
    }
    if (value === 'Del' && !this.value.length) {
      return;
    }
    const result = this.value + value;
    const resultNum = Number(result);
    if (value === '.' && Number(this.value) === 0) {
      this.handleChange(result);
      return;
    }
    if (isNaN(resultNum)) {
      return;
    }
    if (resultNum > this.max) {
      return;
    }
    if (result.length > this.maxLen) {
      return;
    }
    if (this.isInteger && result.includes('.')) {
      return;
    }
    this.handleChange(result);
  }

  build() {
    TextInput({ controller: this.controller, text: this.value })
      .customKeyboard(NumberKeyboardBuilder({
        handleInput: (value) => {
          this.handleInputChange(value)
        },
        handleOk: () => {
          this.controller.stopEditing();
        },
        isSmallHeight:this.isSmallHeight
      })).height(36).borderRadius(6)
  }
}