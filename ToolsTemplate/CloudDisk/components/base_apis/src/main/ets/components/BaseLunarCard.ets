import dayjs from 'dayjs'
import { CALCULATION_TYPE, LuckyDays } from '../model/Model'
import { BaseTextStyleModifier } from '../model/TextStyleModifier'

/**
 * @usage: 用于农历信息展示场景。提供农历日期卡片展示功能，包含公历日期、农历日期、干支纪年、值神、十二神、星宿等信息。
 * 关键数据结构：LuckyDays（宜忌信息模型，包含solarDate公历日期、lunarDate农历日期、weekday星期、
 * ganZhiYear干支年、ganZhiMonth干支月、ganZhiDay干支日、daysFromNow距今天数、forwardOrBack前后标志CALCULATION_TYPE枚举）、
 * onLunarInfoCardClick（卡片点击回调函数，参数为LuckyDays）。
 * 包含if逻辑：根据weekday判断是否为周末（星期六、星期日显示红色），根据daysFromNow判断显示"今天"或"X天前/后"。
 * @layout: 横向Flex布局（SpaceBetween对齐）。左侧Row包含两部分：第一部分Column垂直排列公历日期（年份、月日、星期，
 * 周末显示红色#C4272B，工作日显示font_primary，右侧带分割线），第二部分Column垂直排列农历信息
 * （农历日期、干支纪年月日Row、值神和十二神Row、星宿信息）。右侧Row显示距今天数（天数+前/后，天数加粗）。
 * 整体浅黄色背景#FDF7EE，圆角16vp，内边距上下14vp左右12vp。
 * @constraints: lunarInfo农历信息必须完整且有效，日期格式化使用dayjs库（格式：YYYY.MM-DD），
 * 周末判断逻辑固定为星期六和星期日，文字样式使用BaseTextStyleModifier修饰器（格式：颜色/字号/字重），
 * daysFromNow为0或null时显示"今天"，forwardOrBack为FORWARD时显示"天前"，为其他值时显示"天后"
 * @isGen: true
 * @fileType: component
 * @zhName: 基础农历卡片组件
 */

@ComponentV2
export struct BaseLunarCard {
  /**
   * 当前宜忌信息
   */
  @Require @Param lunarInfo: LuckyDays = new LuckyDays()
  /**
   * 卡片点击事件
   */
  @Event onLunarInfoCardClick: (lunarInfo: LuckyDays) => void = () => {}

  isWeekDay(item: LuckyDays) {
    return ['星期日', '星期六'].includes(item.weekday)
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row({ space: 12 }) {
        Column({ space: 12 }) {
          Text(dayjs(this.lunarInfo.solarDate).format('YYYY.MM-DD').split('-')[0])
            .attributeModifier(new BaseTextStyleModifier(`${this.isWeekDay(this.lunarInfo) ? '#C4272B' :
              'font_primary'}/Body_S/Regular`))
          Text(dayjs(this.lunarInfo.solarDate).format('YYYY.MM-DD').split('-')[1])
            .attributeModifier(new BaseTextStyleModifier(`${this.isWeekDay(this.lunarInfo) ? '#C4272B' :
              'font_primary'}/30/Regular`))
          Text(this.lunarInfo.weekday)
            .attributeModifier(new BaseTextStyleModifier(`${this.isWeekDay(this.lunarInfo) ? '#C4272B' :
              'font_primary'}/Body_S/Regular`))
        }
        .border({
          width: { right: 1 },
          color: { right: '#ccc' },
        })
        .padding({ right: 16 })

        Column({ space: 5 }) {
          Text(this.lunarInfo.lunarDate)
            .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_S/Regular'))
          Row({ space: 5 }) {
            Text(this.lunarInfo.ganZhiYear)
              .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_S/Regular'))
            Text(this.lunarInfo.ganZhiMonth)
              .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_S/Regular'))
            Text(this.lunarInfo.ganZhiDay)
              .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_S/Regular'))
          }

          Row({ space: 5 }) {
            Text('值神：天刑')
              .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))
            Text('十二神：满日')
              .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))
          }


          Text('星宿：胃土雉宿星')
            .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))
        }
        .alignItems(HorizontalAlign.Start)
      }

      Row() {
        Text(this.lunarInfo.daysFromNow ? this.lunarInfo.daysFromNow.toString() : '今天')
          .attributeModifier(new BaseTextStyleModifier('font_primary/Body_L/Bold'))
        Text(this.lunarInfo.forwardOrBack === CALCULATION_TYPE.FORWARD ? '天前' : '天后')
          .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))
          .visibility(this.lunarInfo.daysFromNow ? Visibility.Visible : Visibility.None)
      }
    }
    .padding({
      top: 14,
      bottom: 14,
      left: 12,
      right: 12,
    })
    .onClick(() => {
      this.onLunarInfoCardClick(this.lunarInfo)
    })
    .backgroundColor('#FDF7EE')
    .borderRadius(16)
  }
}