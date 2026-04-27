import { ThemeModel } from '../models/ThemeModel';
import { PersistenceV2 } from '@kit.ArkUI';

@ComponentV2
export struct ServiceTitle {
  @Param title: ResourceStr = ''
  @Param titleColor: ResourceStr = ''
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;

  build() {
    Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
      Text(this.title)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Title_M'))
    }
    .height(56)
    .backgroundColor(Color.Transparent)
    .padding({ left: 16, right: 16 })
  }
}