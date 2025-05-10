import { TextStyleModifier, ThemeItem, ThemeModel } from 'common';
import { PersistenceV2 } from '@kit.ArkUI';

@ComponentV2
export struct ThemeToggleBuilder {
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  @Local themeChoose: ThemeItem = new ThemeItem()
  @Event confirm: (themeChoose: ThemeItem) => void = () => {
  }
  private themeList: ThemeItem[] = [
    {
      id: 'standard',
      name: '标准',
      color: '#f1f3f5',
      titleColor: '#000000',
      barColor: '#c4272b',
      buttonColor: '#c4272b',
      tabColor: '#c4272b',
      tabColorInActive: '#606162',
    },
    {
      id: 'red',
      name: '赤色',
      color: '#c4272b',
      titleColor: '#ffffff',
      barColor: '#ffffff',
      buttonColor: '#c4272b',
      tabColor: '#ffffff',
      tabColorInActive: '#ffffff',
    },
    {
      id: 'blue',
      name: '墨色',
      color: '#4f616d',
      titleColor: '#ffffff',
      barColor: '#ffffff',
      buttonColor: '#4f616d',
      tabColor: '#ffffff',
      tabColorInActive: '#ffffff',
    },
  ]

  aboutToAppear(): void {
    this.themeChoose.color = this.theme.themeState.current
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceEvenly, alignItems: ItemAlign.Center }) {
        ForEach(this.themeList, (item: ThemeItem) => {
          Column({ space: 5 }) {
            Stack() {
              Column()
                .width(48)
                .height(48)
                .backgroundColor(item.color)
                .borderRadius('50%')
              Image($r('app.media.theme_selected')).width(20).height(20)
                .position({ right: 0, bottom: -5 })
                .visibility(this.themeChoose.color === item.color ? Visibility.Visible : Visibility.None)
            }

            Text(item.name)
              .attributeModifier(new TextStyleModifier('font_primary/font_primary'))
          }
          .onClick(() => {
            this.themeChoose = item
          })

        }, (item: ThemeItem) => item.id)
      }

      Button('应用')
        .width('100%')
        .fontColor(this.theme.themeState.color)
        .backgroundColor(this.theme.themeState.current)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .padding({ top: 10, bottom: 10 })
        .onClick(() => {
          if (this.themeChoose?.id === 'standard') {
            this.theme.themeState.color = '#c4272b'
          } else {
            this.theme.themeState.color = '#ffffff'
          }
          this.theme.themeState.current = this.themeChoose?.color as string
          this.theme.themeState.name = this.themeChoose.name
          this.theme.themeState.id = this.themeChoose.id
          this.theme.themeState.barColor = this.themeChoose.barColor
          this.theme.themeState.titleColor = this.themeChoose.titleColor
          this.theme.themeState.buttonColor = this.themeChoose.buttonColor
          this.theme.themeState.tabColor = this.themeChoose.tabColor
          this.theme.themeState.tabColorInActive = this.themeChoose.tabColorInActive
          PersistenceV2.save(ThemeModel)
          this.confirm(this.themeChoose)
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: 26 })
    .height('100%')
    .padding({ left: 16, right: 16, bottom: Number(AppStorage.get('bottomRectHeight')) + 40 })
  }
}