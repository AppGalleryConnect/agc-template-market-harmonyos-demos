import { TouristInfo } from 'types';
import { TouristVM } from '../viewmodel/TouristVM';
import { Tourists } from '../components/Tourists';
import { TitleBar } from 'components';

@Builder
export function TouristsPageBuilder() {
  TouristsPage({ isInReserve: true });
}

@ComponentV2
export struct TouristsPage {
  vm: TouristVM = TouristVM.instance;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local targetIndex: number = 0;
  @Param @Once isInReserve: boolean = false;
  @Event setSelectedTourist: (tourists: TouristInfo[]) => void;
  @Event pushSheetBuilder: (tourist?: TouristInfo) => void;

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '常用旅客', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Tourists();
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.isInReserve = context.pathInfo.param as boolean;
    });
  }
}