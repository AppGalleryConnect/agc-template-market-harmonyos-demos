/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { PromptAction } from '@kit.ArkUI';
import { NavTitle } from '../components/NavTitle';
import { getInstance, RouterMap, setPathStack } from '../util/Route';
import { PermissionUtil } from '../util/PermissionUtil';
import { RecognitionHomePageVM } from '../viewModels/RecognitionHomePageVM';
import { RecognitionType } from '../model/Index';


@Builder
export function RecognitionHomePageBuilder() {
  RecognitionHomePage();
}

@ComponentV2
export struct RecognitionHomePage {
  vm: RecognitionHomePageVM = RecognitionHomePageVM.instance;
  dialogId: number = -1;
  promptAction: PromptAction = this.getUIContext().getPromptAction();
  private uiContext: UIContext = this.getUIContext();

  @Builder
  listItem(str: string) {
    Column() {
      Row() {
        Text(str)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Medium);
        Image($r('app.media.ic_setting_right')).width(12);
      }.width('100%').justifyContent(FlexAlign.Center).height(55).justifyContent(FlexAlign.SpaceBetween);

      Divider();
    }.justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  dialogContentBuilder() {
    Column({ space: 16 }) {
      Column() {
        Row({ space: 16 }) {
          Image($r('app.media.ic_scan_text')).width(24);
          Row() {
            this.listItem('扫描为文字');
          }.layoutWeight(1).onClick(() => {
            this.vm.handleScanByType();
            this.closeDialog();
          });
        };

        Row({ space: 16 }) {
          Image($r('app.media.ic_scan_pdf')).width(24);
          Row() {
            this.listItem('扫描为pdf');
          }.layoutWeight(1).onClick(() => {
            if (canIUse('SystemCapability.AI.Component.DocScan')) {
              getInstance().pushPathByName(RouterMap.DOC_SCAN, null);
            } else {
              this.promptAction.showToast({ message: '设备不支持该功能' });
            }
            this.closeDialog();
          });
        };

      };

      Row() {
        Text('取消')
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium);
      }.width(144).height(40).justifyContent(FlexAlign.Center).onClick(() => {
        this.closeDialog();
      });
    }
    .padding({
      left: 24,
      right: 24,
      bottom: 16,
      top: 24,
    });
  }

  async openDialog() {
    this.dialogId = await this.uiContext.getPromptAction().openCustomDialog({
      builder: () => {
        this.dialogContentBuilder();
      },
      alignment: DialogAlignment.Center,
    });
  }

  closeDialog() {
    this.uiContext.getPromptAction().closeCustomDialog(this.dialogId);
  }

  aboutToAppear(): void {
    PermissionUtil.requestPermissions(['ohos.permission.CAMERA'], this.getUIContext().getHostContext() as Context);
  }

  build() {
    NavDestination() {
      NavTitle({
        title: '图文识别',
      });
      Scroll() {
        Column({ space: 16 }) {
          // 通用区域
          Column({ space: 8 }) {
            Grid() {
              GridItem() {
                this.iconBuilder($r('app.media.ic_qrcode'), '二维码扫描');
              }.commonItem()
              .onClick(() => {
                this.vm.scanCode(this.getUIContext());
              });

              GridItem() {
                this.iconBuilder($r('app.media.ic_question'), '试题扫描');
              }.commonItem()
              .onClick(() => {
                if (canIUse('SystemCapability.AI.Component.DocScan')) {
                  getInstance().pushPathByName(RouterMap.DOC_SCAN, null);
                } else {
                  this.promptAction.showToast({ message: '设备不支持该功能' });
                }
              });

              GridItem() {
                this.iconBuilder($r('app.media.ic_photo'), '拍照扫描');
              }.commonItem()
              .onClick(() => {
                this.vm.toCamera(this.getUIContext().getHostContext() as Context);
              });
            }.columnsTemplate('1fr 1fr 1fr').columnsGap(8).height(104);

            Grid() {
              GridItem() {
                this.iconBuilder($r('app.media.ic_waveform'), '印刷字扫描');
              }.commonItem()
              .onClick(() => {
                this.vm.toCamera(this.getUIContext().getHostContext() as Context);
              });

              GridItem() {
                this.iconBuilder($r('app.media.ic_hand_written'), '手写字扫描');
              }.commonItem()
              .onClick(() => {
                this.vm.toCamera(this.getUIContext().getHostContext() as Context);
              });
            }.columnsTemplate('1fr 1fr').columnsGap(8).height(104);

          }.padding({ top: 8 });

          Column({ space: 12 }) {
            Text('票据识别').commonTitleExtend();
            Grid() {
              GridItem() {
                this.iconBuilder($r('app.media.ic_bill'), '通用票据');
              }.commonItem()
              .onClick(() => {
                this.vm.curScanType = RecognitionType.DEFAULT_SCAN;
                this.openDialog();
              });

              GridItem() {
                this.iconBuilder($r('app.media.ic_print'), '机打发票');
              }.commonItem()
              .onClick(() => {
                this.vm.curScanType = RecognitionType.DEFAULT_SCAN;
                this.openDialog();
              });
            }.columnsTemplate('1fr 1fr').columnsGap(8).height(104);

          }.width('100%').alignItems(HorizontalAlign.Start);

          Column({ space: 12 }) {
            Text('证件识别').commonTitleExtend();
            Grid() {
              GridItem() {
                this.iconBuilder($r('app.media.ic_id_card'), '身份证识别');
              }.commonItem()
              .onClick(() => {
                this.vm.curScanType = RecognitionType.ID_CARD;
                this.openDialog();
              });

              GridItem() {
                this.iconBuilder($r('app.media.ic_passport'), '护照识别');
              }.commonItem()
              .onClick(() => {
                this.vm.curScanType = RecognitionType.PASSPORT;
                this.openDialog();
              });
            }.columnsTemplate('1fr 1fr').columnsGap(8).height(104);

            Grid() {
              GridItem() {
                this.iconBuilder($r('app.media.ic_permit'), '驾驶证识别');
              }.commonItem()
              .onClick(() => {
                this.vm.curScanType = RecognitionType.DRIVER_LICENSE;
                this.openDialog();
              });

              GridItem() {
                this.iconBuilder($r('app.media.ic_bank_card'), '银行卡识别');
              }.commonItem()
              .onClick(() => {
                this.vm.curScanType = RecognitionType.BANK_CARD;
                this.openDialog();
              });


              GridItem() {
                this.iconBuilder($r('app.media.ic_business_permit'), '营业执照识别');
              }.commonItem()
              .onClick(() => {
                this.vm.curScanType = RecognitionType.DEFAULT_SCAN;
                this.openDialog();
              });
            }.columnsTemplate('1fr 1fr 1fr').columnsGap(8).height(104);

          }.width('100%').alignItems(HorizontalAlign.Start);

        }.width('100%').padding({ left: 16, right: 16 }).constraintSize({ minHeight: '100%' });
      }.scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false }).layoutWeight(1);

    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
    .onReady((cxt) => {
      setPathStack(cxt.pathStack);
    });
  }

  @Builder
  iconBuilder(url: ResourceStr, text: string) {
    Column({ space: 8 }) {
      Image(url).width(48);
      Text(text)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'));
    };
  }
}


@Extend(Text)
function commonTitleExtend() {
  .fontSize($r('sys.float.Subtitle_L')).fontWeight(FontWeight.Bold).fontColor($r('sys.color.font_primary'));
}

@Extend(GridItem)
function commonItem() {
  .borderRadius(16).backgroundColor($r('sys.color.comp_background_primary')).height(104);
}
