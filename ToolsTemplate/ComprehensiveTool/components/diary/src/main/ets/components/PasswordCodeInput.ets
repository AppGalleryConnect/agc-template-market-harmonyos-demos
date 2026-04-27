import { inputMethod } from '@kit.IMEKit';
import { PASSWORD_REG } from '../commons/Constant';

const MAX_LENGTH: number = 6;

@ComponentV2
export struct PasswordCodeInput {
  @Param value: string = '';
  @Event $value: (value: string) => void = () => {};
  private readonly codeInputId: string = 'PasswordCodeInput';
  private inputController: inputMethod.InputMethodController = inputMethod.getController();
  private isListen: boolean = false;
  private textConfig: inputMethod.TextConfig = {
    inputAttribute: {
      textInputType: inputMethod.TextInputType.NUMBER,
      enterKeyType: inputMethod.EnterKeyType.DONE
    }
  };
  private codeIndexArray: number[] = [0, 1, 2, 3, 4, 5];
  @Local codeText: string = '';
  // 键盘弹出收起状态
  @Local isShowKeyboard: boolean = false;

  aboutToAppear(): void {
    setTimeout(() => {
      this.attachAndListen();
    }, 200)
  }

  off(): void {
    this.inputController.off('insertText');
    this.inputController.off('deleteLeft');
    this.isListen = false;
    // 退出文本编辑状态
    this.inputController.hideTextInput();
    this.isShowKeyboard = false;
  }

  async attachAndListen(): Promise<void> {
    focusControl.requestFocus(this.codeInputId);
    await this.inputController.attach(true, this.textConfig);
    this.onListener();
    this.isShowKeyboard = true;
  }

  onListener() {
    if (this.isListen) {
      return;
    }
    this.inputController.on('insertText', (text: string) => {
      if (this.codeText.length >= MAX_LENGTH || !PASSWORD_REG.test(text)) {
        return;
      }
      this.codeText += text;
      this.$value(this.codeText);
    })
    this.inputController.on('deleteLeft', (length: number) => {
      this.codeText = this.codeText.substring(0, this.codeText.length - 1);
      this.$value(this.codeText);
    })

    this.inputController.on('sendFunctionKey', (functionKey: inputMethod.FunctionKey) => {
      if (functionKey.enterKeyType === inputMethod.EnterKeyType.DONE) {
        // 退出文本编辑状态
        this.inputController.hideTextInput();
        this.isShowKeyboard = false;
        this.$value(this.codeText);
      }
    })

    this.isListen = true;
  }

  // 绑定输入法
  async attach() {
    await this.inputController.attach(true, this.textConfig);
  }

  build() {
    Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      ForEach(this.codeIndexArray, (item: number) => {
        Row() {
          Circle()
            .width(8)
            .height(8)
            .fill($r('sys.color.font_primary'))
            .visibility(this.codeText[item] ? Visibility.Visible : Visibility.None)
        }
        .width(40)
        .height(40)
        .borderRadius(12)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }, (item: number) => item.toString())
    }
    .id(this.codeInputId)
    .width('100%')
    .backgroundColor(Color.Transparent)
    .defaultFocus(true)
    .onBlur(() => {
      // 绑定注册与解绑
      this.off();
    })
    .onClick(() => {
      this.attachAndListen();
    })
    .onDisAppear(() => {
      this.off();
    })
  }
}