import { BreakpointNameEnum, Constant } from 'common';
import { AddressInfo } from 'types';
import { AddressCardComponent, DeleteConfirmDialog, TitleBar } from 'uicomponents';
import { mapAddressInfoTemp } from '../mapper/Index';
import { AddressVM } from '../viewmodel/AddressVM';

@Builder
export function AddressesBuilder() {
  Addresses();
}

@Extend(Text)
function addressItemText() {
  .fontSize($r('sys.float.Subtitle_M'))
  .fontColor($r('sys.color.font_primary'))
  .fontWeight(FontWeight.Medium)
  .width(64)
  .height(48)
  .padding({
    top: 12,
    bottom: 12,
    left: 0,
    right: 0,
  });
}

@Extend(TextInput)
function addressTextInput() {
  .placeholderFont({ size: $r('sys.float.Body_L') })
  .placeholderColor($r('sys.color.font_secondary'))
  .fontSize($r('sys.float.Body_L'))
  .fontColor($r('sys.color.font_primary'))
  .showUnderline(true)
  .underlineColor({
    normal: '#00000000',
    typing: '#00000000',
    error: '#00000000',
    disable: '#00000000',
  })
  .borderWidth(0)
  .padding({ top: 12, bottom: 12, left: 12 })
  .layoutWeight(1);
}

@Extend(TextInput)
function errorTextInput(hasError: boolean) {
  .underlineColor({
    normal: hasError ? $r('sys.color.warning') : '#00000000',
    typing: hasError ? $r('sys.color.warning') : '#00000000',
    error: $r('sys.color.warning'),
    disable: '#00000000',
  });
}

@ComponentV2
export struct Addresses {
  vm: AddressVM = AddressVM.instance;
  @Local addressId: string = '';
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: DeleteConfirmDialog({
      delete: () => {
        this.vm.deleteItemInfo(this.addressId);
      }, type: 1,
    }), customStyle: true, autoCancel: true,
  });
  @Local isFromReserve: boolean = false;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;

  aboutToAppear(): void {
    this.vm.getAddressList();
  }

  @Builder
  AddressesSheet() {
    Column() {
      Column() {
        Column({ space: 12 }) {
          Column() {
            Row() {
              Text('姓名').addressItemText();
              TextInput({ placeholder: `请输入`, text: $$this.vm.cloneAddressInfo.name })
                .addressTextInput()
                .layoutWeight(1)
                .errorTextInput(this.vm.nameError)
                .onChange(() => {
                  this.vm.nameError = false;
                });
            }.width(Constant.FULL_PERCENT);

            Divider();

            Row() {
              Text('手机号码').addressItemText();
              TextInput({ placeholder: `请输入11位手机号码`, text: $$this.vm.cloneAddressInfo.phone })
                .addressTextInput()
                .layoutWeight(1)
                .errorTextInput(this.vm.phoneError)
                .onChange(() => {
                  this.vm.phoneError = false;
                });
            }.width(Constant.FULL_PERCENT);

            Divider();
            Row() {
              Text('选择地区').addressItemText();

              Row() {
                TextInput({ placeholder: `省、市、区`, text: $$this.vm.cloneAddressInfo.district })
                  .addressTextInput()
                  .layoutWeight(1)
                  .maxLines(1)
                  .textOverflow(TextOverflow.Ellipsis)
                  .layoutWeight(1)
                  .errorTextInput(this.vm.districtError)
                  .onChange(() => {
                    this.vm.districtError = false;
                  })
                  .onClick(() => {
                    this.vm.handleSelectDistrict(this.getUIContext());
                  });
                Button() {
                  SymbolGlyph($r('sys.symbol.local')).fontSize(24).fontColor([$r('sys.color.icon_primary')]);
                }
                .width(26)
                .height(26)
                .margin({ left: 8 })
                .backgroundColor(Color.Transparent)
                .onClick(() => {
                  this.vm.selectLocation(this.getUIContext());
                });
              }.justifyContent(FlexAlign.Start).layoutWeight(1);
            };

            Divider();

            Row() {
              Text('详细地址').addressItemText();
              TextInput({ placeholder: `街道、门牌号、小区楼栋号等`, text: $$this.vm.cloneAddressInfo.detail })
                .addressTextInput()
                .layoutWeight(1)
                .maxLength(100)
                .errorTextInput(this.vm.detailError)
                .onChange(() => {
                  this.vm.detailError = false;
                });
            }.width(Constant.FULL_PERCENT);
          }
          .padding(12)
          .width(Constant.FULL_PERCENT)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius(16);

          Row() {
            Column({ space: 2 }) {
              Text('设为默认地址').fontWeight(500);
            }.alignItems(HorizontalAlign.Start);

            Toggle({ type: ToggleType.Switch, isOn: this.vm.cloneAddressInfo.type === 1 })
              .selectedColor($r('sys.color.multi_color_04'))
              .switchPointColor($r('sys.color.comp_background_primary_contrary'))
              .onChange((isOn: boolean) => {
                isOn ? this.vm.cloneAddressInfo.type = 1 : this.vm.cloneAddressInfo.type = 0;
              });
          }
          .padding(12)
          .width(Constant.FULL_PERCENT)
          .justifyContent(FlexAlign.SpaceBetween)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius(16);

        };
      };

      Column({ space: 12 }) {
        Row({ space: 16 }) {
          if (this.vm.isEdit) {
            Button('取消')
              .layoutWeight(1)
              .fontColor($r('sys.color.multi_color_04'))
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .onClick(() => {
                this.vm.showAddressSheet = false;
              });
          }
          Button('保存')
            .backgroundColor($r('sys.color.multi_color_04'))
            .fontColor($r('sys.color.font_on_primary'))
            .layoutWeight(1)
            .onClick(() => {
              if (this.vm.validate(this.vm.cloneAddressInfo)) {
                this.getUIContext().getPromptAction().showToast({ message: '请正确填写收货地址信息', duration: 1000 });
                return;
              }

              this.vm.addressInfo.id = this.vm.cloneAddressInfo.id;
              this.vm.addressInfo.name = this.vm.cloneAddressInfo.name;
              this.vm.addressInfo.phone = this.vm.cloneAddressInfo.phone;
              this.vm.addressInfo.district = this.vm.cloneAddressInfo.district;
              this.vm.addressInfo.detail = this.vm.cloneAddressInfo.detail;
              this.vm.addressInfo.type = this.vm.cloneAddressInfo.type;

              this.vm.editItemInfo(this.vm.addressInfo, this.vm.isEdit);
              this.vm.showAddressSheet = false;
            });
        };

        if (!this.vm.isEdit) {
          Button('从华为账号导入')
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .fontColor($r('sys.color.multi_color_04'))
            .width(Constant.FULL_PERCENT)
            .onClick(() => {
              this.vm.importSystemAddress(this.getUIContext());
            });
        }
      }.padding({ bottom: 12 });
    }
    .height(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16, bottom: this.windowBottomHeight });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: this.isFromReserve ? '新增/选择收货地址' : '我的地址', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        if (this.vm.addressList.length > 0) {
          List({ space: 12 }) {
            ForEach(this.vm.addressList, (item: AddressInfo) => {
              ListItem() {
                AddressCardComponent({
                  address: item, editAddress: () => {
                    this.vm.isEdit = true;
                    this.vm.cloneAddressInfo = mapAddressInfoTemp(item);
                    this.vm.showAddressSheet = true;
                  }, deleteAddress: () => {
                    this.addressId = item.id;
                    if (this.dialogController != null) {
                      this.dialogController.open();
                    }
                  },
                });
              }.onClick(() => {
                if (this.isFromReserve) {
                  this.mainPathStack.popToName('CommodityReserve', item);
                }
              });
            }, (item: AddressInfo) => JSON.stringify(item));
          }
          .alignListItem(ListItemAlign.Start)
          .scrollBar(BarState.Off)
          .padding({ left: this.vm.breakPointModel.pagePadding, right: this.vm.breakPointModel.pagePadding })
          .contentStartOffset(8)
          .contentEndOffset(8)
          .lanes(this.vm.getFunctionLane(), 16)
          .layoutWeight(1);
        } else {
          Text('暂无地址信息')
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular);
        }

        Row() {
          Button('新增地址')
            .width(Constant.FULL_PERCENT)
            .constraintSize({ maxWidth: Constant.MAX_WIDTH })
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('sys.color.multi_color_04'))
            .onClick(() => {
              this.vm.isEdit = false;
              this.vm.cloneAddressInfo = new AddressInfo();
              this.vm.showAddressSheet = true;
            })
            .bindSheet($$this.vm.showAddressSheet, this.AddressesSheet(), {
              height: this.vm.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? 748 : 612,
              title: { title: this.vm.isEdit ? '编辑地址' : '新增地址' },
              preferType: SheetType.CENTER,
              backgroundColor: $r('sys.color.comp_background_gray')
            });
        }.padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 8,
        }).height(56);
      }
      .height(Constant.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({ bottom: this.windowBottomHeight });
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.isFromReserve = context.pathInfo.param as boolean;
    });
  }
}