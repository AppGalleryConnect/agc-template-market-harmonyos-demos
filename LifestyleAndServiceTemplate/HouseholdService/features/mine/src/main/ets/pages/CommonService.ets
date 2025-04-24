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

import { callPhone, CommonConstants, HomeBaseInfo, RouterMap, RouterModule } from 'utils';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';

@Builder
export function CommonServiceBuilder() {
  CommonService()
}

@ComponentV2
export struct CommonService {
  homeBaseInfo: HomeBaseInfo = AppStorageV2.connect(HomeBaseInfo, () => new HomeBaseInfo())!;

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column({ space: 10 }) {
            Text('在现代社会，随着生活节奏的加快，越来越多的人选择将家务事交给专业的家政服务公司来处理。这不仅节省时间，还能确保家居环境的整洁与卫生。选择一家靠谱的家政公司，更是对家庭健康的重要保障。')
              .fontSize(14)
            Column() {
              Text('保洁家政服务的优势').fontSize(14).fontWeight(500)
              Text(
                '个性化服务：部分品牌提供定制化服务方案，满足不同家庭的个性化需求。\u000A专业团队：所有员工均经过专业培训，持证上岗，确保服务质量。\u000A绿色环保：使用环保清洁剂，保障家人健康。\u000A售后保障：提供完善的售后服务，解决您的后顾之忧。')
                .fontSize(14)
            }
            .alignItems(HorizontalAlign.Start)

            Column() {
              Text('联系方式').fontSize(14).fontWeight(500)
              Row({ space: 4 }) {
                Text('电话：').fontSize(14)
                Text(this.homeBaseInfo.hotline)
                  .fontSize(14)
                  .fontColor($r('app.color.common_theme_color'))
                  .onClick(() => {
                    callPhone(this.homeBaseInfo.hotline);
                  })
              }

              Row({ space: 4 }) {
                Text('官网：').fontSize(14)
                Text(this.homeBaseInfo.officialWebsite)
                  .fontSize(14)
                  .fontColor($r('app.color.common_theme_color'))
                  .onClick(() => {
                    RouterModule.push({ url: RouterMap.OFFICIAL_WEB });
                  })
              }
            }
            .alignItems(HorizontalAlign.Start)
            Column().layoutWeight(1)
          }
          .width(CommonConstants.FULL_PERCENT)
          .padding(10)
          .borderRadius(4)
          .backgroundColor(Color.White)
          .alignItems(HorizontalAlign.Start)
        }
        .padding(10)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .title('公共服务', { backgroundColor: Color.White, paddingStart: new LengthMetrics(10) })
    .backgroundColor($r('app.color.common_page_bg'))
  }
}
