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
  getGoodList,
  IGoodInfo,
  QueryGoodListSource,
  RouterMap,
  RouterModule,
  UIEmpty,
} from 'utils'
import { LengthMetrics } from '@kit.ArkUI';

@Builder
export function SearchPageBuilder() {
  SearchPage()
}

const RECOMMEND_LIST: string[] = [
  '日常保洁', '开荒清洁', '住家保姆', '金牌月嫂',
  '家电维修', '数码维修', '衣柜收纳', '全屋擦窗',
];

@ComponentV2
export struct SearchPage {
  @Local showSearchRsp: boolean = false;
  @Local searchRspList: IGoodInfo[] = [];
  @Local searchText: string = '';

  build() {
    NavDestination() {
      Column() {
        this.TopBar()
        Stack() {
          this.Recommend()
          if (this.showSearchRsp) {
            this.SearchRsp()
          }
        }
        .alignContent(Alignment.Top)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding({
        left: 10,
        right: 10,
        bottom: 10,
      })
    }
    .title('搜索服务', { backgroundColor: Color.White, paddingStart: new LengthMetrics(10) })
    .onBackPressed(() => {
      if (this.showSearchRsp) {
        this.initSearchParam();
        return true;
      }
      return false;
    })
  }

  initSearchParam() {
    this.showSearchRsp = false;
    this.searchText = '';
    this.searchRspList = [];
  }

  searchQuery(input: string) {
    this.searchText = input;
    if (!this.searchText) {
      this.initSearchParam();
      return;
    }
    getGoodList(QueryGoodListSource.SEARCH, this.searchText).then((resp) => {
      this.showSearchRsp = true;
      this.searchRspList = resp;
    });
  }

  @Builder
  TopBar() {
    Row({ space: 10 }) {
      Search({ value: $$this.searchText, placeholder: '请输入名称查询' })
        .layoutWeight(1)
        .onSubmit(() => {
          this.searchQuery(this.searchText);
        })
      Text('取消')
        .fontSize(14)
        .fontColor(Color.Black)
        .onClick(() => {
          RouterModule.pop();
        })
    }
    .height(40)
    .width(CommonConstants.FULL_PERCENT)
  }

  @Builder
  Recommend() {
    Column({ space: 10 }) {
      Text('热门搜索').fontSize(14).fontWeight(500)
      Flex({
        wrap: FlexWrap.Wrap,
        space: { main: new LengthMetrics(10), cross: new LengthMetrics(10) },
        justifyContent: FlexAlign.SpaceBetween,
      }) {
        ForEach(RECOMMEND_LIST, (v: string) => {
          Button() {
            Text(v).fontSize(14).fontWeight(500)
          }
          .backgroundColor($r('app.color.grey_5'))
          .padding({
            top: 4,
            bottom: 4,
            left: 8,
            right: 8,
          })
          .onClick(() => {
            this.searchQuery(v);
          })
        }, (v: string) => v)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width(CommonConstants.FULL_PERCENT)
    .margin({ top: 10 })

  }

  @Builder
  SearchRsp() {
    Column() {
      if (this.searchRspList.length) {
        List() {
          ForEach(this.searchRspList, (v: IGoodInfo) => {
            ListItem() {
              Column() {
                Row({ space: 10 }) {
                  Image(CommonUtils.handleImgUrl(v.image)).width(84).height(70).borderRadius(4)
                  Column({ space: 10 }) {
                    Text(v.title).fontSize(14).fontWeight(500)
                    Text(v.subTitle).fontSize(12).fontWeight(400).fontColor($r('app.color.common_grey'))
                  }
                  .alignItems(HorizontalAlign.Start)
                }
                .width(CommonConstants.FULL_PERCENT)
                .margin({ top: 10, bottom: 10 })
                .onClick(() => {
                  RouterModule.push({ url: RouterMap.GOOD_DETAIL, param: v });
                })

                Divider()
              }
              .alignItems(HorizontalAlign.Start)
            }

          }, (v: IGoodInfo) => v.id.toString() + v.subIndex)
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .scrollBar(BarState.Off)
      } else {
        UIEmpty().margin({ top: 150 })
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .height('calc(100% - 40vp)')
    .backgroundColor(Color.White)
  }
}
