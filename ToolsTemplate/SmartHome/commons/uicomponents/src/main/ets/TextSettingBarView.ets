import { CustomContentDialog } from '@kit.ArkUI';
import { TextBarView } from './TextBarView';

@ComponentV2
export struct TextSettingBarView {
  @Param startImage?: ResourceStr = '';
  @Param maxLength?: number = 8
  @Require @Param name: string = '';
  @Require @Param value: string = '';
  @Require @Param valueChangeCb: (value: string) => void;
  @Local textShow: string = this.value;
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: this.name,
      contentBuilder: () => {
        this.buildContent();
      },
      buttons: [
        {
          value: '取消',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            console.info('Callback when the button is clicked');
          },
        },
        {
          value: '确定',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            console.info('Callback when the button is clicked');
            if (this.textShow !== '') {
              this.valueChangeCb(this.textShow);
            }
          },
        },
      ],
    }),
    backgroundColor: Color.White,
  });

  @Builder
  buildContent() {
    TextInput({ text: this.textShow })
      .showUnderline(true)
      .onChange((value: string) => {
        this.textShow = value;
      })
      .maxLines(1)
      .showCounter(true)
      .maxLength(this.maxLength)
      .backgroundColor(Color.White);
  }

  build() {
    TextBarView({
      startImage: this.startImage,
      name: this.name,
      value: this.value,
    })
      .onClick(() => {
        this.dialogController.open();
      });
  }
}