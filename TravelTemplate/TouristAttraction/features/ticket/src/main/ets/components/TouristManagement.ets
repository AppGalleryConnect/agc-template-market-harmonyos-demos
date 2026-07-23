import { BreakpointNameEnum, Constant } from 'common';
import { Tourist, Tourists } from 'tourist_management';
import { TouristInfo } from 'types';
import { DeleteConfirmDialog } from 'uicomponents';
import { TicketVM } from '../viewmodel/TicketVM';

@ComponentV2
export struct TouristManagement {
  vm: TicketVM = TicketVM.instance;
  @Local isShow: boolean = false;
  @Local initialSheet: boolean = true;
  @Local isShowTourist: boolean = false;
  @Local showEditSheet: boolean = false;
  @Local editItem: TouristInfo = new TouristInfo();
  @Local pathStack: NavPathStack = new NavPathStack();
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: DeleteConfirmDialog({
      delete: () => {
        this.vm.deleteItemInfo(this.editItem.id);
      }, type: 0,
    }), customStyle: true, autoCancel: true,
  });

  aboutToAppear(): void {
    this.vm.getTourists();
  }

  aboutToDisappear(): void {
    this.vm.selectedTourists = [];
    this.vm.selectedTouristsId = [];
    this.vm.selectTouristCount = 1;
    this.vm.touristList = this.vm.touristList.map((item) => {
      item.isChecked = false;
      return item;
    });
  }

  @Builder
  TouristCard(tourist: TouristInfo, index: number) {
    Row() {
      Column() {
        Text(tourist.name).fontSize($r('sys.float.Body_L'));
        Row({ space: 4 }) {
          Text('证件号').fontColor($r('sys.color.font_secondary')).fontSize($r('sys.float.Body_M'));
          Text(tourist.cardNo)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium);
        };

        Row({ space: 4 }) {
          Text('手机号').fontColor($r('sys.color.font_secondary')).fontSize($r('sys.float.Body_M'));
          Text(tourist.phone)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium);
        };
      }.alignItems(HorizontalAlign.Start);

      Row({ space: 16 }) {
        SymbolGlyph($r('sys.symbol.square_and_pencil'))
          .fontSize(24)
          .width(24)
          .height(24)
          .fontColor([$r('sys.color.icon_tertiary')])
          .onClick(() => {
            this.editItem = tourist;
            this.showEditSheet = true;
          });
        SymbolGlyph($r('sys.symbol.xmark_circle'))
          .fontSize(24)
          .width(24)
          .height(24)
          .fontColor([$r('sys.color.icon_tertiary')])
          .onClick(() => {
            this.vm.clearSelected(tourist);
          });
      };
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(Constant.FULL_PERCENT)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .padding(12)
    .borderRadius(16);
  }

  @Builder
  AddressManagementBuilder() {
    Navigation(this.pathStack) {
      Column() {
        Row() {
          Text('选择游客')
            .fontSize($r('sys.float.Title_S'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold);

          SymbolGlyph($r('sys.symbol.xmark'))
            .width(40)
            .height(40)
            .fontSize(18)
            .fontColor([$r('sys.color.icon_primary')])
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .borderRadius(1000)
            .padding(11)
            .onClick(() => {
              this.isShowTourist = false;
            });
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({
          top: 16,
          bottom: 8,
          left: this.vm.breakPointModel.pagePadding,
          right: this.vm.breakPointModel.pagePadding,
        });

        Tourists({
          touristList: this.vm.touristList,
          isInReserve: true,
          useRoute: true,
          onEditTourist: (tourist: TouristInfo, isEdit: boolean) => {
            this.editItem = tourist;
            this.pathStack.pushPath({ name: 'EditTourist' });
          },
          changeSelectedStatus: (isChecked: boolean, touristId: string) => {
            this.vm.changeSelectedStatus(isChecked, touristId);
          },
          setSelectedTourist: () => {
            this.vm.setSelectedTourist();
          },
          closeSheet: () => {
            this.isShowTourist = false;
          },
          deleteTourist: (id: string) => {
            this.vm.deleteItemInfo(id);
          },
          addOrEditTourist: (tourist: TouristInfo, isEdit: boolean) => {
            this.vm.editItemInfo(tourist, isEdit, true);
          },
        }).layoutWeight(1);
      }
      .width(Constant.FULL_PERCENT)
      .height(Constant.FULL_PERCENT);
    }
    .navDestination(this.sheetNavDest)
    .hideTitleBar(true)
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
    .height(Constant.FULL_PERCENT)
    .width(Constant.FULL_PERCENT);
  }

  @Builder
  sheetNavDest(name: string) {
    if (name === 'EditTourist') {
      Tourist({
        touristInfo: this.editItem,
        isEdit: this.editItem.name.length > 0,
        showBack: true,
        pathStack: this.pathStack,
        close: () => {
          this.pathStack.pop();
        },
        addOrEditTourist: (tourist: TouristInfo, isEdit: boolean) => {
          this.vm.editItemInfo(tourist, isEdit, true);
        },
        deleteTourist: (id: string) => {
          this.vm.deleteItemInfo(id);
        },
      });
    }
  }

  @Builder
  EditAddressBuilder() {
    Tourist({
      touristInfo: this.editItem,
      isEdit: this.editItem.name.length > 0,
      close: () => {
        this.showEditSheet = false;
      },
      addOrEditTourist: (tourist: TouristInfo, isEdit: boolean) => {
        this.vm.editItemInfo(tourist, isEdit, true);
      },
      deleteTourist: (id: string) => {
        this.vm.deleteItemInfo(id);
      },
    });
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('游客信息')
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'));
        Button('选择/添加', { controlSize: ControlSize.SMALL })
          .fontColor($r('sys.color.multi_color_04'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            // 拉起游客选择 // 无常用游客或者无常用游客待选时展示选择游客；否则展示新增游客
            if (!this.vm.touristList.length || (this.vm.touristList.length === this.vm.selectedTourists.length &&
              this.vm.touristList.length < this.vm.selectTouristCount)) {
              this.editItem = new TouristInfo();
              this.showEditSheet = true;
            } else {
              this.pathStack.clear();
              this.isShowTourist = true;
            }
          })
          .bindSheet($$this.isShowTourist, this.AddressManagementBuilder(), {
            height: this.vm.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? 748 : 612,
            detents: this.vm.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? [748, 749] : [612, 613],
            preferType: SheetType.CENTER,
            showClose: false
          });
      }
      .alignItems(VerticalAlign.Bottom)
      .justifyContent(FlexAlign.SpaceBetween)
      .width(Constant.FULL_PERCENT)
      .height(40)
      .padding({ bottom: 8 })
      .bindSheet($$this.showEditSheet, this.EditAddressBuilder(), {
        height: this.vm.getSheetHeight(true),
        detents: this.vm.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? [748, 749] : [612, 613],
        preferType: SheetType.CENTER,
        showClose: false,
        backgroundColor: $r('sys.color.comp_background_gray')
      });

      Text() {
        Span(`请选择/填写`).fontColor($r('sys.color.font_secondary'));
        Span(`${this.vm.selectTouristCount}`).fontColor($r('sys.color.warning'));
        Span(`位游客信息，已填写`).fontColor($r('sys.color.font_secondary'));
        Span(`${this.vm.selectedTourists.length}`).fontColor($r('sys.color.warning'));
        Span(`位`).fontColor($r('sys.color.font_secondary'));
      }.fontSize(14);

      Column({ space: 8 }) {
        ForEach(this.vm.selectedTourists, (item: TouristInfo, index: number) => {
          this.TouristCard(item, index);
        }, (item: TouristInfo) => item.id);
      }.visibility(this.vm.selectedTourists.length ? Visibility.Visible : Visibility.Hidden);
    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
    .padding({
      top: 16,
      bottom: 16,
      left: 12,
      right: 12,
    });
  }
}