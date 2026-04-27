import { Tourists } from 'tourist_management';
import { TouristInfo } from 'types';
import { DeleteConfirmDialog, TitleBar } from 'uicomponents';
import { TouristVM } from '../viewmodel/TouristVM';

@Builder
export function TouristListBuilder() {
  TouristList({ isInReserve: true });
}

@ComponentV2
export struct TouristList {
  vm: TouristVM = TouristVM.instance;
  @Local touristId: string = '';
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Param @Once isInReserve: boolean = false;
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: DeleteConfirmDialog({
      delete: () => {
        this.vm.deleteItemInfo(this.touristId);
      },
      type: 0,
    }),
    customStyle: true,
    autoCancel: true,
  });

  aboutToAppear(): void {
    this.vm.getTourists();
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '常用旅客', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Tourists({
          touristList: this.vm.touristList,
          deleteTourist: (id: string) => {
            this.touristId = id;
            if (this.dialogController != null) {
              this.dialogController.open();
            }
          },
          addOrEditTourist: (tourist: TouristInfo, isEdit: boolean) => {
            this.vm.editItemInfo(tourist, isEdit);
          },
        });
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.isInReserve = context.pathInfo.param as boolean;
    });
  }
}