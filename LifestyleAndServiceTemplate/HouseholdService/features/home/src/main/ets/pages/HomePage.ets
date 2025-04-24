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

import { AddressVM } from 'address_manage';
import {
  AppStorageBank,
  CommonConstants,
  CommonUtils,
  GoodCard,
  IGoodInfo,
  IMenuItem,
  MENU_LIST,
  RouterMap,
  RouterModule,
} from 'utils'
import { HomeVM } from '../viewmodel/HomeVM';
import { LengthMetrics } from '@kit.ArkUI';

@ComponentV2
export struct HomePage {
  homeVM: HomeVM = HomeVM.instance;
  addrVM: AddressVM = AddressVM.instance;

  aboutToAppear(): void {
    this.homeVM.init();
    this.addrVM.init();
  }

  build() {
    NavDestination() {
      Column() {
        this.TopBar()
        Scroll() {
          Column({ space: 10 }) {
            this.Banner()
            this.Menus()
            this.ServiceList()
          }
          .padding(10)
        }
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .title('首页', { backgroundColor: Color.White, paddingStart: new LengthMetrics(10) })
    .backgroundColor($r('app.color.common_page_bg'))
  }

  @Builder
  TopBar() {
    Row({ space: 10 }) {
      Row({ space: 4 }) {
        Text(this.homeVM.homeBaseInfo.citySelected)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: 120 })
        Image($r('app.media.ic_public_spinner_small')).width(10)
      }
      .onClick(() => {
        RouterModule.push({
          url: RouterMap.CITY_LIST,
          onPop: (info: PopInfo) => {
            if (info.result) {
              const citySelected = info.result as string;
              this.homeVM.updateCitySelectedInfo(citySelected);
            }
          },
        });
      })

      Search({
        placeholder: '双周保洁38元起',
      })
        .layoutWeight(1)
        .focusable(false)
        .onClick(() => {
          RouterModule.push({ url: RouterMap.SEARCH_PAGE });
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(48)
    .padding({
      left: 10,
      right: 10,
      top: 3,
      bottom: 5,
    })
    .backgroundColor(Color.White)
  }

  @Builder
  Banner() {
    Swiper() {
      ForEach(this.homeVM.homeBaseInfo.bannerGoods, (v: IGoodInfo) => {
        Image(CommonUtils.handleImgUrl(v.image))
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .onClick(() => {
            RouterModule.push({ url: RouterMap.GOOD_DETAIL, param: v });
          })
      }, (v: IGoodInfo) => v.id ?? '')
    }
    .width(CommonConstants.FULL_PERCENT)
    .aspectRatio(2)
    .autoPlay(true)
    .loop(true)
  }

  @Builder
  Menus() {
    Row() {
      ForEach(MENU_LIST, (item: IMenuItem) => {
        Column({ space: 16 }) {
          Image(item.imgUrl).width(48).height(48)
          Text(item.textLabel).fontSize(12).fontWeight(500)
        }
        .onClick(() => {
          AppStorageBank.updateJumpCategoryParam(item.mainParam!);
        })
      }, (item: IMenuItem) => item.imgUrl + item.textLabel)
    }
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  @Builder
  ServiceList() {
    Text('精选服务')
      .fontSize(16)
      .fontWeight(500)
      .margin({ top: 10, bottom: 10 })
      .width(CommonConstants.FULL_PERCENT)
      .textAlign(TextAlign.Start)

    List({ space: 10 }) {
      LazyForEach(this.homeVM.goodDataSource, (v: IGoodInfo) => {
        ListItem() {
          GoodCard({ goodInfo: v, hotline: this.homeVM.homeBaseInfo.hotline })
        }
      }, (v: IGoodInfo) => v.id.toString() + v.subIndex)
      ListItem() {
        Text('--已经到底啦--').fontSize(14).height(40).width(CommonConstants.FULL_PERCENT).textAlign(TextAlign.Center)
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .cachedCount(2)
    .scrollBar(BarState.Off)
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST,
    })
  }
}
