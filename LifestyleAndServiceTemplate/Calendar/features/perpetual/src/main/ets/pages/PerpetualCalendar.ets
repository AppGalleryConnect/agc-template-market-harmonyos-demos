import { PersistenceV2 } from '@kit.ArkUI';
import dayjs from 'dayjs';
import { BaseCalendar } from 'base_calendar';
import { RouterModule } from 'router_module';
import { BaseCell, YiJiCell } from 'base_apis';
import { TrafficRestriction } from 'traffic_restriction';
import { TodayHistory } from 'today_history';
import {
  CalendarVM, GridRowColSetting, PAD_BOTTOM, ServiceTitle, ThemeModel, WeekStart,
} from 'common';
import { FestivalSolar } from '../components/festivalSolarCard/FestivalSolar';
import { CalendarTools } from '../components/calendarTools/CalendarTools';

@ComponentV2
export struct PerpetualCalendar {
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  @Local week: WeekStart = PersistenceV2.connect(WeekStart, () => new WeekStart())!;
  calendarVM: CalendarVM = CalendarVM.instance;
  @Param @Require jumpToAlmanac: () => void = () => {
  };

  aboutToAppear(): void {
    this.calendarVM.getTodayYiJi()
  }

  @Builder
  calendarToolsBuilder() {
    CalendarTools()
  }

  @Builder
  YIJICardBuilder() {
    YiJiCell({
      yiText: this.calendarVM.todayYiJi?.yi,
      jiText: this.calendarVM.todayYiJi?.ji,
      onYiJiCellClick: () => {
        this.jumpToAlmanac();
      },
    })
  }

  build() {
    Column() {
      ServiceTitle({
        title: '万年历',
        titleColor: this.theme.themeState.titleColor,
      })
      List({ space: 12 }) {
        ListItem() {
          BaseCalendar({
            currentDate: dayjs(this.calendarVM.selectDate).format('YYYY-MM-DD'),
            selectedStyle: 'circle',
            startWeekday: this.week.startWeek === 0 ? 'sunday' : 'monday',
            showHoliday: true,
            isShowLunar: true,
            festivalColor: Color.Red,
            selectedColor: this.theme.themeState.calendarColor,
            onCurrentDateSelected: (date: string) => {
              this.calendarVM.selectDate = dayjs(date)
              this.calendarVM.getTodayYiJi()
            },
          });
        }
        .padding(this.calendarVM.pagePadding)
        .opacity(0.8)

        ListItem() {
          GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
            GridCol({
              span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
            }) {
              BaseCell({
                cellTitle: this.calendarVM.getLunarDateLabel(),
                titleColor: this.theme.themeState.buttonColor,
                customBuilderParam: (): void => this.YIJICardBuilder(),
              })
            }

            GridCol({
              span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
            }) {
              BaseCell({
                cellTitle: '实用工具',
                customBuilderParam: (): void => this.calendarToolsBuilder(),
              })
            }
          }
        }
        .padding({ left: 16, right: 16 })


        ListItem() {
          FestivalSolar()
        }
        .padding({ left: 16, right: 16 })

        ListItem() {
          TrafficRestriction({
            selectDate: new Date(this.calendarVM.selectDate.format('YYYY-MM-DD')),
          })
        }
        .padding({ left: 16, right: 16 })

        ListItem() {
          TodayHistory({
            selectDate: new Date(this.calendarVM.selectDate.format('YYYY/MM/DD')),
            selectColor: this.theme.themeState.current,
            titleColor: this.theme.themeState.titleColor,
            routerModule: RouterModule.getStack(),
          })
        }
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 16 })

      }
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .layoutWeight(1)
    .backgroundImage($r('app.media.calender_bg'))
    .backgroundImageSize(ImageSize.Cover)
    .padding({ top: Number(AppStorage.get('topRectHeight')), bottom: this.calendarVM.pagePaddingBottom })
  }
}