import { PersistenceV2 } from '@kit.ArkUI';
import dayjs from 'dayjs';
import { ThemeModel } from '../model/ThemeModel';
import CalendarVM from '../viewmodel/CalendarVM';
import { VernacularContainer } from '../components/VernacularContainer';
import { CalendarController } from '../model/Index';
import { CalendarAlmanac } from '../components/CalendarAlmanac';
import { setPathStack } from '../utils/Route';

@Builder
export function AlmanacViewBuilder() {
  Almanac();
}

@ComponentV2
export struct Almanac {
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  calendarController: CalendarController = new CalendarController();
  vm: CalendarVM = CalendarVM.instance;

  @Builder
  almanacVernacular() {
    VernacularContainer();
  }

  aboutToAppear(): void {
    this.vm.getTodayYiJi();
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        List() {
          ListItem() {
            CalendarAlmanac({
              selectDate: new Date(this.vm.selectDate.format('YYYY-MM-DD')),
              selectTextColor: this.theme.themeState.buttonColor,
              arrowColor: this.theme.themeState.id,
              onDateChange: (date: Date) => {
                this.vm.selectDate = dayjs(date);
                this.calendarController.setSelectDate(date);
                this.vm.getTodayYiJi();
              },
            });
          };

          ListItem() {
            this.almanacVernacular();
          };
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false });
      }
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
    }.title('黄历').backgroundColor($r('sys.color.background_secondary')).onReady((ctx) => {
      setPathStack(ctx.pathStack);
    });
  }
}