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
import { emitter } from '@kit.BasicServicesKit';
import {
  HighLightGuideComponent,
  HighLightGuideBuilder,
  Controller,
  GuidePage,
  HighLightOptionsBuilder,
  HighLightShape,
  OnClickListener,
} from '@ohos/high_light_guide';
import { BaseLayout } from '../components/BaseLayout';
import { UserGuidePageVM } from '../viewmodel/UserGuidePageVM';
import { SendUtil } from '../util/Index';
import { RemoteApi } from '../http/Api';
import { getInstance } from '../components/RouteModule';
import { UtilLog } from '@hw-agconnect/util-log';


@Builder
export function UserGuidePageBuilder() {
  UserGuidePage();
}

@ComponentV2
export struct UserGuidePage {
  vm: UserGuidePageVM = UserGuidePageVM.instance;
  private builder: HighLightGuideBuilder | null = null;
  private controller: Controller | null = null;

  aboutToAppear(): void {
    this.vm.initData();
    this.vm.getProtocolList();
    this.builder = new HighLightGuideBuilder()
      .setLabel('remoteGuide')
      .alwaysShow(true)
      .addGuidePage(GuidePage.newInstance()
        .addHighLightWithOptions('switchGuideId', HighLightShape.ROUND_RECTANGLE, 2,
          1, new HighLightOptionsBuilder().setOnClickListener(this.switchClick).isFetchLocationEveryTime(true).build())
        .setEverywhereCancelable(false))
      .addGuidePage(GuidePage.newInstance()
        .addHighLightWithOptions('modeButtonId', HighLightShape.ROUND_RECTANGLE, 2,
          1, new HighLightOptionsBuilder().setOnClickListener(this.modeClick).isFetchLocationEveryTime(true).build())
        .setEverywhereCancelable(false),
      )
      .addGuidePage(GuidePage.newInstance()
        .addHighLightWithOptions('speedButtonId', HighLightShape.ROUND_RECTANGLE, 2,
          1, new HighLightOptionsBuilder().setOnClickListener(this.speedClick).isFetchLocationEveryTime(true).build())
        .setEverywhereCancelable(false),
      );
  }

  @Builder
  SheetBuilder() {
    Column() {
      Column() {
        Text('电器有反应吗？')
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'));
        Text('请根据电器实际情况选择对应操作')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: 27, bottom: 12 });

        Row({ space: 8 }) {
          Button('有反应').width('calc(50% - 4vp)').onClick(() => {
            this.vm.curentIndex++;
            if (this.vm.curentIndex <= 2) {
              this.vm.isDialogShow = false;
              this.controller?.showPage(this.vm.curentIndex);
            } else {
              this.controller?.remove();
              this.vm.isDialogShow = false;
              this.vm.myControl.addControl(this.vm.controlInfo);
              getInstance().popToName('RemotePage');
            }
          });
          Button('无反应切换数据').width('calc(50% - 4vp)').backgroundColor($r('sys.color.alert')).onClick(() => {
            if (this.vm.tryCount < this.vm.protocolList.length) {
              this.vm.controlInfo.switchStatus = false;
              this.vm.curentIndex = 0;
              this.vm.isDialogShow = false;
              this.vm.tryCount++;
              // 切换当前协议
              this.vm.controlInfo.protocol = this.vm.protocolList[this.vm.tryCount-1].id;
              this.controller?.showPage(0);
            } else {
              this.vm.isDialogShow = false;
              getInstance().popToName('RemotePage');
              this.getUIContext().getPromptAction().showToast({ message: '当前空调型号暂不支持！' });
            }
          });
        };
      }.padding(16).backgroundColor('#FFFFFF').borderRadius(32);

    }.width('100%').padding({ left: 16, right: 16 });
  }

  // 引导蒙层下面的布局
  @Builder
  BasePageBuilder() {
    BaseLayout({
      onShow: () => {
        if (this.controller) {
          this.controller.show();
        }
      },
      onStatusChange: async (data) => {
        const res = await RemoteApi.getInfrared(data);
        SendUtil.sendInfrared(res.frequency, res.pattern);
      },
    });
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          HighLightGuideComponent({
            highLightContainer: this.BasePageBuilder,
            currentHLIndicator: null,
            builder: this.builder,
            onReady: (controllerParam: Controller) => {
              this.controller = controllerParam;
            },
          })
            .width('100%')
            .height('100%');
        };

        if (this.vm.isDialogShow) {
          this.SheetBuilder();
        }
      }.expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
    }.hideBackButton(true).expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
  }

  private switchClick: OnClickListener = {
    onClick: () => {
      this.vm.isDialogShow = true;
      try {
        emitter.emit('toSwitchClick');
      } catch (e) {
        UtilLog.error(`switch click emit failed with error ${JSON.stringify(e)}`);
      }
    },
  };
  private modeClick: OnClickListener = {
    onClick: () => {
      this.vm.isDialogShow = true;
      try {
        emitter.emit('toModeClick');
      } catch (e) {
        UtilLog.error(`mode click emit failed with error ${JSON.stringify(e)}`);
      }
    },
  };
  private speedClick: OnClickListener = {
    onClick: () => {
      this.vm.isDialogShow = true;
      try {
        emitter.emit('toSpeedClick');
      } catch (e) {
        UtilLog.error(`speed click emit failed with error ${JSON.stringify(e)}`);
      }
    },
  };
}

