import { CheckInHistoryDetailDataItem } from '../../types/Types';
import { CheckInTimeDetailItem } from './CheckInTimeDetailItem'

@ComponentV2
export struct CheckInTimeDetail {
  @Param checkinTimeDetailItemList: CheckInHistoryDetailDataItem[] = [];
  private controller: Scroller = new Scroller();

  build() {
    List({ scroller: this.controller }) {
      ForEach(this.checkinTimeDetailItemList, (item: CheckInHistoryDetailDataItem, index) => {
        ListItem() {
          CheckInTimeDetailItem({
            'time': item.time,
            'location': item.location,
            'isFirst': index === 0,
            'isLast': index !== 0 && index === this.checkinTimeDetailItemList.length - 1
          })
        }
      })
    }.listDirection(Axis.Vertical)
    .scrollBar(BarState.Off)
  }
}