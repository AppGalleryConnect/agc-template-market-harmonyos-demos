@ComponentV2
export struct CommonBarView {
  @BuilderParam part0: () => void;
  @BuilderParam part1: () => void;
  @BuilderParam part2: () => void;
  @BuilderParam part3: () => void;

  build() {
    Row() {
      Column() {
        this.part0();
      }
      .margin({ left: 10 });

      Column() {
        this.part1();
      }
      .margin({ left: 5 });

      Blank();
      Column() {
        this.part2();
      }
      .margin({ right: 10 });

      Column() {
        this.part3();
      }
      .margin({ right: 5 });
    }
    .width('100%');
  }
}