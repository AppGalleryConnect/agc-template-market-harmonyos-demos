import { UIContext, window } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { AddressDTO } from '../models/AddressDTO';
import { AddressFormSheet } from '../utils/AddressFormSheet';
import { AddressVM } from '../viewmodels/AddressVM';
import { AddressManagementOptions, BreakpointType } from '../common/CustomTypes';
import { SimpleDialog } from '../utils/SimpleDialog';
import { AddressController } from '../viewmodels/AddressController';

@ComponentV2
struct AddressListPage {
  controller: AddressController = new AddressController();

  @Local
  private isInitializing: boolean = true;

  @Local
  private isLoading: boolean = false;

  @Local
  private templateForWaterFlow: string = '1fr';

  @Local
  isAvoidArea: boolean = false;

  @Local
  windowTopPadding: number = 40;

  @Local
  windowBottomPadding: number = 28;

  private uiContext: UIContext = this.getUIContext();

  private navPathStack: NavPathStack | null = null;

  private onAddressSelected: Callback<AddressDTO> | undefined = undefined;

  private scroller: Scroller = new Scroller();

  private dialog: SimpleDialog = new SimpleDialog(this.uiContext);

  private sheet: AddressFormSheet = new AddressFormSheet(this.uiContext)
    .onAddressListUpdate(() => {
      this.isLoading = true;
      this.refreshData(() => this.isLoading = false);
    })
    .onWillDismiss((reason: DismissReason, hasChange: boolean): void => {
      if (reason !== DismissReason.TOUCH_OUTSIDE && reason !== DismissReason.SLIDE_DOWN) {
        if (hasChange) {
          this.uiContext.getFocusController().clearFocus();
          this.dialog
            .onConfirm(() => {
              this.dialog.close();
              this.sheet.close();
            })
            .setMessage('是否放弃编辑此地址？')
            .setConfirmButton('确定', $r('sys.color.font_emphasize'))
            .setCancelButton('取消', $r('sys.color.font_emphasize'))
            .open();
        } else {
          this.sheet.close();
        }
      }
    });

  aboutToAppear(): void {
    // 获取当前窗口实例
    try {
      const context = this.uiContext.getHostContext() as Context;
      window.getLastWindow(context).then(async (windowClass) => {
        // 判断是否为全屏布局
        const properties = windowClass.getWindowProperties();
        if (properties.isLayoutFullScreen) {
          this.isAvoidArea = true;
          this.setAvoidSize(windowClass)
        } else {
          this.isAvoidArea = false;
        }
      }).catch((err: BusinessError) => {
        UtilLog.error(`Failed to obtain the top window. Error: ${JSON.stringify(err)}`);
      });
    } catch (err) {
      UtilLog.error(`Failed to obtain the top window. Error: ${JSON.stringify(err)}`);
    }
  }

  public setAvoidSize(windowClass: window.Window) {
    try {
      const uiContext = this.getUIContext();
      let avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      this.windowTopPadding = uiContext.px2vp(avoidArea.topRect.height);
      avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      this.windowBottomPadding = uiContext.px2vp(avoidArea.bottomRect.height);
    } catch (error) {
      UtilLog.error('[FeedbackSubmitPage]', `setAvoidArea fail, error: ${JSON.stringify(error)}`);
    }
  }

  build() {
    NavDestination() {
      Column() {
        this.buildTitleBar()
        GridRow({ breakpoints: { value: [ '320vp', '600vp', '840vp' ] } })
          .onBreakpointChange((breakpoints: string) => {
            if (breakpoints === BreakpointType.XS || breakpoints === BreakpointType.SM) {
              this.templateForWaterFlow = '1fr';
            } else if (breakpoints === BreakpointType.MD) {
              this.templateForWaterFlow = '1fr '.repeat(2);
            } else {
              this.templateForWaterFlow = '1fr '.repeat(3);
            }
          })
        Stack() {
          Column() {
            if (!this.isInitializing) {
              if (this.controller.addressList.length > 0) {
                Scroll() {
                  Column() {
                    this.buildAddressWaterFlow()
                  }
                  .constraintSize({ minHeight: '100%' })
                }
                .layoutWeight(1)
                .edgeEffect(EdgeEffect.Spring)
                .scrollBar(BarState.Off)
              } else {
                Column({ space: 12 }) {
                  Image($r('app.media.ic_address_empty')).width(120).height(120)
                  Text('暂无地址，快去添加吧')
                    .fontColor($r('sys.color.font_secondary'))
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Medium)
                }
                .width('100%')
                .layoutWeight(1)
                .padding({ bottom: 64 })
                .justifyContent(FlexAlign.Center)
              }

              Row() {
                Button('添加地址')
                  .width('100%')
                  .constraintSize({ maxWidth: '480vp' })
                  .onClick(() => this.sheet.openForCreate())
              }
              .padding({ left: 16, right: 16 })
            }
          }
          if (this.isInitializing || this.isLoading) {
            Column() {
              LoadingProgress()
                .width(40)
                .height(40)
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
          }
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding(this.isAvoidArea ? {
        top: this.windowTopPadding,
        bottom: this.windowBottomPadding,
      } : null)
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.navPathStack = ctx.pathStack;
      const params = ctx.pathInfo.param as AddressManagementOptions;
      if (params) {
        this.controller = params.controller;
        this.onAddressSelected = params.onAddressSelected;
        this.sheet.setAddressController(params.controller);
      }

      this.refreshData(() => this.isInitializing = false);
    })
  }

  @Builder
  private buildAddressWaterFlow(): void {
    WaterFlow({
      scroller: this.scroller,
      layoutMode: WaterFlowLayoutMode.SLIDING_WINDOW
    }) {
      ForEach(this.controller.addressList, (address: AddressVM, index: number) => {
        FlowItem() {
          Column() {
            Column() {
              Text(address.title)
                .width('100%')
                .maxLines(1)
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ bottom: 4 })
              Text(address.fullAddress)
                .width('100%')
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_primary'))
            }
            .constraintSize({ minHeight: 64 })
            .margin({ bottom: 12 })
            Divider()
            Row() {
              Row() {
                Toggle({ type: ToggleType.Switch, isOn: address.isDefault })
                  .onChange((isOn: boolean) => {
                    if (this.isLoading) {
                      return;
                    }
                    this.isLoading = true;
                    address.isDefault = isOn;
                    // 如果当前地址为默认地址，则将其它地址改为非默认
                    let cacheId: number = 0;
                    if (isOn) {
                      this.controller.addressList.forEach((item: AddressVM) => {
                        // 缓存被改动地址的 Id
                        if (item.isDefault && item.addressId !== address.addressId) {
                          cacheId = item.addressId;
                          item.isDefault = false;
                        }
                      });
                    }
                    const isAutoTop: boolean = index !== 0 && isOn;
                    this.controller.onModifyAddress?.(address.toDTO(), true)
                      .then(() => {
                        this.refreshData(() => {
                          if (isAutoTop) {
                            this.scroller.scrollEdge(Edge.Top);
                            this.uiContext.getPromptAction().showToast({ message: '已自动为您置顶默认地址' });
                          }
                          this.isLoading = false;
                        });
                      })
                      .catch(() => {
                        this.isLoading = false;
                        if (cacheId) {
                          this.controller.addressList.forEach((item: AddressVM) => {
                            item.isDefault = item.addressId === cacheId
                          });
                        }
                      });
                  })
                  .margin({ right: 8 })
                Text('默认地址')
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Regular)
              }
              Row() {
                Button('编辑')
                  .size({ width: 72, height: 28 })
                  .type(ButtonType.ROUNDED_RECTANGLE)
                  .fontColor($r('sys.color.font_emphasize'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Medium)
                  .backgroundColor($r('sys.color.comp_background_tertiary'))
                  .margin({ right: 12 })
                  .onClick(() => this.sheet.openForEdit(address.toDTO()))
                Button('删除')
                  .size({ width: 72, height: 28 })
                  .type(ButtonType.ROUNDED_RECTANGLE)
                  .fontColor($r('sys.color.warning'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Medium)
                  .backgroundColor($r('sys.color.comp_background_tertiary'))
                  .onClick(() => {
                    this.dialog
                      .onConfirm(() => {
                        this.dialog.close();
                        if (this.isLoading) {
                          return;
                        }
                        this.isLoading = true;
                        if (this.controller.onDeleteAddress) {
                          this.controller.onDeleteAddress(address.addressId)
                            .then(() => {
                              this.refreshData(() => this.isLoading = false);
                            })
                            .catch(() => {
                              this.isLoading = false;
                            });
                        }
                      })
                      .setMessage('删除后将无法恢复，是否删除？')
                      .setConfirmButton('删除', $r('sys.color.warning'))
                      .setCancelButton('取消', $r('sys.color.font_emphasize'))
                      .open();
                  })
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ top: 12 })
          }
          .width('100%')
          .padding(12)
          .margin({ top: 12 })
          .borderRadius(16)
          .backgroundColor($r('sys.color.background_primary'))
          .alignItems(HorizontalAlign.Start)
          .onClick(() => {
            this.onAddressSelected?.(address.toDTO());
          })
        }
        .width('100%')
      }, (address: AddressVM) => JSON.stringify(address.toDTO()))
    }
    .width('100%')
    .height('100%')
    .columnsTemplate(this.templateForWaterFlow)
    .columnsGap('12vp')
    .padding({ left: 16, right: 16 })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
    .nestedScroll({
      scrollForward: NestedScrollMode.SELF_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
  }

  @Builder
  private buildTitleBar(): void {
    Row() {
      /**
       * 页面返回按钮
       */
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
          .fontWeight(FontWeight.Normal)
      }
      .width(40)
      .height(40)
      .margin({ right: 8 })
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => this.navPathStack?.pop())
      /**
       * 标题文本
       */
      Text('地址管理')
        .layoutWeight(1)
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .maxLines(1)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
  }

  private refreshData(onFinish: () => void): void {
    this.controller.loadAddress().finally(() => onFinish());
  }
}

@Builder
export function buildAddressListPage(): void {
  AddressListPage()
}
