@ComponentV2
export struct InputModal {
  @Consumer() heightText: string = '';
  @Consumer() weightText: string = '';
  @Param title: string = '';
  @Param unit: string = '';
  @Param isVisible: boolean = false;
  @Param @Require onConfirm?: (value: number) => void;
  @Param @Require onCancel?: () => void;
  private initialHeight: number = 0;
  private initialWeight: number = 0;

  aboutToAppear() {
    this.initialHeight = parseFloat(this.heightText) || 0;
    this.initialWeight = parseFloat(this.weightText) || 0;
  }

  build() {
    if (this.isVisible) {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.End, justifyContent: FlexAlign.End }) {
        Column() {
          Text(this.title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 16, bottom: 16 })

          Row() {
            if (this.unit === 'cm') {
              TextInput({ text: this.heightText, placeholder: '请输入身高' })
                .type(InputType.NUMBER_DECIMAL)
                .width('70%')
                .height(40)
                .backgroundColor(Color.White)
                .borderRadius(4)
                .border({ width: 1, color: '#e5e5e5' })
                .padding(10)
                .onChange((value: string) => {
                  const isValidInput = /^(\d+|\d+\.\d*|\.\d+|\d*\.?)$/.test(value);
                  if (isValidInput) {
                    this.heightText = value;
                  }
                })
                .onSubmit(() => {
                  this.handleConfirm();
                })
            } else if (this.unit === 'kg') {
              TextInput({ text: this.weightText, placeholder: '请输入体重' })
                .type(InputType.NUMBER_DECIMAL)
                .width('70%')
                .height(40)
                .backgroundColor(Color.White)
                .borderRadius(4)
                .border({ width: 1, color: '#e5e5e5' })
                .padding(10)
                .onChange((value: string) => {
                  const isValidInput = /^(\d+|\d+\.\d*|\.\d+|\d*\.?)$/.test(value);
                  if (isValidInput) {
                    this.weightText = value;
                  }
                })
                .onSubmit(() => {
                  this.handleConfirm();
                })
            }

            Text(this.unit)
              .margin({ left: 8 })
          }
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 36 })

          Row({ space: 12 }) {
            Button('取消')
              .flexGrow(1)
              .fontColor($r('sys.color.font_primary'))
              .backgroundColor('#F2F2F2')
              .onClick(() => {
                this.handleCancel();
              })

            Button('确定')
              .flexGrow(1)
              .backgroundColor('#0BCFB1')
              .onClick(() => {
                this.handleConfirm();
              })
          }
          .width('100%')
          .height(45)
        }
        .width('100%')
        .height('30%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 12, topRight: 12, bottomLeft: 0, bottomRight: 0 })
        .border({ width: 1, color: '#e8e8e8' })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(0x66000000)
      .onClick(() => {
        this.handleCancel();
      })
      .position({ x: 0, y: 0 })
      .zIndex(999)
    }
  }

  private handleConfirm() {
    let num: number;
    if (this.unit === 'cm') {
      num = parseFloat(this.heightText);
      if (isNaN(num)) {num = this.initialHeight;}
      num = Math.max(1, Math.min(300, num));
    } else {
      num = parseFloat(this.weightText);
      if (isNaN(num)) {num = this.initialWeight;}
      num = Math.max(1, Math.min(300, num));
    }
    this.onConfirm?.(num);
  }

  private handleCancel() {
    if (this.unit === 'cm') {
      this.heightText = this.initialHeight.toString();
    } else {
      this.weightText = this.initialWeight.toString();
    }
    this.onCancel?.();
  }
}
