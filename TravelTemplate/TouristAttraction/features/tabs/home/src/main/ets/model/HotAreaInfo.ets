import { HotAttractionsBuilder } from '../components/HotAttractions';
import { HotNotesBuilder } from '../components/HotNotes';

export interface HotAreaInfo {
  itemTitle: HotType,
  component: WrappedBuilder<[]>,
  routeEvent: (event: ClickEvent) => void
}

enum HotType {
  ATTRACTION = '热门景点',
  NOTE = '游玩攻略'
}

export function getHotAreaInfo(pathStack: NavPathStack) {
  return [
    {
      itemTitle: HotType.ATTRACTION,
      component: wrapBuilder(HotAttractionsBuilder),
      routeEvent: () => {
        pathStack.pushPathByName('Attractions', null);
      },
    },
    {
      itemTitle: HotType.NOTE,
      component: wrapBuilder(HotNotesBuilder),
      routeEvent: () => {
        pathStack.pushPathByName('Notes', null);
      },
    },
  ] as HotAreaInfo[];
}
