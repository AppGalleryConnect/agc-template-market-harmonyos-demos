import { PersistenceV2 } from '@kit.ArkUI';
import dayjs from 'dayjs';
import { CalendarVM, ServiceTitle, ThemeModel } from 'common'
import { CalendarController } from 'base_calendar';
import { CalendarAlmanac } from 'calendar_almanac';
import { VernacularContainer } from '../components/VernacularContainer';

@Preview
@ComponentV2
export struct Almanac {
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  calendarController: CalendarController = new CalendarController();
  vm: CalendarVM = CalendarVM.instance

  @Builder
  almanacVernacular() {
    VernacularContainer()
  }

  build() {
    Column() {
      ServiceTitle({
        title: '黄历',
        titleColor: this.theme.themeState.titleColor,
      })
      List() {
        ListItem() {
          CalendarAlmanac({
            selectDate: new Date(this.vm.selectDate.format('YYYY-MM-DD')),
            selectTextColor: this.theme.themeState.buttonColor,
            arrowColor: this.theme.themeState.id,
            onDateChange: (date: Date) => {
              this.vm.selectDate = dayjs(date)
              this.calendarController.setSelectDate(date)
              this.vm.getTodayYiJi()
            },
          })
        }

        ListItem() {
          this.almanacVernacular()
        }
      }
      .scrollBar(BarState.Off)
    }
    .justifyContent(FlexAlign.Start)
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
    .border({ width: { left: this.vm.isTabVertical ? 1 : 0 }, color: '#ccc' })
  }
}