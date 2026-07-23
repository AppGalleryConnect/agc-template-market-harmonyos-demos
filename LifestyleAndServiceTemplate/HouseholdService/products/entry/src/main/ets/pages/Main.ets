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
import { ToastDialog } from '@hw-agconnect/ui-toast';
import {
  AppPrivacyUtils,
  AppStorageBank,
  BreakpointNameEnum,
  CommonConstants,
  CustomLinkModel,
  CustomShareParams,
  FormCardRouter,
  FullOrderInfo,
  getGood,
  getGoodList,
  getOrder,
  GridRowColSetting,
  IJumpToDetailParam,
  JumpCategoryParam,
  OrderToPayParam,
  QueryGoodListSource,
  RouterModule,
  WindowUtils
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
  @Local breakpoint: BreakpointNameEnum = BreakpointNameEnum.SM;
  @Local allCategoryListIndex: number = 0;
  @Local privacyImpl: AppPrivacyUtils = AppPrivacyUtils.instance;
  @Local shareRouter: CustomShareParams =
    AppStorageV2.connect(CustomShareParams, 'handleShare', () => new CustomShareParams())!;
  @Local linkScanRouter: CustomLinkModel = AppStorageV2.connect(CustomLinkModel, () => new CustomLinkModel())!;
  @Local formCardRouter: FormCardRouter = AppStorageV2.connect(FormCardRouter, () => new FormCardRouter())!;
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

  @Monitor('formCardRouter.id')
  onFormCardClick() {
    if (this.formCardRouter.id) {
      if (this.formCardRouter.pageUrl === RouterMap.MY_ORDER_DETAIL && this.formCardRouter.orderId) {
        getOrder(this.formCardRouter.orderId).then(async (resp) => {
          const orderInfo = new OrderToPayParam();
          orderInfo.orderInfo = resp as FullOrderInfo;
          orderInfo.isFromOrderCard = false;
          RouterModule.push({ url: RouterMap.MY_ORDER_DETAIL, param: orderInfo });
        }).catch((error: BusinessError) => {
          ToastDialog.showToast({ message: '该订单不存在~' });
          UtilLog.error('[formCardRouter]', 0x0FFF,
            'Click formCard failed, can not find the order, error: ' + JSON.stringify(error));
        })
      } else if (this.formCardRouter.pageUrl === 'AllCategory') {
        AppStorageBank.updateJumpCategoryParam(this.formCardRouter.categoryParam)
      } else {
        getGood(this.formCardRouter.goodId).then((good) => {
          const param: IJumpToDetailParam = { goodInfo: good };
          RouterModule.push({ url: RouterMap.GOOD_DETAIL, param: param });
        }).catch((error: BusinessError) => {
          ToastDialog.showToast({ message: '该服务不存在~' });
          UtilLog.error('[MainReceiveShare]', 0x0FFF,
            'Receive share failed, can not find the good, error: ' + JSON.stringify(error));
        })
      }
      this.formCardRouter.id = 0;
    }
  }

  @Computed
  get isTabVertical() {
    return [BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.breakpoint);
  }

  aboutToAppear(): void {
    this.onShareJump();
    this.onLinkJump();
    this.onFormCardClick();
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
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS, }) {
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
            .scrollable(false)
            .barWidth(this.isTabVertical ? 96 : undefined)
            .barHeight(this.isTabVertical ? '50%' : undefined)
            .divider(this.isTabVertical ? {
              strokeWidth: '1px',
              color: $r('sys.color.comp_divider'),
              startMargin: 0,
              endMargin: 0,
            } as DividerStyle : null)
            .vertical(this.isTabVertical ? true : false)
            .animation({ duration: 200, curve: Curve.EaseInOut })
            .barPosition(this.isTabVertical ? BarPosition.Start : BarPosition.End)
            .onTabBarClick((index: number) => {
              this.jumpCategoryParam.tabIndex = index;
            })
          }
          .height(CommonConstants.FULL_PERCENT)
          .width(CommonConstants.FULL_PERCENT)
          .padding({
            bottom: this.isTabVertical ? 0 : WindowUtils.windowBottomPadding,
          })

          // todo 可选，若需要内容模糊，可放开下面注释代码
          // .foregroundBlurStyle(this.privacyImpl.agreeFlag ? BlurStyle.NONE : BlurStyle.Thin)
        }
      }
      .onBreakpointChange((bp) => {
        this.breakpoint = bp as BreakpointNameEnum;
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}