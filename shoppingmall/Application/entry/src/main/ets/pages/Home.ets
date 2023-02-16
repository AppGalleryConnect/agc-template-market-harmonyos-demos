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
import { GoodsList, SearchContainer } from '../../components';
import { GoodModel } from '../../model';
import { Request, RequestType, Triggers } from '../../api';
import { domain, searchText, Constants } from '../../constants';

const TAG = new String($r('app.string.Home')).toString();

@Component
export struct Home {
  @State recommendHint: string = searchText;
  @State searchInput: string = '';
  @Link token: string;
  @Link @Watch("onSearchChanged") isSearching: boolean;
  @State searchResult: Array<GoodModel> = [];
  private controller: SearchController = new SearchController();

  onSearchChanged() {
    Logger.info(domain, TAG, "search state changed " + this.isSearching);
  }

  async getSearchResult(keyword) {
    let params = {
      "keyword": keyword
    };

    let res = await Request.invokeWithToken(Triggers.Commodity, this.token, RequestType.Search, params);
    //展示搜索列表
    this.isSearching = true;
    this.searchResult = res;
  }

  build() {
    Column() {
      Flex() {
        Stack({ alignContent: Alignment.End }) {
          Search({ value: this.searchInput, placeholder: this.recommendHint, controller: this.controller })
            .width(Constants.WIDTH_FULL)
            .height(Constants.SEARCH_HIGH)
            .textFont({ size: $r('app.float.font_middle'), weight: FontWeight.Medium })
            .placeholderFont({ size: $r('app.float.font_middle'), weight: FontWeight.Normal })
            .searchButton('搜索')
            .backgroundColor(Color.White)
            .placeholderColor(Color.Black)
            .onSubmit((value: string) => {
              //获取搜索结果
              if (!this.searchInput.length) {
                this.getSearchResult(this.recommendHint);
              } else {
                this.getSearchResult(value);
              }
            })
            .onChange((value: string) => {
              this.searchInput = value;
            })
            .onPaste((value: string) => {
              Logger.info(domain, TAG, "pasted text in search is " + value);
            })

          if (this.searchInput.length) {
            Image($r('app.media.clear'))
              .align(Alignment.Center)
              .width(Constants.CORNER_MARK)
              .height(Constants.CORNER_MARK)
              .margin({
                right: 54, top: 8, bottom: 8
              })
              .onClick(() => {
                this.searchInput = ''
              })
          }
        }
        .margin({ top: $r('app.float.margin_top_small'), bottom: $r('app.float.margin_bottom_small') })
        .width(Constants.WIDTH_FULL)
      }.width(Constants.WIDTH_FULL).backgroundColor(Color.Red)

      if (!this.isSearching) {
        GoodsList()
      } else {
        SearchContainer({ searchResult: $searchResult })
      }
    }
    .backgroundColor($r('app.color.page_background'))
  }
}