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

import { getGoodList, GoodDataSource, QueryGoodListSource } from 'utils';

@ObservedV2
export class MineVM {
  @Trace titleBgOpacity: number = 0;
  scroller: Scroller = new Scroller();
  goodDataSource: GoodDataSource = new GoodDataSource();
  isLoading: boolean = false;

  init() {
    this.queryGoodList();
  }

  queryGoodList() {
    this.isLoading = true;
    getGoodList(QueryGoodListSource.MINE).then((resp) => {
      this.goodDataSource.batchPushData(resp);
      this.isLoading = false;
    });
  }

  preloadData(index: number) {
    if (this.isLoading) {
      return;
    }
    if (index + 0 >= this.goodDataSource.totalCount()) {
      this.queryGoodList()
    }
  }
}