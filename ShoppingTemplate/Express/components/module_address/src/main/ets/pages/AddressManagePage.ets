import { Context } from '../common/Context';
import { IColor, IStyle, Operation, ViewModelState } from '../common/CommonConst';
import { CommonDivider, RouterMap, IAddrInfo } from 'module_base'
import { AddressVM } from '../viewmodel/AddressVM';
import { ComponentContent } from '@kit.ArkUI';

@ComponentV2
struct AddressManagePage {
  @Param
  public ctx: Context = new Context();

  public aboutToAppear(): void {
    this.ctx.addressMgr.initialize();
  }

  public build(): void {
    NavDestination() {
      Column() {
        Stack() {
          if (this.ctx.addressMgr.state === ViewModelState.READY) {
            this.buildMainContent();
          }
        }
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .backgroundColor(IColor.BACKGROUND)
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    }
    .title('地址簿')
  }

  @Builder
  private buildMainContent(): void {
    Column() {
      Column() {
        this.buildCreateAddressButton()
        if (this.ctx.addressMgr.list.length > 0) {
          List({ space: IStyle.CARD_GAP }) {
            ForEach(this.ctx.addressMgr.list, (address: AddressVM) => {
              ListItem() {
                this.buildAddressCard(address);
              }
            }, (item: AddressVM) => JSON.stringify(item))
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
          .contentStartOffset(IStyle.CARD_GAP)
          .contentEndOffset(IStyle.CARD_GAP)
          .padding({ left: 16, right: 16 })
        } else {
          Text('您还没有添加收货地址')
            .fontSize(14)
            .fontColor(IColor.BLACK_TRANSPARENT_60)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .height('100%')
  }

  @Builder
  private buildAddressCard(address: AddressVM): void {
    Column() {
      Column() {
        Text(address.title)
          .width('100%')
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
        Text(address.fullAddress)
          .width('100%')
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 5 })
      }

      CommonDivider()

      Row() {
        Row() {
          Toggle({ type: ToggleType.Switch, isOn: address.isDefault })
            .margin({ right: 12 })
            .onChange((value) => {
              address.isDefault = value
              this.ctx.addressMgr.updateDefaultAddress(address, address.id, address.isDefault)
            })
          Text(address.isDefault ? '已默认' : '设为默认')
            .fontColor(IColor.BLACK_TRANSPARENT_60)
            .fontSize(12)
        }
        .responseRegion([
          {
            x: 0,
            y: '-50%',
            width: '100%',
            height: '200%',
          },
          {
            x: -16,
            y: '-50%',
            width: 16,
            height: '200%',
          },
        ])
        .onClick(() => {
          const dto: IAddrInfo = address.toDTO();
          dto.isDefault = !dto.isDefault;
          this.ctx.addressMgr.update(dto);
        })

        Row() {
          Button('修改')
            .width(72)
            .controlSize(ControlSize.SMALL)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .fontColor($r('sys.color.font_primary'))
            .onClick(() => {
              this.ctx.editingIAddrInfo = address.toDTO();
              this.ctx.operation = Operation.EDIT;
              this.ctx.navPathStack.pushPathByName(RouterMap.ADDRESS_EDIT_PAGE, this.ctx);
            })

          Button('删除')
            .width(72)
            .controlSize(ControlSize.SMALL)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .fontColor($r('sys.color.font_primary'))
            .margin({ left: 8 })
            .onClick(() => {
              const uiContext = this.getUIContext();
              const promptAction = uiContext.getPromptAction();
              const params: ParamsForDeleteDialog = new ParamsForDeleteDialog();
              const contentNode = new ComponentContent(uiContext, wrapBuilder(buildDeleteDialog), params);
              params.onClose = () => promptAction.closeCustomDialog(contentNode);
              params.onDelete = () => this.ctx.addressMgr.delete(address.id);
              promptAction.openCustomDialog(contentNode);
            })
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(110)
    .borderRadius(8)
    .backgroundColor(IColor.WHITE)
    .padding(16)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      if (this.ctx.isSelectMode) {
        this.ctx.onSelect(address.toDTO());
        this.ctx.navPathStack.pop();
      }
    })
  }

  @Builder
  private buildCreateAddressButton(): void {
    Column() {
      Row() {
        Image($r('app.media.ic_add'))
          .width(24)
          .height(24)
          .margin({ right: 8 })
        Text('添加地址')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#466DFA')
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
    }
    .borderRadius(16)
    .backgroundColor(IColor.WHITE)
    .margin({
      top: 12,
      left: 16,
      right: 16,
    })
    .onClick(() => {
      this.ctx.editingIAddrInfo = null;
      this.ctx.operation = Operation.CREATE;
      this.ctx.navPathStack.pushPathByName(RouterMap.ADDRESS_EDIT_PAGE, this.ctx);
    })
  }
}

@Builder
export function buildAddressManagePage(_: string, context: Context) {
  AddressManagePage({ ctx: context })
}

class ParamsForDeleteDialog {
  public onClose = () => {
  };
  public onDelete = () => {
  };
}

@Builder
function buildDeleteDialog(params: ParamsForDeleteDialog): void {
  Column() {
    Text('确定要删除地址吗？')
      .fontSize(16)
      .fontColor(IColor.BLACK_TRANSPARENT_90)
      .fontWeight(600)
      .margin({ bottom: 8 })
    Row() {
      Button('取消')
        .width('50%')
        .height(40)
        .fontWeight(500)
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .fontColor($r('sys.color.font_tertiary'))
        .onClick(() => params.onClose())

      Button('删除')
        .width('50%')
        .height(40)
        .fontWeight(500)
        .fontColor($r('sys.color.warning'))
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          params.onClose();
          params.onDelete();
        })
    }
    .width('100%')
  }
  .width('90%')
  .padding(16)
  .justifyContent(FlexAlign.Start)
  .backgroundColor(Color.White)
  .borderRadius(24)
}