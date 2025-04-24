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
import { AppStorageV2 } from '@kit.ArkUI';
import { HomePage } from 'home';
import { AllCategory } from 'category';
import { Mine } from 'mine';
import { Logger, CommonConstants, JumpCategoryParam } from 'utils';

class TabItemModel {
  label: ResourceStr = '';
  icon: ResourceStr = '';
  iconSelected: ResourceStr = '';
}

@Builder
export function MainBuilder() {
  Main()
}

@Entry
@ComponentV2
struct Main {
  @Local allCategoryListIndex: number = 0;
  jumpCategoryParam: JumpCategoryParam = AppStorageV2.connect(JumpCategoryParam, () => new JumpCategoryParam())!;

  aboutToAppear() {
    Logger.info('Main Page onCreate');
  }

  @Builder
  tabBuilder(index: number, item: TabItemModel) {
    Column({ space: 4 }) {
      Image(this.jumpCategoryParam.tabIndex === index ? item.iconSelected : item.icon)
        .width(21)
        .height(21)
        .objectFit(ImageFit.Contain)
      Text(item.label)
        .fontColor(this.jumpCategoryParam.tabIndex === index ? $r('app.color.common_theme_color') :
        $r('app.color.common_grey'))
        .fontSize(10)
        .fontWeight(500)
        .lineHeight(14)
    }.width(CommonConstants.FULL_PERCENT)
  }

  build() {
    NavDestination() {
      Column() {
        Tabs({ index: $$this.jumpCategoryParam.tabIndex }) {
          TabContent() {
            HomePage()
          }
          .tabBar(this.tabBuilder(0, {
            label: $r('app.string.tab_home'),
            icon: $r('app.media.ic_public_home'),
            iconSelected: $r('app.media.ic_public_home_highlight'),
          }))

          TabContent() {
            AllCategory()
          }
          .tabBar(this.tabBuilder(1, {
            label: $r('app.string.tab_all_category'),
            icon: $r('app.media.ic_tab_category'),
            iconSelected: $r('app.media.ic_tab_category_highlight'),
          }))

          TabContent() {
            Mine()
          }
          .clip(false)
          .tabBar(this.tabBuilder(2, {
            label: $r('app.string.tab_mine'),
            icon: $r('app.media.ic_public_person'),
            iconSelected: $r('app.media.ic_public_person_highlight'),
          }))
        }
        .clip(false)
        .height(CommonConstants.FULL_PERCENT)
        .width(CommonConstants.FULL_PERCENT)
        .scrollable(false)
        .barPosition(BarPosition.End)
        .barBackgroundColor($r('app.color.common_page_bg'))
        .onTabBarClick((index: number) => {
          this.jumpCategoryParam.tabIndex = index;
        })
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
    }.hideTitleBar(true)
  }
}