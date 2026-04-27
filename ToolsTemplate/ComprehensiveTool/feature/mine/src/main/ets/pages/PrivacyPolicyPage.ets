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

@Builder
export function PrivacyPolicyPageBuilder() {
  PrivacyPolicyPage();
}

@ComponentV2
export struct PrivacyPolicyPage {
  build() {
    NavDestination() {
      Column() {
        Column() {
          Text('使用记录：用户使用该App网络服务或访问App平台网页时，App自动接收并记录的浏览器和计算机上的信息，包括但不限于IP地址、浏览器的类型、使用的语言、访问日期和时间、软硬件特征信息及用户需求的网页记录等数据。\n' +
            '合作数据：App通过合法途径从商业伙伴处取得的用户个人数据。\n' +
            '此外，部分信息可能不适用该隐私政策，比如用户在使用App平台提供的搜索服务时输入的关键字信息，App收集到的用户在App发布的有关信息数据（包括但不限于参与活动、成交信息及评价详情），违反法律规定或违反App规则行为及App已对用户采取的措施。')
            .lineHeight(24).padding(12).backgroundColor($r('sys.color.comp_background_list_card')).borderRadius(16);
        }.padding(16);
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .width('100%')
      .height('100%')
    }.title('隐私政策').backgroundColor($r('sys.color.background_secondary'));
  }
}