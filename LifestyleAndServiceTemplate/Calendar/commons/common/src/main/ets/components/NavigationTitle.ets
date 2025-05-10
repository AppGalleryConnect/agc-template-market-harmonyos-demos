import { ThemeModel } from '../models/ThemeModel';
import { TextStyleModifier } from '../style/CommonStyle'
import { PersistenceV2 } from '@kit.ArkUI';

@ComponentV2
export struct NavigationTitle {
  @Param title: string = ''
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  build() {
    Row({ space: 8 }) {
      Row() {
        Image($r('app.media.left')).width(24).height(24)
      }
      .width(40)
      .justifyContent(FlexAlign.Center)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius('50%')

      Text(this.title)
        .attributeModifier(new TextStyleModifier(`${this.theme.themeState.titleColor}/Title_S/Bold`))
    }
    .height(86)
    .width('100%')
    .onClick(() =>  {
      this.pageInfos.pop()
    })
    .padding({ top: Number(AppStorage.get('topRectHeight')) ,left: 16, right: 16 })
    .backgroundColor(this.theme.themeState.current)
  }
}