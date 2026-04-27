import { Context } from '../common/Context';
import { IColor, IFontSize, Operation } from '../common/CommonConst';
import { AddressVM } from '../viewmodel/AddressVM';
import { sceneMap } from '@kit.MapKit';
import { CommonDivider, IAddrInfo, toastUtil } from 'module_base';
import { CommonUtils } from '../common/Utils';
import { common } from '@kit.AbilityKit';

@ComponentV2
struct AddressEditPage {
  @Param
  public ctx: Context = new Context();
  @Local
  private address: AddressVM = new AddressVM();

  public aboutToAppear(): void {
    if (this.ctx.operation === Operation.EDIT && this.ctx.editingIAddrInfo) {
      this.address.assignFromDTO(this.ctx.editingIAddrInfo);
    }
  }

  onlyEdit(address: IAddrInfo) {
    this.ctx.onSelect(address)
    this.ctx.navPathStack.pop()
  }

  public build(): void {
    NavDestination() {
      Column() {
        Stack() {
          this.buildMainContent();
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .backgroundColor(IColor.BACKGROUND)
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    }
    .title(this.ctx.operation === Operation.EDIT ? '编辑地址' : '新增地址')
  }

  @Builder
  private buildMainContent(): void {
    Column() {
      Scroll() {
        Column() {
          //获取关联账号地址
          Row() {
            Row() {
              Image($r('app.media.ic_link'))
                .width(24)
                .height(24)
                .margin({ right: 8 })
              Text('获取关联账号地址')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#466DFA')
            }

            Image($r('app.media.ic_arrow_right'))
              .width(12)
              .height(24)
          }
          .width('100%')
          .height(56)
          .padding({ left: 12, right: 12 })
          .justifyContent(FlexAlign.SpaceBetween)
          .borderRadius(16)
          .backgroundColor(Color.White)
          .margin({ bottom: 12, top: 12 })
          .onClick(async () => {
            const context = this.getUIContext().getHostContext() as common.UIAbilityContext
            const address = await CommonUtils.chooseAddress(context)
            if (address) {
              this.address.name = address.name
              this.address.phone = address.phone
              this.address.countryCode = address.countryCode
              this.address.country = address.country
              this.address.province = address.province
              this.address.city = address.city
              this.address.district = address.district
              this.address.detail = address.detail
              this.address.updatedAt = address.updatedAt
              this.address.createdAt = address.createdAt
              this.address.isDefault = address.isDefault
            }
          })

          Column() {
            // 收货人 & 手机号码
            Column() {
              Row() {
                Text('姓名')
                  .width(56)
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_primary'))
                  .margin({ right: 24 })
                TextInput({ text: $$this.address.name, placeholder: '名字' })
                  .backgroundColor(Color.Transparent)
                  .layoutWeight(1)
                  .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
                  .placeholderColor($r('sys.color.font_secondary'))
                  .fontSize(12)
              }
              .width('100%')
              .height(44)
              .alignItems(VerticalAlign.Center)

              CommonDivider()

              Row() {
                Text('手机号码')
                  .width(56)
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_primary'))
                  .margin({ right: 24 })
                TextInput({ text: $$this.address.phone, placeholder: '手机号' })
                  .backgroundColor(Color.Transparent)
                  .layoutWeight(1)
                  .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
                  .placeholderColor($r('sys.color.font_secondary'))
                  .fontSize(12)
              }
              .width('100%')
              .height(44)
              .alignItems(VerticalAlign.Center)

              CommonDivider()

              Row() {
                Text('所在区域')
                  .width(56)
                  .fontSize(14)
                  .fontColor($r('sys.color.font_primary'))
                  .textAlign(TextAlign.Start)
                  .margin({ right: 24 })
                Column() {
                  if (this.address.region) {
                    Text(this.address.region)
                      .width('100%')
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .fontColor(IColor.BLACK_TRANSPARENT_90)
                      .textAlign(TextAlign.Start)
                  } else {
                    Text('省市区县、乡镇等')
                      .width('100%')
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .fontColor(IColor.BLACK_TRANSPARENT_40)
                      .textAlign(TextAlign.Start)
                  }
                }
                .padding({ left: 16 })
                .layoutWeight(1)
                .onClick(() => this.handleSelectDistrict())
              }
              .width('100%')
              .height(40)
              .alignItems(VerticalAlign.Center)

              CommonDivider()

              Row() {
                Text('详细地址')
                  .width(56)
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_primary'))
                  .textAlign(TextAlign.Start)
                  .margin({ right: 24 })
                TextArea({ text: $$this.address.detail, placeholder: '小区、写字楼、门牌号等' })
                  .backgroundColor(Color.Transparent)
                  .layoutWeight(1)
                  .placeholderFont({ size: 12, weight: FontWeight.Regular })
                  .placeholderColor($r('sys.color.font_tertiary'))
                  .fontSize(12)
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
            .padding(12)
          }
          .width('100%')
          .backgroundColor(IColor.WHITE)
          .borderRadius(16)
          .margin({ bottom: 16 })

          // 设为默认地址
          Row() {
            Text('设为默认地址')
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
            Toggle({ type: ToggleType.Switch, isOn: this.address.isDefault })
              .onChange((isOn: boolean) => {
                this.address.isDefault = isOn;
              })
          }
          .width('100%')
          .height(44)
          .padding({ left: 12, right: 12 })
          .justifyContent(FlexAlign.SpaceBetween)
          .borderRadius(16)
          .backgroundColor(Color.White)
          .margin({ bottom: 12 })
        }
        .width('100%')
        .constraintSize({ minHeight: '100%' })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

      this.buildSaveButton();
    }
    .height('100%')
  }

  @Builder
  private buildSaveButton(): void {
    Column() {
      Row() {
        Button() {
          Text('保存')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_on_primary'))
        }
        .width('80%')
        .height(40)
        .backgroundColor('#0A59F7')
        .borderRadius(21)
        .fontWeight(500)
        .type(ButtonType.Normal)
        .onClick(() => {
          if (this.verify()) {
            const address: IAddrInfo = this.address.toDTO();
            if (this.ctx.operation === Operation.CREATE) {
              this.ctx.addressMgr.create(address, () => this.ctx.navPathStack.pop())
            } else {
              if (this.ctx.isOnlyEdit) {
                this.onlyEdit(address)
              } else {
                this.ctx.addressMgr.update(address, () => this.ctx.navPathStack.pop())
              }
            }
          }
        })
      }
      .width('100%')
      .height(52)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
  }

  private handleSelectDistrict(): void {
    const options: sceneMap.DistrictSelectOptions = {
      countryCode: 'CN',
      language: 'zh',
    };
    sceneMap.selectDistrict(this.getUIContext().getHostContext(), options)
      .then((result: sceneMap.DistrictSelectResult) => {
        this.address.countryCode = '';
        this.address.country = '';
        this.address.province = '';
        this.address.city = '';
        this.address.district = '';
        this.address.street = '';
        for (let district of result.districts) {
          switch (district.adminLevel) {
            case 'COUNTRY':
              break;
            case 'ADMINISTRATIVE_AREA_LEVEL_1':
              this.address.province = district.name ?? '';
              break;
            case 'ADMINISTRATIVE_AREA_LEVEL_2':
              this.address.city = district.name ?? '';
              break;
            case 'ADMINISTRATIVE_AREA_LEVEL_3':
              this.address.district = district.name ?? '';
              break;
            case 'ADMINISTRATIVE_AREA_LEVEL_4':
              this.address.street = district.name ?? '';
              break;
          }
        }
      });
  }

  private verify(): boolean {
    if (!this.address.name) {
      toastUtil.showToast('请输入收货人姓名');
      return false;
    }
    if (!this.address.phone) {
      toastUtil.showToast('请输入手机号码');
      return false;
    }
    if (!this.address.region) {
      toastUtil.showToast('请选择所在地区');
      return false;
    }
    if (!this.address.detail) {
      toastUtil.showToast('请输入详细地址');
      return false;
    }
    if (this.address.phone.length > 11) {
      toastUtil.showToast('输入手机号码格式错误');
      return false;
    }
    return true;
  }
}

@Builder
export function buildAddressEditPage(_: string, context: Context) {
  AddressEditPage({ ctx: context })
}
