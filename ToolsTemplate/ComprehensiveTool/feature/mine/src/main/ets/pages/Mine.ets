/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { CircleShape } from '@kit.ArkUI';
import { FeedbackTrigger } from 'feedback';
import { SettingModule } from '../model/Index';
import { MineVM } from '../viewmodel/MineVM';
import { SETTING_TYPE_MODULES } from '../constant/Index';
import { SettingType } from '../constant/Enum';

@Builder
export function MineBuilder() {
  Mine();
}

@ComponentV2
export struct Mine {
  @Param pathStack: NavPathStack = new NavPathStack();
  vm: MineVM = MineVM.instance;

  @Styles
  normalStyles() {
    .backgroundColor($r('sys.color.comp_background_primary'));
  }

  @Styles
  pressedStyles(): void {
    .backgroundColor($r('sys.color.interactive_pressed'));
  }

  @Builder
  Profile() {
    if (!this.vm.userInfoModel.isLogin) {
      Row({ space: 16 }) {
        Image($r('app.media.blank_profile')).size({ width: 48, height: 48 });

        Text('点击登录').fontSize(18).fontWeight(FontWeight.Medium);
      }
      .padding(12)
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius(16)
      .width('100%')
      .margin({ top: 18 })
      .justifyContent(FlexAlign.Start)
      .onClick(() => {
        this.vm.pathStack.pushPathByName('LoginPage', null);
      });
    } else {
      Column() {
        Row({ space: 16 }) {
          Image(this.vm.userInfoModel.userIcon)
            .width(48)
            .clipShape(new CircleShape({ width: 48, height: 48 }))
            .draggable(false);
          Column({ space: 2 }) {
            Text(this.vm.userInfoModel.userNickName)
              .fontSize(18)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium);
            Row({ space: 4 }) {
              Image($r('app.media.ic_phone'))
                .width(16)
                .draggable(false)
                .fillColor($r('sys.color.icon_secondary'));
              Text(this.vm.userInfoModel.userPhone)
                .fontSize(12)
                .fontColor($r('sys.color.font_secondary'));
            };
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);

          Image($r('app.media.chevron_right'))
            .width(12)
            .draggable(false);
        }
        .stateStyles({
          normal: this.normalStyles,
          pressed: this.pressedStyles,
        })
        .onClick(() => {
          this.vm.pathStack.pushPathByName('ProfilePage', null);
        });

        Divider().vertical(false).margin({ top: 12, bottom: 12 });

        Row() {
          Text('开通会员后享受更多权益').fontSize(14);
          Button('会员中心')
            .size({ width: 72, height: 28 })
            .fontColor($r('sys.color.font_primary'))
            .backgroundColor('#D3B685')
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.vm.pathStack.pushPathByName('MemberShipSubscribe', null);
            });
        }.width('100%').justifyContent(FlexAlign.SpaceBetween);
      }.backgroundColor($r('sys.color.background_primary')).borderRadius(16).padding(12).margin({ top: 18 });
    }
  }

  build() {
    NavDestination() {
      Column() {
        Text('我的')
          .fontSize(26)
          .width('100%')
          .textAlign(TextAlign.Start)
          .fontColor($r('sys.color.black'))
          .fontWeight(FontWeight.Bold);

        this.Profile();

        Text('常用服务')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 12, top: 12, bottom: 12 });

        Column() {
          ForEach(this.vm.userInfoModel.isLogin ? SETTING_TYPE_MODULES :
            SETTING_TYPE_MODULES.slice(0, SETTING_TYPE_MODULES.length - 1), (item: SettingModule, index: number) => {
            if (index === SettingType.FEEDBACK) {
              FeedbackTrigger() {
                Row() {
                  Row({ space: 12 }) {
                    Image(item.icon).size({ width: 24, height: 24 });
                    Text(item.title).fontWeight(FontWeight.Medium);
                  };

                  Image($r('app.media.chevron_right')).size({ width: 12, height: 24 });
                }.height(56).width('100%').justifyContent(FlexAlign.SpaceBetween);
              };
            } else {
              Row() {
                Row({ space: 12 }) {
                  Image(item.icon).size({ width: 24, height: 24 });
                  Text(item.title).fontWeight(FontWeight.Medium);
                };

                Image($r('app.media.chevron_right')).size({ width: 12, height: 24 });
              }.height(56).width('100%').justifyContent(FlexAlign.SpaceBetween).onClick(() => {
                this.vm.pathStack.pushPathByName(item.url, null);
              });
            }
          }, (item: SettingModule) => JSON.stringify(item));
        }.backgroundColor($r('sys.color.white')).borderRadius(8).padding(12);
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
    }.expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]).onReady(() => {
      this.vm.pathStack = this.pathStack;
    });
  }
}