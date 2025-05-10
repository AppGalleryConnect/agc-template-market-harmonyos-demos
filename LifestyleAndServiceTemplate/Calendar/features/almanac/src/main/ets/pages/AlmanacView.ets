import { CalendarVM, commonActionSheet, DatePickerDialog, ServiceTitle, TextStyleModifier, ThemeModel } from 'common'
import { PersistenceV2 } from '@kit.ArkUI';

@Preview
@ComponentV2
export struct Almanac {
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  vm: CalendarVM = CalendarVM.instance

  @Builder
  alDatePickerBuilder() {
    DatePickerDialog({
      confirm: (date: Date) => {
        this.vm.changeDate(date);
        commonActionSheet.close('almanacBuilder')
      },
      cancel: () => {
        commonActionSheet.close('almanacBuilder')
      },
    })
  }

  @Builder
  almanacHeader() {
    Column() {
      Row() {
        Text(this.vm.selectDate.format('YYYY年MM月DD日'))
          .attributeModifier(new TextStyleModifier('font_primary/Subtitle_M/Regular'))
        Image($r('app.media.ic_bottom'))
          .width(24)
          .fillColor('#000000')
      }.margin({ top: 10 })
      .onClick(() => {
        commonActionSheet.show({
          id: 'almanacBuilder',
          height: 300,
          showClose: false,
          customContent: () => {
            this.alDatePickerBuilder()
          },
        })
      })

      Row() {
        Image(this.theme.themeState.id === 'blue' ? $r('app.media.ic_left_blue') : $r('app.media.ic_left'))
          .height(24)
          .onClick(() => {
            this.vm.getPreDate()
          })
        Text(this.vm.getLunarDateLabel())
          .attributeModifier(new TextStyleModifier(`${this.theme.themeState.buttonColor}/Title_L/Bold`))
          .margin({ right: 26, left: 26 })

        Image(this.theme.themeState.id === 'blue' ? $r('app.media.ic_right_blue') : $r('app.media.ic_right'))
          .height(24)
          .onClick(() => {
            this.vm.getNextDate()
          })
      }
      .width('100%')
      .margin({ top: 13 })
      .justifyContent(FlexAlign.Center)

      Text(this.vm.lunarInfo?.yinli)
        .attributeModifier(new TextStyleModifier('font_primary/Body_L/Regular'))
        .margin({ top: 12, bottom: 16 })
    }
    .border({
      width: { bottom: 1 }, color: $r('app.color.splits_color'),
    })
  }

  @Builder
  almanacContent() {
    Column() {
      Flex() {
        Image($r('app.media.ic_yi_str'))
          .width(20)
          .margin({ right: 12 })
        Text() {
          ForEach(this.vm.todayYiJi?.yi, (value: string) => {
            Span(value + '  ')
          })
        }
        .attributeModifier(new TextStyleModifier('font_primary/Subtitle_S/Regular'))
        .flexGrow(1)
        .lineHeight(20)
      }
      .width('100%')
      .margin({ bottom: 24 })

      Flex() {
        Image($r('app.media.ic_ji_str'))
          .width(20)
          .margin({ right: 12 })
        Text() {
          ForEach(this.vm.todayYiJi?.ji, (value: string) => {
            Span(value + '  ')
          })
        }
        .attributeModifier(new TextStyleModifier('font_primary/Subtitle_S/Regular'))
        .flexGrow(1)
      }
    }
    .margin({ top: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  almanacFiveElement() {
    Flex() {
      Column({ space: 5 }) {
        Text('五行：')
          .attributeModifier(new TextStyleModifier('#966426/Body_L/Bold'))
        Text(this.vm.lunarInfo?.wuxing)
          .attributeModifier(new TextStyleModifier('font_primary/Body_M/Regular'))
      }
      .alignItems(HorizontalAlign.Start)
      .border({
        width: { right: 1 },
        color: { right: '#cccccc' },
      })
      .flexGrow(1)

      Column({ space: 5 }) {
        Text('冲煞：')
          .attributeModifier(new TextStyleModifier('#966426/Body_L/Bold'))
        Text(this.vm.lunarInfo?.chongsha)
          .attributeModifier(new TextStyleModifier('font_primary/Body_M/Regular'))
      }
      .alignItems(HorizontalAlign.Start)
      .flexGrow(1)
      .margin({ left: 12 })
    }
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding({
      left: 12,
      top: 16,
      bottom: 16,
      right: 12,
    })
    .margin({ top: 26 })
  }

  @Builder
  almanacDetails() {
    Row() {
      Column() {
        Text('五行:')
          .attributeModifier(new TextStyleModifier('#966426/Body_L/Bold'))
        Text(this.vm.lunarInfo?.wuxing)
          .attributeModifier(new TextStyleModifier('font_primary/Body_M/Regular'))
      }.width('50%')
      .padding({ left: 12 })

      Column() {
        Text('冲煞:')
          .attributeModifier(new TextStyleModifier('#966426/Body_L/Bold'))
        Text(this.vm.lunarInfo?.chongsha)
          .attributeModifier(new TextStyleModifier('font_primary/Body_M/Regular'))
      }.width('50%').padding({ left: 12 }).border({ width: { left: 1 }, color: $r('app.color.splits_color') })
    }
    .backgroundColor($r('app.color.font_color_white'))
    .borderRadius(16)
    .margin({ top: 26 })
    .padding({ top: 16, bottom: 16 })

    Column() {
      Column({ space: 5 }) {
        Text('彭祖百忌')
          .attributeModifier(new TextStyleModifier('font_primary/Body_L/Bold'))
        Column() {
          Text(this.vm.lunarInfo?.baiji)
            .attributeModifier(new TextStyleModifier('font_primary/Body_M/Regular'))
        }
      }
      .width('100%')
      .padding({ bottom: 16 })
      .border({ width: { bottom: 1 }, color: $r('app.color.splits_color') })

      Flex() {
        Column() {
          Text('吉神宜趋')
            .attributeModifier(new TextStyleModifier('font_primary/Body_L/Bold'))
          Column() {
            Text(this.vm.lunarInfo?.jishen)
              .attributeModifier(new TextStyleModifier('font_primary/Body_M/Regular'))
          }
          .padding(12)
        }
        .width('50%')
        .border({ color: $r('app.color.splits_color'), width: { right: 1 } })
        .justifyContent(FlexAlign.Center)

        Column() {
          Text('凶神宜忌')
            .attributeModifier(new TextStyleModifier('font_primary/Body_L/Bold'))
          Column() {
            Text(this.vm.lunarInfo?.xiongshen)
              .attributeModifier(new TextStyleModifier('font_primary/Body_M/Regular'))
          }
          .padding(12)
        }.width('50%')
      }.margin({ top: 15 })
    }
    .backgroundColor($r('app.color.font_color_white'))
    .margin({ top: 12 })
    .borderRadius(16)
    .padding({
      top: 16,
      bottom: 16,
      left: 12,
      right: 12,
    })
  }

  build() {
    Column() {
      ServiceTitle({
        title: '黄历',
        titleColor: this.theme.themeState.titleColor,
      })
      List() {
        ListItem() {
          this.almanacHeader()
        }

        ListItem() {
          this.almanacContent()
        }

        ListItem() {
          this.almanacFiveElement()
        }

        ListItem() {
          this.almanacDetails()
        }
      }.width('100%')
      .padding(16)
      .layoutWeight(1)
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
  }
}