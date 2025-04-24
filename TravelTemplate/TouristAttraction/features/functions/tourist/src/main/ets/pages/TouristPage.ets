import { TitleBar } from 'components';
import { cardTypeOptions, TouristInfo } from 'types';
import { Tourist } from '../components/Tourist';
import { TouristVM } from '../viewmodel/TouristVM';

@Builder
export function TouristPageBuilder() {
  TouristPage();
}

@ComponentV2
export struct TouristPage {
  vm: TouristVM = TouristVM.instance;
  @Local isEdit: boolean = true;
  @Local touristInfo: TouristInfo = new TouristInfo();
  @Param @Once editItemInReserve: TouristInfo = new TouristInfo();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    if (this.editItemInReserve) {
      this.touristInfo = this.editItemInReserve;
    }
  }

  @Builder
  CardTypeSelectBuilder(tourist: TouristInfo) {
    TextPicker({ range: cardTypeOptions, selected: tourist.cardType })
      .onChange((value: string | string[], index: number | number[]) => {
        tourist.cardType = (Array.isArray(index) ? index[0] : index);
      });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: this.isEdit ? '编辑常用旅客' : '添加常用旅客', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Tourist({ touristInfo: this.touristInfo, isEdit: this.isEdit });
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.touristInfo = context.pathInfo.param as TouristInfo;
      if (!this.touristInfo) {
        this.touristInfo = new TouristInfo();
        this.isEdit = false;
      }
    });
  }
}