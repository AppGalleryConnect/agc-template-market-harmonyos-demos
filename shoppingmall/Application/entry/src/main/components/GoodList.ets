/*
 * Copyright 2020. Huawei Technologies Co., Ltd. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Logger from '@ohos.hilog';
import router from '@ohos.router';
import { GoodModel } from '../model';
import { Request, RequestType,Triggers } from '../api';
import { Empty } from './Empty';
import { Loading } from './Loading';
import { domain } from '../constants';
import { Constants } from '../constants/Constants';

const TAG = new String($r('app.string.GoodList')).toString();

@Component
export struct GoodsList {
  @State goodList: Array<GoodModel> = [];
  @State gridIndex: number = 0;
  @State isVisibleLoadMore: boolean = false;
  private gridItemHeight = 250;
  private loadMoreHeight = 100;
  private downY = 0;
  // 上一次移动的y坐标
  private lastMoveY = 0;
  // 是否正在刷新：刷新中不进入触摸逻辑
  private isRefreshing: boolean = false;
  //是否为加载更多状态
  private isLoadingMore: boolean = false;
  //是否为加载中
  private isLoading: boolean = true;
  // 是否已经进入了下拉刷新操作
  private pageSize: number = 6;
  private currentPage: number = 1;
  // 上拉加载的布局是否显示

  async aboutToAppear() {
    this.fetchGoodData();
  }

   async fetchGoodData() {
    try {
      let params = {
        "pageSize": this.pageSize,
        "currentPage": this.currentPage
      }
      let res = await Request.invoke(Triggers.Commodity, RequestType.Query, params);
      if (res) {
        this.goodList = Object.assign(res, this.goodList);
      }
      this.isLoading = false;
    } catch (err) {
      this.isLoading = false;
      Logger.error(domain, TAG, "obtain goodList failed " + err);
    }
  }

  gridTouchEvent(event: TouchEvent) {
    switch (event.type) {
      case TouchType.Down:
      // 记录按下的y坐标
        this.downY = event.touches[0].y;
        this.lastMoveY = event.touches[0].y;
        break
      case TouchType.Move:
      // 下拉刷新中 或 加载更多中，不进入处理逻辑
        if (this.isRefreshing || this.isLoadingMore) {
          return
        }

      //大于pagesize的高度后，查询下一页数据
        let y = event.touches[0].y;
        let isDown
        if (this.currentPage === 1) {
          isDown = event.touches[0].y - this.lastMoveY > 0;
        } else {
          isDown = event.touches[0].y - this.lastMoveY > 100;
        }

        if (!isDown) {
          this.touchMoveLoadMore(event);
        } else {
          this.isVisibleLoadMore = false;
        }
        this.lastMoveY = event.touches[0].y;
        break
      case TouchType.Up:
    }
  }

  touchMoveLoadMore(event: TouchEvent) {
    this.isVisibleLoadMore = true;
    this.currentPage++;
    this.fetchGoodData();
  }

  @Builder loadMoreGood() {
    Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Image($r('app.media.loading'))
        .width($r('app.float.good_loading_width'))
        .height($r('app.float.good_loading_width'))

      Text($r('app.string.shopCart_loading'))
        .margin({ left: $r('app.float.margin_left_middle') })
        .fontSize($r('app.float.font_large'))
        .fontColor(Color.Gray)
    }
    .width(Constants.WIDTH_FULL)
    .height(this.loadMoreHeight)
    .backgroundColor($r('app.color.good_loading'))
    .visibility(this.isVisibleLoadMore ? Visibility.Visible : Visibility.None)
  }

  build() {
    Column() {
      if (!this.goodList.length) {
        if (this.isLoading) {
          Loading()
        } else {
          Empty()
        }
      } else {
        Grid() {
          ForEach(this.goodList, item => {
            GridItem() {
              Column() {
                Image(item.detail_pic_url)
                  .width(Constants.HIGH_FULL)
                  .height(Constants.HIGH_TWO_THIRD_FULL)
                  .objectFit(ImageFit.Contain)
                  .margin({ bottom: $r('app.float.margin_bottom_large') })
                  .alignSelf(ItemAlign.Center)
                Text(`【${item.name}】${item.desc}`)
                  .fontSize($r('app.float.font_middle'))
                  .fontWeight(600)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ bottom:  $r('app.float.margin_bottom_middle'), left:  $r('app.float.margin_left_middle') })

                Text(`￥${item.price.toFixed(2)}`)
                  .fontSize($r('app.float.font_large'))
                  .fontColor(Color.Red)
                  .margin({ left: $r('app.float.margin_left_middle') })
              }
              .alignItems(HorizontalAlign.Start)
            }
            .width(Constants.WIDTH_NEAR_FULL)
            .height(this.gridItemHeight)
            .border({ width: 1, color: $r('app.color.good_grid'), radius: $r('app.float.border_radius_small') })
            .margin({ top: $r('app.float.margin_top_small'), bottom: $r('app.float.margin_bottom_small') })
            .backgroundColor(Color.White)
            .onClick(() => {
              router.push({
                url: 'pages/GoodDetail',
                params: { goodData: item }
              })
            })
          }, item => item.toString())
        }
        .columnsTemplate('1fr 1fr')
        .onScrollIndex((e) => {
          this.gridIndex = Number(e)
          Logger.info(domain, TAG, "current gridIndex is " + this.gridIndex);
        })
        .onTouch((event) => {
          this.gridTouchEvent(event);
        })

        this.loadMoreGood();
      }
    }
    .width(Constants.WIDTH_FULL)
    .backgroundColor($r('app.color.page_background'))
  }
}