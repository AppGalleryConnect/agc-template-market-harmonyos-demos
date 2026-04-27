import dayjs from 'dayjs'
import { baseActionSheet } from '../apis/ActionSheet';
import { TextStyleModifier } from '../model/TextStyleModifier';
import { AlmanacVM } from '../viewmodel/ViewModel';
import { BaseDatePicker } from './BaseDatePicker';

@ComponentV2
export struct DateToggle {
  /**
   * 主题id
   */
  @Param themeId: string = 'white'
  /**
   * 按钮颜色
   */
  @Param selectTextColor: ResourceStr = ''
  /**
   * 时间格式化
   */
  @Local dateFormat: 'YYYY-MM-DD' | 'YYYY年MM月DD日' | 'YYYY.MM.DD' = 'YYYY年MM月DD日'
  /**
   * 日期变化事件
   */
  @Event onDateChange: (date: Date) => void = () => {
  }
  almanacVM: AlmanacVM = AlmanacVM.instance;

  @Builder
  alDatePickerBuilder() {
    BaseDatePicker({
      datePicker: new Date(dayjs(this.almanacVM.selectDate).format('YYYY-MM-DD')),
      confirm: (date: Date) => {
        this.almanacVM.selectDate = date
        this.onDateChange(date)
        baseActionSheet.close('almanacBuilder')
      },
      cancel: () => {
        baseActionSheet.close('almanacBuilder')
      },
    })
  }

  build() {
    Column() {
      Row() {
        Text(dayjs(this.almanacVM.selectDate).format(this.dateFormat))
          .attributeModifier(new TextStyleModifier('font_primary/Subtitle_M/Regular'))
        Image($r('app.media.ic_bottom'))
          .width(24)
          .fillColor('#000000')
      }.margin({ top: 10 })
      .onClick(() => {
        baseActionSheet.show({
          uiContext: this.getUIContext(),
          id: 'almanacBuilder',
          detents: [300, 301],
          showClose: false,
          customContent: () => {
            this.alDatePickerBuilder()
          },
        })
      })

      Row() {
        Image(this.themeId === 'blue' ? $r('app.media.ic_left_blue') : $r('app.media.ic_left'))
          .height(24)
          .onClick(() => {
            this.almanacVM.selectDate = new Date(dayjs(this.almanacVM.selectDate).add(-1, 'day').format('YYYY-MM-DD'))
            this.onDateChange(this.almanacVM.selectDate)
          })
        Text(this.almanacVM.lunarDate)
          .attributeModifier(new TextStyleModifier(`${this.selectTextColor}/Title_L/Bold`))
          .margin({ right: 26, left: 26 })
          .fontSize(30)
        Image(this.themeId === 'blue' ? $r('app.media.ic_right_blue') : $r('app.media.ic_right'))
          .height(24)
          .onClick(() => {
            this.almanacVM.selectDate = new Date(dayjs(this.almanacVM.selectDate).add(1, 'day').format('YYYY-MM-DD'))
            this.onDateChange(this.almanacVM.selectDate)
          })
      }
      .width('100%')
      .margin({ top: 13 })
      .justifyContent(FlexAlign.Center)

      Text(this.almanacVM.yinLiDate)
        .attributeModifier(new TextStyleModifier('font_primary/Body_L/Regular'))
        .margin({ top: 12, bottom: 16 })
    }
    .border({
      width: { bottom: 1 }, color: $r('app.color.splits_color'),
    })
  }
}