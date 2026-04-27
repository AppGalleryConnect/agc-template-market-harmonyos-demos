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
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import {
  AppPrivacyUtils,
  CommonConstants,
  CustomLinkModel,
  CustomShareParams,
  getGood,
  getGoodList,
  IJumpToDetailParam,
  JumpCategoryParam,
  QueryGoodListSource,
  RouterModule
} from 'lib_foundation';
import { HomePage } from 'business_home';
import { Mine } from 'business_mine';
import { AllCategory } from '../components/AllCategory';
import { RouterMap } from 'module_base';

class TabItemModel {
  label: ResourceStr = '';
  icon: ResourceStr = '';
}

@Builder
export function MainBuilder() {
  Main()
}

@Entry
@ComponentV2
struct Main {
  @Local allCategoryListIndex: number = 0;
  @Local privacyImpl: AppPrivacyUtils = AppPrivacyUtils.instance;
  @Local shareRouter: CustomShareParams = AppStorageV2.connect(CustomShareParams, 'handleShare', () => new CustomShareParams())!;
  @Local linkScanRouter: CustomLinkModel = AppStorageV2.connect(CustomLinkModel, () => new CustomLinkModel())!;
  jumpCategoryParam: JumpCategoryParam = AppStorageV2.connect(JumpCategoryParam, () => new JumpCategoryParam())!;

  @Monitor('shareRouter.id')
  onShareJump() {
    if (this.shareRouter.id) {
      const currentName: string[] = RouterModule.getStack().getAllPathName()
      if (this.shareRouter.pageName === RouterMap.GOOD_DETAIL) {
        getGood(this.shareRouter.goodId).then((sharedGood) => {
          const param: IJumpToDetailParam = { goodInfo: sharedGood };
          if (currentName.length && currentName[currentName.length-1] === RouterMap.GOOD_DETAIL) {
            RouterModule.replace({ url: RouterMap.GOOD_DETAIL, param: param });
          } else {
            RouterModule.push({ url: RouterMap.GOOD_DETAIL, param: param });
          }
        }).catch((error: BusinessError) => {
          UtilLog.error('[MainReceiveShare]', 0x0FFF,
            'Receive share failed, can not find the good, error: ' + JSON.stringify(error));
        })
      } else {
        RouterModule.popToName(RouterMap.MAIN);
      }
    }
  }

  @Monitor('linkScanRouter.id')
  onLinkJump() {
    if (this.linkScanRouter.id) {
      this.jumpCategoryParam.tabIndex = 0;
      const pathNames: string[] = RouterModule.getStack().getAllPathName();
      for (let i = pathNames.length - 1; i > 0; i--) {
        RouterModule.getStack().removeByName(pathNames[i])
      }
      getGoodList(QueryGoodListSource.HOME).then((resp) => {
        const param: IJumpToDetailParam = { goodInfo: resp[0] };
        RouterModule.push({ url: RouterMap.GOOD_DETAIL, param: param })
      });
    }
  }

  aboutToAppear(): void {
    this.onShareJump();
    this.onLinkJump();
  }

  @Builder
  tabBuilder(index: number, item: TabItemModel) {
    Column({ space: 4 }) {
      SymbolGlyph(item.icon as Resource)
        .fontSize(24)
        .fontColor(this.jumpCategoryParam.tabIndex === index ? [$r('sys.color.icon_emphasize')] :
          [$r('sys.color.icon_secondary')])

      Text(item.label)
        .fontColor(this.jumpCategoryParam.tabIndex === index ? $r('sys.color.font_emphasize') :
          $r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Caption_M'))
        .fontWeight(400)
        .lineHeight(13)
    }
    .width(CommonConstants.FULL_PERCENT)
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
            icon: $r('sys.symbol.house_fill'),
          }))

          TabContent() {
            AllCategory()
          }
          .tabBar(this.tabBuilder(1, {
            label: $r('app.string.tab_all_category'),
            icon: $r('sys.symbol.store_fill'),
          }))

          TabContent() {
            Mine()
          }
          .clip(false)
          .tabBar(this.tabBuilder(2, {
            label: $r('app.string.tab_mine'),
            icon: $r('sys.symbol.person_fill'),
          }))
        }
        .clip(false)
        .height(CommonConstants.FULL_PERCENT)
        .width(CommonConstants.FULL_PERCENT)
        .scrollable(false)
        .barPosition(BarPosition.End)
        .barBackgroundColor($r('sys.color.background_primary'))
        .onTabBarClick((index: number) => {
          this.jumpCategoryParam.tabIndex = index;
        })
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)

      // todo 可选，若需要内容模糊，可放开下面注释代码
      // .foregroundBlurStyle(this.privacyImpl.agreeFlag ? BlurStyle.NONE : BlurStyle.Thin)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}