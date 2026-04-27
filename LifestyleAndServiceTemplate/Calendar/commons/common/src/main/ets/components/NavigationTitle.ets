import { ThemeModel } from '../models/ThemeModel';
import { TextStyleModifier } from '../style/CommonStyle'
import { PersistenceV2 } from '@kit.ArkUI';
import { RouterModule } from 'router_module';

@ComponentV2
export struct NavigationTitle {
  @Param title: ResourceStr = ''
  @Param bgImage: ResourceStr = ''
  @Param bg: ResourceStr | Color = ''
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  @Event routerBack: () => void = () => {
  }

  build() {
    Row({ space: 8 }) {
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontColor([$r('sys.color.font_primary')])
          .fontWeight(FontWeight.Normal)
          .fontSize(24)
      }
      .width(40)
      .justifyContent(FlexAlign.Center)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_secondary'))
      .borderRadius('50%')

      Text(this.title)
        .attributeModifier(new TextStyleModifier(`font_primary/Title_S/Bold`))
    }
    .height(102)
    .width('100%')
    .onClick(() => {
      RouterModule.pop()
      this.routerBack()
    })
    .padding({ top: Number(AppStorage.get('topRectHeight')), left: 16, right: 16 })
    .backgroundColor($r('sys.color.background_primary'))
    .backgroundImage(this.bgImage)
    .backgroundImageSize(ImageSize.Cover)
  }
}