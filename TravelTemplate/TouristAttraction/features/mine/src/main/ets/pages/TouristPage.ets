import { TitleBar } from 'uicomponents';
import { TouristInfo } from 'types';
import { TouristVM } from '../viewmodel/TouristVM';
import { Tourist } from 'tourist_management';

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

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: this.isEdit ? '编辑常用旅客' : '添加常用旅客', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Tourist({
          touristInfo: this.touristInfo,
          isEdit: this.isEdit,
          addOrEditTourist: (tourist: TouristInfo, isEdit: boolean) => {
            this.vm.editItemInfo(tourist, isEdit);
          },
        });
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