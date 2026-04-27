import { AppStorageV2, ComponentContent } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import {
  BreakpointModel,
  Constants, GlobalContext, HMPromptAction, RouterMap, TCLogger } from 'common';
import { phoneRouterControl } from 'oh_router';
import { PairedDeviceModel } from '../viewmodel/ScannedDevice';
import { DeviceModel } from '../viewmodel/DeviceModel';
import { PairHelpPageBuilder } from '../views/PairHelpPage';

const TAG: string = 'HMConnectDialog';

/**
 * 设备链接成功或者失败弹框
 */
export class HMConnectDialog {
  private constructor() {
  }

  static ShowConnectPopup(pairedDeviceVM: PairedDeviceModel) {
    try {
      if (HMPromptAction.contentNode === undefined) {
        let uiContext = GlobalContext.getUIContext();
        if (uiContext) {
          let contentNode = new ComponentContent(uiContext, wrapBuilder(buildConnectPopup), pairedDeviceVM);
          HMPromptAction.uiContext = uiContext;
          HMPromptAction.contentNode = contentNode;
          HMPromptAction.options = {
            alignment: DialogAlignment.Center,
            autoCancel: true,
            onWillDismiss: (_reason: DismissDialogAction) => {
              HMPromptAction.closeDialog();
              if (pairedDeviceVM.pairState === 2) {
                HMConnectDialog.CloseConnectPopup();
                emitter.emit(Constants.onPairDeviceChange);
                emitter.emit(Constants.onHealthDataChange);
                if (!DeviceModel.instance.currentMainPage) {
                  phoneRouterControl.popPage({
                    pageName: RouterMap.MAIN_PAGE
                  });
                }
              }
              return true;
            }
          };
          HMPromptAction.openDialog();
        } else {
          TCLogger.info(TAG, `GlobalContext uiContext is empty`);
        }
      }
    } catch (err) {
    }
  }

  static CloseConnectPopup() {
    HMPromptAction.closeDialog();
  }
}

@ComponentV2
struct popup {
  @Param @Require pairedDeviceVM: PairedDeviceModel;
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    Column() {
      Blank().height($r('app.float.vp_30'))
      Image($r('app.media.device_add'))
        .size({ width: $r('app.float.vp_140'), height: $r('app.float.vp_140') })

      Blank().height($r('app.float.vp_20'))

      Text(this.pairedDeviceVM.pairState === 2
        ? $r('app.string.device_pair_status_connect_success')
        : $r('app.string.device_pair_status_connect_fail'))
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor(Color.Black)

      Blank().height($r('app.float.vp_20'))

      if (this.pairedDeviceVM.pairState === 2) {
        Row() {
          SymbolGlyph($r('sys.symbol.battery_90percent'))
            .size({ width: 21, height: $r('app.float.vp_10') })

          Text(this.pairedDeviceVM.battery + '%')
            .fontColor(Color.Black)
            .fontSize($r('sys.float.Body_L'))
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .height($r('app.float.vp_40'))

      } else {
        Row() {
          Button($r('app.string.device_cancel'))
            .type(ButtonType.Normal)
            .layoutWeight(1)
            .height('100%')
            .backgroundColor(Color.Transparent)
            .fontColor($r('sys.color.font_tertiary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              HMConnectDialog.CloseConnectPopup();
            })

          Blank()
            .height($r('app.float.vp_22'))
            .width('1px')
            .color($r('sys.color.comp_divider'))

          Button($r('app.string.pair_help_title'))
            .type(ButtonType.Normal)
            .layoutWeight(1)
            .height('100%')
            .backgroundColor(Color.Transparent)
            .fontColor($r('sys.color.font_emphasize'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              HMConnectDialog.CloseConnectPopup();
              phoneRouterControl.jumpPage({
                pageName: RouterMap.DEVICE_PAIR_HELP_PAGE,
                builder: wrapBuilder(PairHelpPageBuilder)
              })
            })
        }
        .width('100%')
        .height($r('app.float.vp_40'))
      }

      Blank().height($r('app.float.vp_16'))
    }
    .backgroundColor(Color.White)
    .width(this.breakpointModel.dialogWidth)
    .borderRadius($r('sys.float.corner_radius_level12'))
    .onClick(() => {
      try {
        if (this.pairedDeviceVM.pairState === 2) {
          HMConnectDialog.CloseConnectPopup();
          emitter.emit(Constants.onPairDeviceChange);
          emitter.emit(Constants.onHealthDataChange);
          if (!DeviceModel.instance.currentMainPage) {
            phoneRouterControl.popPage({
              pageName: RouterMap.MAIN_PAGE
            });
          }
        }
      } catch (err) {
      }
    })
  }
}

@Builder
function buildConnectPopup(pairedDeviceVM: PairedDeviceModel) {
  popup({ pairedDeviceVM: pairedDeviceVM })
}