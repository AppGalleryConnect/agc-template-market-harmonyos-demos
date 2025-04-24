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
import { CommonConstants, IMenuItem, MY_ORDER_LIST, FullOrderInfo, UIEmpty } from 'utils'
import { OrderCard } from '../components/OrderCard';
import { MyOrderVM } from '../viewmodel/MyOrderVM';
import { LengthMetrics } from '@kit.ArkUI';

@Builder
export function MyOrderListBuilder() {
  MyOrderList()
}

@ComponentV2
export struct MyOrderList {
  orderVM: MyOrderVM = MyOrderVM.instance;

  aboutToAppear(): void {
    this.orderVM.init();
  }

  build() {
    NavDestination() {
      Column() {
        Divider()
        Tabs({ barPosition: BarPosition.Start, index: this.orderVM.selectedIndex }) {
          ForEach(MY_ORDER_LIST, (v: IMenuItem, index: number) => {
            TabContent() {
              this.contentBuilder(index)
            }.tabBar(this.tabBuilder(index, v.tabLabel || v.textLabel))
          }, (v: IMenuItem) => v.imgUrl + v.textLabel)
        }
        .barMode(BarMode.Fixed)
        .barHeight(40)
        .barBackgroundColor(Color.White)
        .scrollable(false)
        .animationDuration(600)
        .onAnimationStart((index: number, targetIndex: number) => {
          if (index === targetIndex) {
            return
          }
          this.orderVM.queryOrderList({
            tabIndex: targetIndex,
            showFullLoading: true,
          });
        })
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
      }
    }
    .title('订单管理', { backgroundColor: Color.White, paddingStart: new LengthMetrics(10) })
    .backgroundColor($r('app.color.common_page_bg'))
  }

  @Builder
  tabBuilder(index: number, name: string) {
    Column({ space: 6 }) {
      Text(name)
        .fontSize(14)
        .fontWeight(this.orderVM.selectedIndex === index ? 500 : 400)
        .lineHeight(20)
      Divider()
        .strokeWidth(2)
        .color($r('app.color.common_theme_color'))
        .opacity(this.orderVM.selectedIndex === index ? 1 : 0)
        .width('80%')
    }
    .width(CommonConstants.FULL_PERCENT)
  }

  @Builder
  contentBuilder(index: number) {
    if (this.orderVM.allList[index].list.length) {
      Refresh({ refreshing: $$this.orderVM.isRefreshing }) {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.orderVM.allList[index].list, (v: FullOrderInfo) => {
              OrderCard({
                fullOrderInfo: v,
                refreshList: () => {
                  this.orderVM.queryOrderList({
                    showFullLoading: true,
                  });
                },
                jumpTab: (tabIndex: number) => {
                  this.orderVM.queryOrderList({
                    tabIndex,
                    showFullLoading: true,
                  });
                },
              })
            }, (item: FullOrderInfo) => JSON.stringify(item))
          }.width(CommonConstants.FULL_PERCENT)
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .padding(10)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .onRefreshing(() => {
        this.orderVM.queryOrderList({
          showFullLoading: false,
        });
      })
    }
    if (!this.orderVM.isLoading && this.orderVM.allList[index].list.length === 0) {
      UIEmpty({ emptyDesc: '暂无订单', fg: 12 }).margin({ bottom: 100 })
    }
  }
}
