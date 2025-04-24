import { Header } from '../components/Header';
import { Settings } from '../components/Settings';
import { MinePageVM } from '../viewModels/MinePageVM';
import { VIPCard } from 'componentlib';

@Builder
export function minePageBuilder() {
  MinePage()
}

@ComponentV2
struct MinePage {
  vm: MinePageVM = MinePageVM.instance;

  build() {
    Column() {
      this.titleBuilder();
      Column() {
        Header()
        VIPCard()
        Settings()
      }
      .padding({
        left: $r('app.string.padding_s'),
        right: $r('app.string.padding_s'),
      })

    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .backgroundColor($r('app.color.system_color_background_auxiliary'))
    .height('100%')
    .width('100%')
  }

  @Builder
  titleBuilder() {
    Text(this.vm.minePageSetting.hotelName)
      .fontSize($r('app.string.font_size_36'))
      .fontWeight(600)
      .backgroundColor(Color.White)
      .width('100%')
      .padding($r('app.string.padding_m'))
  }
}