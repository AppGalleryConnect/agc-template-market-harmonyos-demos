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
import {
  BreakpointNameEnum,
  CommonConstants,
  GridRowColSetting,
  IMenuItem,
  MY_ORDER_LIST,
  WindowUtils
} from 'lib_foundation';
import { WindowUtil } from 'module_base';
import { OrderList } from '../components/OrderList';
import { IQueryListParam, MyOrderVM } from '../viewmodel/MyOrderVM';

@Builder
export function MyOrderListBuilder() {
  MyOrderList()
}

@ComponentV2
export struct MyOrderList {
  @Local breakpoint: BreakpointNameEnum = BreakpointNameEnum.SM;
  orderVM: MyOrderVM = MyOrderVM.instance;

  async aboutToAppear(): Promise<void> {
    WindowUtil.initWindowUtil(this.getUIContext());
    await this.orderVM.init();
  }

  build() {
    NavDestination() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS, }) {
          Column() {
            Tabs({ barPosition: BarPosition.Start, index: this.orderVM.selectedIndex }) {
              ForEach(MY_ORDER_LIST, (v: IMenuItem, index: number) => {
                TabContent() {
                  OrderList({
                    breakpoint: this.breakpoint,
                    data: this.orderVM.allList[index],
                    isRefreshing: this.orderVM.isRefreshing,
                    isLoading: this.orderVM.isLoading,
                    queryOrderList: (param?: IQueryListParam) => {
                      this.orderVM.queryOrderList(true, param);
                    },
                    refreshList: async (param?: IQueryListParam) => {
                      await this.orderVM.checkCalendar();
                      this.orderVM.queryOrderList(true, param);
                    },
                  })
                }.tabBar(this.tabBuilder(index, v.tabLabel || v.textLabel))
              }, (v: IMenuItem) => v.imgUrl + v.textLabel)
            }
            .barMode(BarMode.Scrollable)
            .barHeight(56)
            .barWidth('calc(100% - 48vp)')
            .scrollable(false)
            .animationDuration(600)
            .onAnimationStart((index: number, targetIndex: number) => {
              if (index === targetIndex) {
                return
              }
              this.orderVM.queryOrderList(true, {
                tabIndex: targetIndex,
                showFullLoading: true,
              });
            })
            .height(CommonConstants.FULL_PERCENT)
          }
        }
      }
      .onBreakpointChange((bp) => {
        this.breakpoint = bp as BreakpointNameEnum;
      })
    }
    .title('我的订单', {
      paddingStart: { value: GridRowColSetting.getPageMargin(this.breakpoint), unit: 1 }
    })
    .padding({
      top: WindowUtils.windowTopPadding,
      bottom: WindowUtils.windowBottomPadding,
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  tabBuilder(index: number, name: string) {
    Column({ space: 8 }) {
      Text(name)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(this.orderVM.selectedIndex === index ? 700 : 400)
        .lineHeight(22)
        .fontColor(this.orderVM.selectedIndex === index ? $r('sys.color.font_emphasize') :
          $r('sys.color.font_secondary'))
        .onSizeChange((oldSize, newSize) => {
          this.orderVM.textWidth[index] = newSize.width as number - 8;
        })
      Row()
        .height(2)
        .backgroundColor(this.orderVM.selectedIndex === index ? $r('sys.color.font_emphasize') :
          $r('sys.color.font_secondary'))
        .opacity(this.orderVM.selectedIndex === index ? 1 : 0)
        .width(this.orderVM.textWidth[index])
    }
    .width('calc(25% - 12vp)')
  }
}
