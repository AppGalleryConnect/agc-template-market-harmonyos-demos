import { DeleteConfirmDialog, TouristCardComponent } from 'components';
import { TouristInfo } from 'types';
import { TouristVM } from '../viewmodel/TouristVM';
import { Constant, Logger } from 'common';

@ComponentV2
export struct Tourists {
  vm: TouristVM = TouristVM.instance;
  @Param @Once isInReserve: boolean = false;
  @Local touristId: string = '';
  @Event setSelectedTourist: (tourists: TouristInfo[]) => void;
  @Event changeSheetContent: (isInitialPage: boolean, tourist: TouristInfo) => void;
  @Event closeSheet: () => void;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
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
    Scroll() {
      Column({ space: 12 }) {
        Row() {
          Image($r('app.media.icon_add')).size({ height: 22, width: 22 }).margin({ right: 2 });
          Text('添加常用游客').fontSize(18).fontWeight(500).fontColor('#E84026');
        }
        .width(Constant.FULL_PERCENT)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .padding({
          top: 24,
          bottom: 24,
        })
        .onClick(() => {
          this.isInReserve ? this.changeSheetContent(false, new TouristInfo()) :
          this.mainPathStack.pushPathByName('TouristPage', null);
        });

        ForEach(this.vm.touristList, (item: TouristInfo) => {
          TouristCardComponent({
            isInReserve: this.isInReserve,
            tourist: item,
            editTourist: () => {
              this.isInReserve ? this.changeSheetContent(false, item) :
              this.mainPathStack.pushPathByName('TouristPage', item);
            },
            deleteTourist: () => {
              this.touristId = item.id;
              if (this.dialogController != null) {
                this.dialogController.open();
              }
            },
            updateCheckStatus: (value: boolean) => {
              this.vm.touristList = this.vm.touristList.map((tourist) => {
                if (tourist.id === item.id) {
                  tourist.isChecked = value;
                }
                return tourist;
              });
              Logger.info('tourist info is ' + this.vm.touristList);
              this.vm.editItemInfo(item, true);
            },
          });
        }, (item: TouristInfo) => item.id);

        if (this.isInReserve) {
          Button('确定')
            .backgroundColor('#64BB5C')
            .fontSize(14)
            .width(Constant.FULL_PERCENT)
            .borderRadius(20)
            .onClick(() => {
              this.setSelectedTourist(this.vm.getCheckedTourists());
              this.closeSheet();
            });
        }
      }.padding(12);
    }.height('90%').align(Alignment.Top).backgroundColor('#F1F3F5F2').scrollBar(BarState.Off);
  }
}