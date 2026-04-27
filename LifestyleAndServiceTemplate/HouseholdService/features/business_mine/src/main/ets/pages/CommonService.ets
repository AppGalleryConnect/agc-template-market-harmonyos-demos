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
import { RouterMap } from 'module_base';
import { CommonConstants, GridRowColSetting, HomeBaseInfo, RouterModule } from 'lib_foundation';
import { AppStorageV2 } from '@kit.ArkUI';
import { DialPanel } from 'dial_panel';

@Builder
export function CommonServiceBuilder() {
  CommonService()
}

@Extend(Column)
function cardContainer() {
  .width(CommonConstants.FULL_PERCENT)
  .padding({
    top: 16,
    bottom: 16,
    right: 12,
    left: 12
  })
  .borderRadius(20)
  .backgroundColor($r('sys.color.comp_background_list_card'))
}

@ComponentV2
export struct CommonService {
  @Local breakpoint: string = '';
  homeBaseInfo: HomeBaseInfo = AppStorageV2.connect(HomeBaseInfo, () => new HomeBaseInfo())!;
  private uiContext: UIContext = this.getUIContext();
  private dialPanel: DialPanel = new DialPanel(this.uiContext)

  build() {
    NavDestination() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS, }) {
          Scroll() {
            Column({ space: 16 }) {
              Column() {
                Column({ space: 12 }) {
                  Text('在现代社会，随着生活节奏的加快，越来越多的人选择将家务事交给专业的家政服务公司来处理。这不仅节省时间，还能确保家居环境的整洁与卫生。选择一家靠谱的家政公司，更是对家庭健康的重要保障。')
                    .fontSize($r('sys.float.Body_L')).fontWeight(FontWeight.Medium).lineHeight(21)
                  Text('保洁家政服务的优势：')
                    .fontSize($r('sys.float.Subtitle_L'))
                    .fontWeight(FontWeight.Bold)
                    .lineHeight(24)
                  Text('个性化服务：部分品牌提供定制化服务方案，满足不同家庭的个性化需求。\u000A专业团队：所有员工均经过专业培训，持证上岗，确保服务质量。\u000A绿色环保：使用环保清洁剂，保障家人健康。\u000A售后保障：提供完善的售后服务，解决您的后顾之忧。')
                    .fontSize($r('sys.float.Body_L')).fontWeight(FontWeight.Medium).lineHeight(21)
                }
                .alignItems(HorizontalAlign.Start)
              }
              .cardContainer()

              Column() {
                Column({ space: 8 }) {
                  Row() {
                    Text('联系方式').fontSize($r('sys.float.Subtitle_L')).fontWeight(FontWeight.Bold)
                  }

                  Column({ space: 4 }) {
                    Row({ space: 8 }) {
                      Text('电话：').fontSize($r('sys.float.Subtitle_M')).fontWeight(FontWeight.Medium)
                      Text(this.homeBaseInfo.hotline)
                        .fontSize($r('sys.float.Body_L'))
                        .fontColor($r('sys.color.font_emphasize'))
                        .onClick(() => {
                          this.dialPanel
                            .setTitle('联系客服')
                            .setPhoneNumber(this.homeBaseInfo.hotline)
                            .open();
                        })
                    }

                    Row({ space: 8 }) {
                      Text('官网：').fontSize($r('sys.float.Subtitle_M')).fontWeight(FontWeight.Medium)
                      Text(this.homeBaseInfo.officialWebsite)
                        .fontSize($r('sys.float.Body_L'))
                        .fontColor($r('sys.color.font_emphasize'))
                        .onClick(() => {
                          RouterModule.push({ url: RouterMap.OFFICIAL_WEB });
                        })
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                }
                .margin({ left: 16 })
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              }
              .cardContainer()
            }
            .padding({
              top: 8,
              bottom: 8,
              left: GridRowColSetting.getPageMargin(this.breakpoint),
              right: GridRowColSetting.getPageMargin(this.breakpoint)
            })
          }
          .height(CommonConstants.FULL_PERCENT)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .onBreakpointChange((bp) => {
        this.breakpoint = bp;
      })
    }
    .title('公共服务', {
      paddingStart: { value: GridRowColSetting.getPageMargin(this.breakpoint), unit: 1 }
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
