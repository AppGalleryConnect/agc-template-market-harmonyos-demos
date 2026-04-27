import { baseActionSheet, BaseDatePicker, DividerTmp, BaseTextStyleModifier, BaseLunarCard } from 'base_apis';
import dayjs from 'dayjs';
import { getCurEndDate, getCurSolarDate, getLuckyMarriageDaysInTwoMonths } from '../../utils/Utils';
import { LuckyDays, PickerDate } from '../../model/Model';
import { COL_SPAN, GRID_ROW_OPTIONS } from '../../constants/Constants';

@ComponentV2
export struct YiJiDayQuery {
  /**
   * 查询结果集合
   */
  @Local jiDayResult: LuckyDays[] = []
  /**
   * list组件公用分割线
   */
  @Local egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')
  /**
   * 格式化日期
   */
  @Local datePicker: Date = new Date()
  /**
   * 宜忌选择
   */
  @Param choose: string = 'yi'
  /**
   * 开始查询的日期
   */
  @Param startDate: Date = new Date()
  /**
   * 主题
   */
  @Param selectColor: ResourceStr = '#c4272b'
  /**
   * 查询关键字
   */
  @Param value: string = ''
  /**
   * 开始日期
   */
  @Local localStartDate: string = ''
  /**
   * 结束日期
   */
  @Local localEndDate: string = ''
  /**
   * 是否展示农历
   */
  @Local isShowLunar: boolean = true
  /**
   * 是否展示星期
   */
  @Local isShowWeek: boolean = true
  /**
   * 显示格式
   */
  @Local showFormat: 'YYYY-MM-DD' | 'YYYY.MM.DD' = 'YYYY-MM-DD'
  /**
   * 卡片点击事件
   */
  @Event onLunarInfoCardClick: (lunarInfo: LuckyDays) => void = () => {
  }
  @Local isDayInWeek: boolean = false
  private context: UIContext = this.getUIContext();

  @Computed
  get jiDayResultList() {
    return this.isDayInWeek ? this.jiDayResult.filter(item => ['星期日', '星期六'].includes(item.weekday)) :
      this.jiDayResult
  }

  getJiDayInWeek(isOn: boolean) {
    if (isOn) {
      this.jiDayResult = this.jiDayResult.filter(item => ['星期日', '星期六'].includes(item.weekday))
    } else {
      this.jiDayResult =
        getLuckyMarriageDaysInTwoMonths(this.value, this.choose, new Date(this.localStartDate.split(' ')[0]),
          new Date(this.localEndDate.split(' ')[0]))
    }
  }

  aboutToAppear(): void {
    this.jiDayResult = getLuckyMarriageDaysInTwoMonths(this.value, this.choose, new Date(this.startDate))
    this.getJiDayEndDate(this.startDate)
    this.getJiDayStartDate(this.startDate)
  }

  initDateShow(date: PickerDate) {
    let result = ''
    date.currentDate = dayjs(date.currentDate).format(this.showFormat)
    if (this.isShowLunar && this.isShowWeek) {
      result = `${date.currentDate} ${date.weekday} ${date.lunarDate}`
    }
    if (this.isShowLunar && !this.isShowWeek) {
      result = `${date.currentDate} ${date.lunarDate}`
    }
    if (!this.isShowLunar && this.isShowWeek) {
      result = `${date.currentDate} ${date.weekday}`
    }
    if (!this.isShowLunar && !this.isShowWeek) {
      result = `${date.currentDate}`
    }
    return result
  }

  getJiDayEndDate(date: Date, type?: string) {
    let endDate = getCurEndDate(date, type)
    this.localEndDate = this.initDateShow(endDate)
  }

  getJiDayStartDate(date: Date) {
    let startDate = getCurSolarDate(date)
    this.localStartDate = this.initDateShow(startDate)
  }

  compareDates(start: Date, end: Date) {
    const timestamp1 = start.getTime()
    const timestamp2 = end.getTime()

    if (timestamp1 > timestamp2) {
      return false
    }
    return true
  }

  @Builder
  jiDayFilter() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          Text() {
            Span('近期')
            Span(this.choose === 'yi' ? '宜' : '忌')
            Span(this.value)
            Span('的日子共有')
            Span(this.jiDayResultList.length.toString())
              .fontColor('#C4272B')
              .fontWeight(FontWeight.Bold)
              .fontSize($r('sys.float.Body_L'))
            Span('天')
          }
          .attributeModifier(new BaseTextStyleModifier('#000000/Body_M/Regular'))
        }

        Row({ space: 5 }) {
          Text('只看周末')
            .attributeModifier(new BaseTextStyleModifier('#000000/Body_M/Regular'))
          Toggle({ type: ToggleType.Switch, isOn: false })
            .switchPointColor($r('sys.color.comp_background_primary_contrary'))
            .selectedColor($r('sys.color.comp_background_emphasize'))
            .onChange((isOn: boolean) => {
              this.isDayInWeek = isOn
              this.getJiDayInWeek(isOn)
            })
        }
      }

      Scroll() {
        GridRow(GRID_ROW_OPTIONS) {
          ForEach(this.jiDayResultList, (item: LuckyDays) => {
            GridCol({
              span: COL_SPAN,
            }) {
              BaseLunarCard({
                lunarInfo: item,
              })
            }
          }, (item: LuckyDays) => JSON.stringify(item))
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .layoutWeight(1)
    .padding({ left: 16, right: 16, bottom: 16 })
  }

  @Builder
  datePickerBuilder(type: string) {
    BaseDatePicker({
      datePicker: this.datePicker,
      selectColor: this.selectColor,
      confirm: (date: Date) => {
        if (type === 'start') {
          this.getJiDayStartDate(date)
        }
        let validate: boolean = false
        if (type === 'end') {
          validate = this.compareDates(date, new Date(this.localStartDate.split(' ')[0]))
          if (validate) {
            this.getUIContext()?.getPromptAction().showToast({ message: '开始时间不能大于结束时间' })
            return
          }
          this.getJiDayEndDate(date, type)
        }
        baseActionSheet.close(this.context, 'datePickerBuilder')
        this.jiDayResult =
          getLuckyMarriageDaysInTwoMonths(this.value, this.choose, new Date(this.localStartDate.split(' ')[0]),
            new Date(this.localEndDate.split(' ')[0]))
      },
      cancel: () => {
        baseActionSheet.close(this.context, 'datePickerBuilder')
      },
    })
  }

  @Builder
  jiDayOperation() {
    List({ space: 16 }) {
      ListItem() {
        Row() {
          Text('开始')
            .attributeModifier(new BaseTextStyleModifier(`#C4272B/Subtitle_M/Medium`))
          Row({ space: 5 }) {
            Text(this.localStartDate)
              .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))
            Image($r('app.media.chevron_right')).width(7).height(17)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          this.datePicker = new Date(dayjs(this.localStartDate.split(' ')[0]).format('YYYY-MM-DD'))
          baseActionSheet.show(this.context, {
            id: 'datePickerBuilder',
            detents: [300, 301],
            showClose: false,
            customContent: () => {
              this.datePickerBuilder('start')
            },
          })
        });
      }

      ListItem() {
        Row() {
          Text('结束')
            .attributeModifier(new BaseTextStyleModifier(`#C4272B/Subtitle_M/Medium`))
          Row({ space: 5 }) {
            Text(this.localEndDate)
              .attributeModifier(new BaseTextStyleModifier(`font_primary/Body_M/Regular`))
            Image($r('app.media.chevron_right')).width(7).height(17)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          this.datePicker = new Date(dayjs(this.localEndDate.split(' ')[0]).format('YYYY-MM-DD'))
          baseActionSheet.show(this.context, {
            id: 'datePickerBuilder',
            detents: [300, 301],
            showClose: false,
            customContent: () => {
              this.datePickerBuilder('end')
            },
          })
        });
      }

    }
    .padding({ left: 16, right: 16 })
    .divider(this.egDivider)
    .margin({ bottom: 16, top: 16 })
  }

  build() {
    NavDestination() {
      this.jiDayOperation()
      this.jiDayFilter()
    }
    .height('100%')
    .hideTitleBar(true)
  }
}