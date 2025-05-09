import { TravelNote } from 'type';
import { Constants } from 'constant';
import { CommonBlank, TitleBar } from 'component';
import { DiscoverPageVM } from '../viewmodel/DiscoverPageVM';
import { ContentCard } from '../components/ContentCard';
import './PageDetail';

@Builder
export function DiscoveryBuilder() {
  Discovery();
}

@Component
export struct Discovery {
  vm: DiscoverPageVM = DiscoverPageVM.instance;
  private scroller: Scroller = new Scroller();
  @Consume('mainPathStack') mainPathStack: NavPathStack;

  @Builder
  buildWaterFlow() {
    if (this.vm.travelNotes.length !== 0) {
      WaterFlow({ scroller: this.scroller }) {
        LazyForEach(this.vm.list, (item: TravelNote) => {
          FlowItem() {
            ContentCard({
              data: item,
            });
          }
          .width('100%');
        }, (item: TravelNote) => JSON.stringify(item));
      }
      .cachedCount(4)
      .columnsTemplate('1fr 1fr')
      .columnsGap(16)
      .rowsGap(16)
      .width('100%')
      .height('90%')
      .layoutWeight(1)
      .backgroundColor('#F5F6FA')
      .padding({
        left: 16,
        right: 16,
        top: 12,
        bottom: 12,
      });
    } else {
      CommonBlank().height(Constants.FULL_SCREEN).backgroundColor(Color.White);
    }
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: false, title: '发现', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });
        this.buildWaterFlow();
      };
    }.hideTitleBar(true);
  }
}
