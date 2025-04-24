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
  CommonConstants,
  CommonUtils,
  GoodCard,
  GoodCardSize,
  IGoodInfo,
  IMenuItem,
  MY_ORDER_LIST,
  MY_TOOL_LIST,
  RouterMap,
  RouterModule,
  UserInfo,
} from 'utils'
import { AppStorageV2, CircleShape } from '@kit.ArkUI';
import { MineVM } from '../viewmodel/MineVM';

@ComponentV2
export struct Mine {
  userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  mineVM: MineVM = new MineVM();

  aboutToAppear(): void {
    this.mineVM.init();
  }

  build() {
    NavDestination() {
      Stack() {
        Scroll(this.mineVM.scroller) {
          Column() {
            Column() {
              this.titleInside()
              this.TopPersonInfo()
            }
            .padding({ left: 10, right: 10 })
            .backgroundImage($r('app.media.mine_top_bg'))
            .backgroundImageSize(ImageSize.Cover)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

            Column({ space: 10 }) {
              this.MineOrder()
              this.ToolCard()
              this.WaterFlowList()
            }
            .padding({
              left: 10,
              right: 10,
              top: 10,
              bottom: 10,
            })
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring)
        .onDidScroll(() => {
          this.mineVM.titleBgOpacity = this.mineVM.scroller.currentOffset().yOffset / 56;
        })

        this.titleBuilder()
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .alignContent(Alignment.Top)
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.common_page_bg'))
  }

  @Builder
  titleBuilder() {
    Row() {
      Text('个人中心').fontSize(20).fontWeight(FontWeight.Bold).padding({ left: 10 }).height(56)
    }
    .width(CommonConstants.FULL_PERCENT)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .backgroundColor(Color.White)
    .opacity(this.mineVM.titleBgOpacity)
  }

  @Builder
  titleInside() {
    Text('个人中心')
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .height(56)
      .alignSelf(ItemAlign.Start)
      .opacity(1 - 2 * this.mineVM.titleBgOpacity)
  }

  @Builder
  TopPersonInfo() {
    Row({ space: 6 }) {
      Image(CommonUtils.handleImgUrl(this.userInfo.avatar) || $r('app.media.ic_user_default'))
        .width(56)
        .height(56)
        .clipShape(new CircleShape({ width: 56, height: 56 }))
      Text(this.userInfo.nickName || '华为用户')
        .fontSize(18)
        .fontWeight(500)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
    }
    .width(CommonConstants.FULL_PERCENT)
    .margin({ top: 20, bottom: 30 })
    .onClick(() => {
      RouterModule.push({ url: RouterMap.EDIT_PERSONAL });
    })
  }

  @Builder
  MineOrder() {
    Column({ space: 10 }) {
      Text('我的订单').fontSize(14).fontWeight(500)

      Grid() {
        ForEach(MY_ORDER_LIST, (v: IMenuItem, index: number) => {
          GridItem() {
            Column({ space: 4 }) {
              Image(v.imgUrl).width(24).height(24).objectFit(ImageFit.Contain)
              Text(v.textLabel).fontSize(12).height(16)
            }
            .onClick(() => {
              RouterModule.push({ url: RouterMap.MY_ORDER_LIST, param: index });
            })
          }
        }, (v: IMenuItem) => v.imgUrl + v.textLabel)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding(10)
    .borderRadius(8)
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ToolCard() {
    Column({ space: 10 }) {
      Text('服务与工具').fontSize(14).fontWeight(500)

      Grid() {
        ForEach(MY_TOOL_LIST, (v: IMenuItem) => {
          GridItem() {
            Column({ space: 4 }) {
              Image(v.imgUrl).width(24).height(24).objectFit(ImageFit.Contain)
              Text(v.textLabel).fontSize(12).height(16)
            }
            .onClick(() => {
              RouterModule.push({ url: v.routerUrl! });
            })
          }
        }, (item: IMenuItem) => item.imgUrl + item.textLabel)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding(10)
    .borderRadius(8)
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  WaterFlowList() {
    WaterFlow() {
      LazyForEach(this.mineVM.goodDataSource, (v: IGoodInfo, index: number) => {
        FlowItem() {
          GoodCard({ goodInfo: v, type: GoodCardSize.SMALL })
        }
        .width(CommonConstants.FULL_PERCENT)
        .onAppear(() => {
          this.mineVM.preloadData(index);
        })
      }, (v: IGoodInfo) => v.id.toString() + v.subIndex)
    }
    .columnsTemplate('1fr 1fr')
    .columnsGap(10)
    .rowsGap(6)
    .width(CommonConstants.FULL_PERCENT)
    .scrollBar(BarState.Off)
    .cachedCount(2)
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST,
    })
  }
}
