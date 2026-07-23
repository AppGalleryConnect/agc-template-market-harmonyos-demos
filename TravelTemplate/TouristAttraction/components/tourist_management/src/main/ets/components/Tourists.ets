import { Constant, TouristInfo } from 'module_base';
import { BreakpointNameEnum, GridRowColSetting } from '../constant/GridRowColSetting';
import { TouristVM } from '../viewmodel/TouristVM';
import { Tourist } from './Tourist';
import { TouristCardComponent } from './TouristCardComponent';

@ComponentV2
export struct Tourists {
  vm: TouristVM = TouristVM.instance;
  @Param @Require touristList: TouristInfo[] = [];
  @Param @Once isInReserve: boolean = false;
  @Param @Once useRoute: boolean = false;
  @Local pathStack: NavPathStack = new NavPathStack();
  @Local touristId: string = '';
  @Local showEditSheet: boolean = false;
  @Local editItem: TouristInfo = new TouristInfo();
  @Event changeSelectedStatus: (isChecked: boolean, touristId: string) => void;
  @Event setSelectedTourist: () => void;
  @Event closeSheet: () => void;
  // 新增、编辑、删除
  @Event deleteTourist: (touristId: string) => void;
  @Event addOrEditTourist: (tourist: TouristInfo, isEdit: boolean) => void;
  @Event onEditTourist: (tourist: TouristInfo, isEdit: boolean) => void;
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  @Builder
  EditAddressBuilder() {
    Tourist({
      touristInfo: this.editItem,
      isEdit: this.editItem.name.length > 0,
      pathStack: this.pathStack,
      close: () => {
        this.showEditSheet = false;
      },
      addOrEditTourist: (tourist: TouristInfo, isEdit: boolean) => {
        this.addOrEditTourist(tourist, isEdit);
      },
      deleteTourist: (touristId: string) => {
        this.deleteTourist(touristId);
      },
    });
  }

  @Builder
  ItemDelete(item: TouristInfo) {
    Row() {
      Image($r('app.media.delete_warning')).width(40).height(40);
    }.padding({ left: 16 }).onClick(() => {
      this.deleteTourist(item.id);
    });
  }

  build() {
    Column({ space: 12 }) {
      if (this.touristList.length) {
        GridRow({ columns: 12 }) {
          GridCol({ span: 12 }) {
            List({ space: 12 }) {
              if (this.isInReserve) {
                ListItem() {
                  Row({ space: 8 }) {
                    SymbolGlyph($r('sys.symbol.plus_circle'))
                      .fontSize(24)
                      .width(24)
                      .height(24)
                      .fontColor([$r('sys.color.warning')]);
                    Text('添加常用游客')
                      .fontSize($r('sys.float.Body_L'))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.warning'));
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor($r('sys.color.comp_background_primary'))
                  .borderRadius(16)
                  .padding({
                    top: 16, bottom: 16,
                  })
                  .onClick(() => {
                    this.editItem = new TouristInfo();
                    if (this.useRoute) {
                      this.onEditTourist(this.editItem, false);
                    } else {
                      this.showEditSheet = true;
                    }
                  });
                };
              }

              ForEach(this.touristList, (item: TouristInfo) => {
                ListItem() {
                  TouristCardComponent({
                    isInReserve: this.isInReserve,
                    tourist: item,
                    editTourist: () => {
                      this.editItem = item;
                      if (this.useRoute) {
                        this.onEditTourist(this.editItem, true);
                      } else {
                        this.showEditSheet = true;
                      }
                    },
                    updateCheckStatus: (value: boolean) => {
                      this.changeSelectedStatus(value, item.id);
                    },
                  });
                }.swipeAction(this.isInReserve ? {} : {
                  end: {
                    builder: () => {
                      this.ItemDelete(item);
                    },
                    onAction: () => {
                      this.getUIContext().animateTo({ duration: 1000 }, () => {
                        this.deleteTourist(item.id);
                      });
                    },
                  }, edgeEffect: SwipeEdgeEffect.Spring,
                });
              }, (item: TouristInfo) => item.id);
            }
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
            .lanes(this.isInReserve ? 1 : this.vm.getTouristLanes, 16)
            .contentStartOffset(this.isInReserve ? 0 : 12)
            .contentEndOffset(12)
            .layoutWeight(1);
          };
        }.layoutWeight(1)
        .onBreakpointChange((breakpoint: string) => {
          this.vm.setBreakpoint(breakpoint);
        });
      } else {
        Column() {
          Text('暂无游客信息').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_secondary'));
        }.width(Constant.FULL_PERCENT).layoutWeight(1).justifyContent(FlexAlign.Center);
      }

      Button(this.isInReserve ? '确定' : '添加常用游客')
        .backgroundColor($r('sys.color.multi_color_04'))
        .fontSize($r('sys.float.Body_L'))
        .width(this.vm.getAddWidth)
        .constraintSize({ maxWidth: Constant.MAX_WIDTH })
        .onClick(() => {
          if (this.isInReserve) {
            this.setSelectedTourist();
            this.closeSheet();
          } else {
            this.editItem = new TouristInfo();
            if (this.useRoute) {
              this.onEditTourist(this.editItem, false);
            } else {
              this.showEditSheet = true;
            }
          }
        });
    }
    .padding({
      left: GridRowColSetting.getPageMargin(this.vm.currentBreakpoint),
      right: GridRowColSetting.getPageMargin(this.vm.currentBreakpoint),
      bottom: this.windowBottomHeight + 8,
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .bindSheet($$this.showEditSheet, this.EditAddressBuilder(), {
      height: this.vm.getSheetHeight(this.isInReserve),
      detents: this.vm.currentBreakpoint === BreakpointNameEnum.SM ? [748, 749] : [612, 613],
      showClose: false,
      preferType: SheetType.CENTER,
      backgroundColor: $r('sys.color.comp_background_gray')
    });
  }
}