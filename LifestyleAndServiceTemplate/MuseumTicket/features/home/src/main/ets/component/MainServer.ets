import { RouterModule, RouterMap } from 'commonlib';
import { HomePageVM } from '../viewModels/HomePageVM';
import { ServerListItem } from '../types/Index';

@ComponentV2
export struct MainServer {
  vm: HomePageVM = HomePageVM.instance;

  build() {
    Column() {
      Grid() {
        ForEach(this.vm.serverList, (item: ServerListItem, index) => {
          GridItem() {
            Column() {
              Column() {
                Image(item.icon).height(index === 1 || 2 ? 24 : 36);
              }
              .width(48)
              .height(48)
              .borderRadius(24)
              .margin({ bottom: 16 })
              .backgroundColor($r('app.color.font_color_green'))
              .justifyContent(FlexAlign.Center);

              Text(item.name)
                .fontSize($r('sys.float.ohos_id_text_size_body3'))
                .fontColor($r('sys.color.ohos_id_color_text_primary'));
            };
          }.onClick(() => {
            RouterModule.push({ url: item.url });
          });
        }, (item: ServerListItem, index) => item.name);
      }.padding({ top: 6, left: 10, right: 10 })
      .columnsTemplate('1fr 1fr 1fr  1fr');
    }
    .width('100%')
    .height(90);

  }
}