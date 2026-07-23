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

import { UtilLog } from '@hw-agconnect/util-log';
import { common } from '@kit.AbilityKit';
import { PreferenceUtil, PreferConstant, RouterMap, RouterModule } from 'commonlib';

// 隐私协议
@ComponentV2
export struct PrivacyAgreementPage {
  private permissionList: string[] = ['XX', 'XX'];
  @Local information: string = 'XX';
  @Local service: string = 'XX';
  @Local business: string = 'XX业务与隐私声明';

  build() {
    Column() {
      Image($r('app.media.exam_icon_login'))
        .width(72)
        .height(72)
        .margin({ bottom: 24, top: 136 });
      Text('备考')
        .fontSize($r('sys.float.Title_L'))
        .height(40)
        .fontWeight(FontWeight.Medium);
      Text('业务描述')
        .fontSize($r('sys.float.Body_M'))
        .height(19)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'));
      Blank()
        .layoutWeight(1);
      Image($r('app.media.ic_pre_exam'))
        .height(18)
        .margin({ bottom: 17 });
      Text() {
        Span('本应用需');
        Span('联网')
          .fontColor($r('sys.color.font_primary'));
        Span('，调用');
        ForEach(this.permissionList, (item: string, index) => {
          Span(item)
            .fontColor($r('sys.color.font_primary'));
          if (index !== this.permissionList.length - 1) {
            Span('、');
          }
        }
          , (item: string, index: number) => item + index);
        Span('获取' + `${this.information}` + '信息，以为您提供+' + `${this.service}` +
          '服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅');
        Span(this.business)
          .onClick(() => {
            RouterModule.push({ url: RouterMap.PRIVACY_STATEMENT_PAGE });
          })
          .fontColor('#4B5CC4');
        Span('、');
        Span('权限使用说明')
          .onClick(() => {
            RouterModule.push({ url: RouterMap.PRIVACY_STATEMENT_PAGE });
          })
          .fontColor('#4B5CC4');
      }
      .lineHeight(13)
      .fontSize($r('sys.float.Caption_M'))
      .fontColor($r('sys.color.font_secondary'));

      Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_secondary'))
        .margin({ top: 6, bottom: 17 });
      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_emphasize'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            RouterModule.push({
              url: RouterMap.PRIVACY_USE_PAGE, onPop: () => {
                RouterModule.replace({ url: RouterMap.MAIN_PAGE });
              }
            });
          });
        Button('同意')
          .layoutWeight(1)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('#4B5CC4')
          .onClick(() => {
            PreferenceUtil.getInstance().put(PreferConstant.FIRST_LAUNCH, false);
            RouterModule.replace({ url: RouterMap.MAIN_PAGE });
          });
      }
      .width('100%');
    }
    .width('100%')
    .height('100%')
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), bottom: $r('app.float.vp_16') })
    .justifyContent(FlexAlign.Start);
  }
}

@ComponentV2
export struct PrivacyUseAlert {
  @Local information: string = 'XX';
  @Local service: string = 'XX';
  @Local business: string = 'XX业务与隐私声明';
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.mask_fourth'))
      .opacity(0.4)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);

      Column() {
        Text('您需要同意协议才能体验备考')
          .lineHeight(27)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
          .margin({
            left: 24,
            right: 24,
            top: 15,
            bottom: 15
          });
        Column() {
          Text() {
            Span('本应用需');
            Span('联网')
              .fontColor($r('sys.color.font_primary'));
            Span('，调用');
            Span('XX')
              .fontColor($r('sys.color.font_primary'));
            Span('、');
            Span('XX')
              .fontColor($r('sys.color.font_primary'));
            Span('获取XX信息，以为您提供XX服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅');
            Span(this.business)
              .onClick(() => {
                RouterModule.push({ url: RouterMap.PRIVACY_STATEMENT_PAGE });
              })
              .fontColor('#4B5CC4');
            Span('、');
            Span('权限使用说明')
              .onClick(() => {
                RouterModule.push({ url: RouterMap.PRIVACY_STATEMENT_PAGE });
              })
              .fontColor('#4B5CC4');
          }
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_secondary'));

          Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_secondary'))
            .margin({ top: 15 });
        }.height(92).margin({ left: 24, right: 24, bottom: 24 });

        Row() {
          Button('退出应用')
            .onClick(() => {
              this.context.terminateSelf().catch((e: BusinessError<void>) => {
                UtilLog.error('terminateSelf fail, error: ' + JSON.stringify(e))
              });
            })
            .width(140)
            .height(40)
            .fontColor('#4B5CC4')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .margin({ right: 16 });
          Button('同意并继续')
            .onClick(() => {
              PreferenceUtil.getInstance().put(PreferConstant.FIRST_LAUNCH, false);
              RouterModule.pop<string>('agree');
            })
            .width(140)
            .height(40)
            .fontColor('sys.color.font_on_primary')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#4B5CC4');
        };
      }
      .justifyContent(FlexAlign.Start)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .borderRadius(20)
      .height(229)
      .width(328);
    };
  }
}

@Builder
export function PrivacyUseAlertBuilder() {
  PrivacyUseAlert();
}

@Builder
export function PrivacyAgreementBuilder() {
  PrivacyAgreementPage();
}