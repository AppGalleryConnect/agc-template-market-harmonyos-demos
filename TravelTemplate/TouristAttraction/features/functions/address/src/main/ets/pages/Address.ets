import { common } from '@kit.AbilityKit';
import { shippingAddress } from '@kit.AccountKit';
import { promptAction } from '@kit.ArkUI';
import { TitleBar } from 'components';
import { Constant, getCascadeInfo, getSystemAddress, Logger } from 'common';
import { AddressInfo } from 'types';
import { AddressVM } from '../viewmodel/AddressVM';

@Builder
export function AddressBuilder() {
  Address();
}

@Extend(Text)
function addressItemText() {
  .fontSize(14).opacity(0.9).width(80);
}

@Extend(TextInput)
function addressTextInput() {
  .placeholderFont({ size: 14 })
  .placeholderColor('rgba(0, 0, 0, 0.4)')
  .backgroundColor(Color.Transparent)
  .opacity(0.9);
}

@ComponentV2
export struct Address {
  vm: AddressVM = AddressVM.instance;
  @Local isEdit: boolean = true;
  @Local cloneAddressInfo: AddressInfo = new AddressInfo();
  @Local addressInfo: AddressInfo = new AddressInfo();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;

  async importSystemAddress() {
    let systemAddress: shippingAddress.AddressInfo = await getSystemAddress(getContext(this));
    if (systemAddress.userName) {
      // 映射收货地址
      this.addressInfo.detail = systemAddress.detailedAddress;
      this.addressInfo.phone = systemAddress.mobileNumber;
      this.addressInfo.name = systemAddress.userName;
      this.addressInfo.district = this.vm.mapDistrict(systemAddress);
    }
  }

  @Builder
  TextInputBuilder(itemName: string, text: string, callback: EditableTextOnChangeCallback) {
    Row() {
      Text(itemName).addressItemText();
      TextInput({ placeholder: `请填写收货人${itemName}`, text: text })
        .onChange(callback)
        .backgroundColor(Color.Transparent)
        .addressTextInput();
    }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          TitleBar({
            isShowBack: true, title: this.isEdit ? '修改收货地址' : '新建收货地址', clickEvent: () => {
              this.mainPathStack.pop();
            },
          });

          Column({ space: 12 }) {
            Column() {
              Row() {
                Text('收货人').addressItemText();
                TextInput({ placeholder: `请填写收货人姓名`, text: this.addressInfo.name })
                  .onChange((value: string) => {
                    this.cloneAddressInfo.name = value;
                  })
                  .addressTextInput();
              }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

              Divider();

              Row() {
                Text('手机号').addressItemText();
                TextInput({ placeholder: `请填写收货人手机号`, text: this.addressInfo.phone })
                  .onChange((value: string) => {
                    this.cloneAddressInfo.phone = value;
                  })
                  .addressTextInput();
              }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
            }.padding(12).width(Constant.FULL_PERCENT).backgroundColor(Color.White).borderRadius(8);

            Column() {
              Row() {
                Row() {
                  Text('所在地区').fontSize(14).opacity(0.9);
                  Image($r('app.media.chevron_down')).size({ width: 12, height: 12 });
                }.width(80).justifyContent(FlexAlign.Start).onClick(async () => {
                  this.addressInfo.district = await getCascadeInfo(this.context);
                  Logger.info('address info selected is ' + this.addressInfo.district);
                });

                Row() {
                  TextArea({ text: this.addressInfo?.district, placeholder: '请填写所在地区' })
                    .placeholderFont({ size: 14 })
                    .placeholderColor('rgba(0, 0, 0, 0.4)')
                    .backgroundColor(Color.Transparent)
                    .opacity(0.9)
                    .maxLines(2)
                    .enabled(false)
                    .textOverflow(TextOverflow.Ellipsis)
                    .width(240)
                    .onChange((value: string) => {
                      this.cloneAddressInfo.district = value;
                    });
                }.justifyContent(FlexAlign.Start);
              };

              Divider();

              Row() {
                Text('详细地址').addressItemText();
                TextInput({ placeholder: `请填写收货人详细地址`, text: this.addressInfo.detail })
                  .onChange((value: string) => {
                    this.cloneAddressInfo.detail = value;
                  })
                  .addressTextInput();
              }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
            }.padding(12).width(Constant.FULL_PERCENT).backgroundColor(Color.White).borderRadius(8);

            Row() {
              Column({ space: 2 }) {
                Text('设为默认地址').fontWeight(500);
                Text('提醒：下单时会优先使用该地址').fontSize(14).opacity(0.6);
              }.alignItems(HorizontalAlign.Start);

              Checkbox()
                .select(this.addressInfo?.type === 1)
                .selectedColor(Color.Black)
                .shape(CheckBoxShape.CIRCLE)
                .onChange((value: boolean) => {
                  // 勾选清空本地默认状态
                  if (value) {
                    this.vm.addressList = this.vm.addressList.map((item) => {
                      item.type = 0;
                      return item;
                    },
                    );
                  }
                  value ? this.cloneAddressInfo.type = 1 : this.cloneAddressInfo.type = 0;
                });
            }
            .alignItems(VerticalAlign.Center)
            .padding(12)
            .width(Constant.FULL_PERCENT)
            .justifyContent(FlexAlign.SpaceBetween)
            .backgroundColor(Color.White)
            .borderRadius(8);

            Row() {
              Image($r('app.media.import_address')).size({ width: 24, height: 24 });
              Text('导入地址').opacity(0.9);
            }.justifyContent(FlexAlign.End).width(Constant.FULL_PERCENT).onClick(() => {
              this.importSystemAddress();
            });
          }.padding({ left: 12, right: 12 });
        };

        Row() {
          Button('保存')
            .backgroundColor('#64BB5C')
            .fontSize(14)
            .fontWeight(500)
            .width(Constant.FULL_PERCENT)
            .onClick(() => {
              if (this.vm.validate(this.cloneAddressInfo)) {
                promptAction.showToast({ message: '请正确填写收货地址信息', duration: 1000 });
                return;
              }

              this.addressInfo.id = this.cloneAddressInfo.id;
              this.addressInfo.name = this.cloneAddressInfo.name;
              this.addressInfo.phone = this.cloneAddressInfo.phone;
              this.addressInfo.district = this.cloneAddressInfo.district;
              this.addressInfo.detail = this.cloneAddressInfo.detail;
              this.addressInfo.type = this.cloneAddressInfo.type;

              this.vm.editItemInfo(this.addressInfo, this.isEdit);
              this.mainPathStack.pop();
            });
        }.padding({ left: 12, right: 12 });
      }
      .backgroundColor('#F1F3F5')
      .height(Constant.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ bottom: this.windowBottomHeight });
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.addressInfo = context.pathInfo.param as AddressInfo;

      if (!this.addressInfo) {
        this.addressInfo = new AddressInfo();
        this.isEdit = false;
      } else {
        this.cloneAddressInfo.id = this.addressInfo.id;
        this.cloneAddressInfo.name = this.addressInfo.name;
        this.cloneAddressInfo.phone = this.addressInfo.phone;
        this.cloneAddressInfo.district = this.addressInfo.district;
        this.cloneAddressInfo.detail = this.addressInfo.detail;
      }
    });
  }
}