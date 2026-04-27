import { HomePageVM } from '../viewModels/HomePageVM';

@ComponentV2
export struct CommonButton {
  vm: HomePageVM = HomePageVM.instance;
  @Param text: string = ''

  build() {
    Row() {
      Text(this.text)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor('#0A59F7')
        .lineHeight(16)
    }
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .backgroundColor('#BFD5FF')
    .borderRadius(16)
    .justifyContent(FlexAlign.Center)
  }
}