import { call } from '@kit.TelephonyKit';
import { baseActionSheet } from 'base_common';
import {
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  Constants,
  FontModel,
  MinorsMode,
  MinorsProtectionUtils,
  TCRouter
} from 'common'
import { AppStorageV2 } from '@kit.ArkUI';
import { DialPanel } from 'dial_panel';
import { BusinessError } from '@kit.BasicServicesKit';
import { fp2pxUtil } from 'base_common';

@ComponentV2
export struct ServiceCard {
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint;
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;
  private uiContext: UIContext = this.getUIContext();
  @Local minorsMode: MinorsMode =
    AppStorageV2.connect(MinorsMode, 'isMinorsMode', () => new MinorsMode(MinorsProtectionUtils.getMinorsMode()))!

  private showToast(msg: string): void {
    this.uiContext.getPromptAction().showToast({ message: msg });
  }

  private dialPanel: DialPanel = new DialPanel(this.uiContext)
    .onMakeCall((e: BusinessError<void>): void => {
      if (e.code) {
        this.showToast(`拨号页面跳转失败 -> code: ${e.code}, msg: ${e.message}`);
      }
    })
    .onWillDismiss((reason: DismissReason): void => {
      if (reason === DismissReason.TOUCH_OUTSIDE) {
        this.showToast('已拦截点击其它区域进行关闭的交互方式');
      } else if (reason === DismissReason.SLIDE_DOWN) {
        this.showToast('已拦截下拉模态窗进行关闭的交互方式');
      } else {
        this.dialPanel.close();
      }
    });

  build() {
    Column() {
      Row() {
        Text('常用服务')
          .height(24)
          .width(72)
          .fontSize(this.fontModel.getFg(18))
          .fontWeight(500)
          .width(Constants.FULL_SIZE)
          .textAlign(TextAlign.Start)
      }
      .padding({ bottom: 12 })
      .width(Constants.FULL_SIZE)

      Column({ space: 8 }) {
        if (this.curBreakpoint.value === BreakpointTypeEnum.SM) {
          List() {
            ListItem() {
              this.serviceButtonView('app.media.ic_reading_history', 'app.string.reading_history', true, () => {
                TCRouter.pushByLogin(Constants.READ_HISTORY_ROUTE);
              })
            }

            ListItem() {
              this.serviceButtonView('app.media.ic_arrow_down_circle', 'app.string.my_download', true, () => {
                TCRouter.pushByLogin(Constants.MY_DOWNLOAD_ROUTE);
              })
            }

            if (!this.minorsMode.isMinorsMode) {
              ListItem() {
                this.serviceButtonView('app.media.ic_public_office_brush', 'app.string.my_evaluation', true, () => {
                  TCRouter.pushByLogin(Constants.MY_EVALUATION_ROUTE);
                })
              }

              ListItem() {
                this.serviceButtonView('app.media.ic_reading_preference', 'app.string.reading_preference', true, () => {
                  TCRouter.pushByLogin(Constants.PREFERENCE_ROUTE);
                })
              }
            }
          }
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .borderRadius(16)
          .divider({
            strokeWidth: 0.5,
            color: $r('sys.color.comp_divider'),
            startMargin: 48,
            endMargin: 12
          })
          .padding({ top: 4, bottom: 4 })

          List() {
            if (!this.minorsMode.isMinorsMode) {
              ListItem() {
                this.serviceButtonView('app.media.ic_contact', 'app.string.contact', true, () => {
                  baseActionSheet.show({
                    id: 'PhoneSheetBuilder',
                    title: { title: '联系客服' },
                    height: SheetSize.FIT_CONTENT,
                    preferType: SheetType.CENTER,
                    backgroundColor: $r('sys.color.background_secondary'),
                    customContent: () => {
                      this.PhoneSheetBuilder()
                    },
                  })
                })
              }
            }

            ListItem() {
              this.serviceButtonView('app.media.ic_issue_and_feedback', 'app.string.issue_and_feedback', true, () => {
                TCRouter.push(Constants.ISSUE_AND_FEEDBACK_ROUTE);
              })
            }
          }
          .width('100%')
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .borderRadius(16)
          .divider({
            strokeWidth: 0.5,
            color: $r('sys.color.comp_divider'),
            startMargin: 48,
            endMargin: 12
          })
          .padding({ top: 4, bottom: 4 })
        } else {
          Grid() {
            GridItem() {
              this.serviceButtonView('app.media.ic_reading_history', 'app.string.reading_history', true, () => {
                TCRouter.pushByLogin(Constants.READ_HISTORY_ROUTE);
              })
            }

            GridItem() {
              this.serviceButtonView('app.media.ic_arrow_down_circle', 'app.string.my_download', true, () => {
                TCRouter.pushByLogin(Constants.MY_DOWNLOAD_ROUTE);
              })
            }

            if (!this.minorsMode.isMinorsMode) {
              GridItem() {
                this.serviceButtonView('app.media.ic_public_office_brush', 'app.string.my_evaluation', true, () => {
                  TCRouter.pushByLogin(Constants.MY_EVALUATION_ROUTE);
                })
              }

              GridItem() {
                this.serviceButtonView('app.media.ic_reading_preference', 'app.string.reading_preference', true, () => {
                  TCRouter.pushByLogin(Constants.PREFERENCE_ROUTE);
                })
              }
            }
          }
          .columnsTemplate('1fr 1fr')
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .borderRadius(16)

          Row() {
            if (!this.minorsMode.isMinorsMode) {
              this.serviceButtonView('app.media.ic_contact', 'app.string.contact', false, () => {
                baseActionSheet.show({
                  id: 'PhoneSheetBuilder',
                  title: { title: '联系客服' },
                  height: SheetSize.FIT_CONTENT,
                  preferType: SheetType.CENTER,
                  backgroundColor: $r('sys.color.background_secondary'),
                  customContent: () => {
                    this.PhoneSheetBuilder()
                  },
                })
              })
            }

            this.serviceButtonView('app.media.ic_issue_and_feedback', 'app.string.issue_and_feedback', false, () => {
              TCRouter.push(Constants.ISSUE_AND_FEEDBACK_ROUTE);
            })
          }
          .width('100%')
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .borderRadius(16)
        }
      }
    }
  }

  @Builder
  serviceButtonView(iconUrl: string, serviceText: string, isSM: boolean, onCall?: () => void) {
    Row() {
      Row() {
        Image($r(iconUrl))
          .height(24)
          .width(24)
          .fillColor([$r('sys.color.icon_primary')])
          .objectFit(ImageFit.Contain)
          .margin({
            right: 12
          })

        Text($r(serviceText))
          .fontColor($r('sys.color.font_primary'))
          .fontSize(this.fontModel.getFg(16))
      }

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(fp2pxUtil(24))
        .fontColor([$r('sys.color.icon_fourth')])
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .layoutWeight(isSM ? 0 : 1)
    .height(56)
    .width(isSM ? Constants.FULL_SIZE : 'auto')
    .padding({
      left: 12,
      right: 12
    })
    .onClick(() => {
      onCall?.()
    })
  }

  @Builder
  PhoneSheetBuilder() {
    Column() {
      Column() {
        Row() {
          Row() {
            SymbolGlyph($r('sys.symbol.phone'))
              .fontSize(24)
              .fontColor([$r('sys.color.icon_secondary')])
          }
          .borderRadius(24)
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('sys.color.comp_background_tertiary'))

          Text('电话客服')
            .fontSize(16)
            .fontWeight(500)
            .margin({ left: 16 })
          Blank()
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_fourth')])
        }
        .width('100%')
        .onClick(() => {
          this.dialPanel
            .setTitle('联系客服')
            .setPhoneNumber('12345678901')
            .setAutoClosePanel(false) // 成功跳转后不自动关闭模态窗
            .open();
        })

        Divider()
          .margin({ top: 10, bottom: 10, left: 64 })

        Row() {
          Row() {
            SymbolGlyph($r('sys.symbol.service_message_fill'))
              .fontSize(24)
              .fontColor([$r('sys.color.icon_secondary')])
          }
          .borderRadius(24)
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('sys.color.comp_background_tertiary'))

          Text('在线客服')
            .fontSize(16)
            .fontWeight(500)
            .margin({ left: 16 })
          Blank()
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_fourth')])
        }
        .width('100%')
        .onClick(() => {
          baseActionSheet.close('PhoneSheetBuilder')
          TCRouter.push(Constants.CUSTOMER_SERVICE_CHAT_ROUTER)
        })
      }
      .width(328)
      .height(140)
      .borderRadius(20)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .padding(12)
      .margin({ bottom: 41 })
    }
  }
}