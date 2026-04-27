import { BaseCell } from 'base_apis';
import { calculateNextEvents, CalendarVM } from 'common';
import { RouterModule } from 'router_module';
import { FestivalInfo } from '../../model/Model';
import { FestivalCard } from './FestivalCard';

@ComponentV2
export struct FestivalSolar {
  @Local festivalList: FestivalInfo[] = []
  @Local vm: CalendarVM = CalendarVM.instance;

  @Monitor('vm.selectDate')
  onStrChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      this.festivalList = calculateNextEvents(this.vm.selectDate.format('YYYY-MM-DD'))
    })
  }

  aboutToAppear(): void {
    this.festivalList = calculateNextEvents(this.vm.selectDate.format('YYYY-MM-DD'))
  }

  @Builder
  festivalCardBuilder() {
    List({ space: 12 }) {
      ForEach(this.festivalList, (item: FestivalInfo) => {
        ListItem() {
          FestivalCard({
            festivalInfo: item,
            onFestivalCardClick: () => {
              RouterModule.pushPathByName({ url: 'FestivalDetails', param: item })
            },
          })
        }
      }, (item: FestivalInfo) => JSON.stringify(item))
    }
    .lanes(this.vm.getLanes(), 16)
    .margin({ top: 12 })
    .scrollBar(BarState.Off)
  }

  build() {
    BaseCell({
      cellTitle: '节日节气',
      customBuilderParam: (): void => this.festivalCardBuilder(),
    })
  }
}