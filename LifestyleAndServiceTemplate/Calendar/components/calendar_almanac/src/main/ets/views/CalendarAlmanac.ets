import { YiJiCell } from 'base_apis'
import { DateToggle } from '../components/dateToogle/DateToogle'
import { FiveElementsClashElements } from '../components/fiveElementsClashElements/FiveElementsClashElements'
import { TaboosAccordPengZu } from '../components/taboosAccordPengZu/TaboosAccordPengZu'
import { AlmanacVM } from '../viewModel/ViewModel'

@ComponentV2
export struct CalendarAlmanac {
  /**
   * 当前日期
   */
  @Param selectDate: Date = new Date()

  /**
   * 主题id
   */
  @Param arrowColor: 'standard' | 'blue' | 'red' = 'standard'

  /**
   * 按钮颜色
   */
  @Param selectTextColor: ResourceStr = '#c4272b'


  @Event onDateChange:(date: Date) => void = () => {}


  almanacVM: AlmanacVM = AlmanacVM.instance;
  @Monitor('selectDate')
  selectDateChange() {
    this.almanacVM.setSelectDate(this.selectDate)
  }
  aboutToAppear(): void {
    this.almanacVM.setSelectDate(this.selectDate)
  }

  @Builder
  almanacHeader() {
    DateToggle({
      themeId: this.arrowColor,
      selectTextColor: this.selectTextColor,
      onDateChange: (date: Date) => {
        this.onDateChange(date)
      },
    })
  }

  @Builder
  almanacContent() {
    YiJiCell({
      yiText: this.almanacVM.yiText,
      jiText: this.almanacVM.jiText,
      isEllipsis: false,
    })
  }

  @Builder
  almanacFiveElement() {
    FiveElementsClashElements()
  }

  @Builder
  almanacDetails() {
    TaboosAccordPengZu()
  }

  build() {
    Column() {
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

      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('sys.color.background_secondary'))
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
    }
  }
}