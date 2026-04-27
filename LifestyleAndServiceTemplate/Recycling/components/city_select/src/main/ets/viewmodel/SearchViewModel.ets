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

import { i18n } from '@kit.LocalizationKit';
import { City, CityDetail } from '../common/Model';

@ObservedV2
export class SearchViewModel {
  @Trace searchKey: string = '';
  @Trace cityList: City[];
  @Trace showSearchRsp: boolean = false;

  constructor(cityList: City[]) {
    this.cityList = cityList;
  }

  @Computed
  get emptyLabel() {
    if (this.searchKey && this.searchList.length === 0) {
      return '没有符合条件的内容';
    }
    return '输入关键词查找结果';
  }

  @Computed
  get showSearchResult(): boolean {
    return !!this.searchKey;
  }

  @Computed
  get cityDetailList(): CityDetail[] {
    return this.getCityDetailList(this.cityList);
  }

  @Computed
  get searchList(): City[] {
    if (!this.searchKey) {
      return [];
    }
    const value = this.searchKey.toLowerCase();
    return this.cityDetailList.filter(item => item.name.includes(value) || item.pinyin.includes(value) ||
    item.key.includes(value));
  }

  init() {
    this.searchKey = '';
  }

  private getCityDetailList(cityList: City[]): CityDetail[] {
    let transliterator = i18n.Transliterator.getInstance('Any-Latn;Latin-Ascii');
    return cityList.map((item: City) => {
      const list: string[] = transliterator.transform(item.name).split(' ');
      return {
        name: item.name,
        code: item.code,
        pinyin: list.join(''),
        key: list.map(word => word[0].toLowerCase()).join(''),
      } as CityDetail
    })
  }
}