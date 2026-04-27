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
import { PersistenceV2, Type } from '@kit.ArkUI';
import { City, CityAlphaGroup } from '../common/Model';
import { getLocationCity } from '../common/Location';

@ObservedV2
export class CitySelectViewModel {
  @Trace selectIndex: number = 0;
  @Trace persistenceData: PersistenceData = PersistenceV2.connect(PersistenceData, () => new PersistenceData())!
  @Trace isLoading: boolean = false;
  @Trace cityList: City[];
  @Trace maxVisitNum = 4;
  @Trace columnsNum: number = 4;
  @Trace buttonPadding: number = 8;
  @Trace breakpoint: string = 'sm';
  scrollerOut: Scroller = new Scroller();
  scroller: Scroller = new Scroller();

  constructor(cityList: City[]) {
    this.cityList = cityList;
  }

  @Computed
  get recentVisitList() {
    if (this.currentCity.name) {
      return this.persistenceData.recentVisitList.filter((item) => item.name !== this.currentCity?.name)
        .slice(0, this.maxVisitNum);
    }
    return this.persistenceData.recentVisitList.slice(0, this.maxVisitNum);
  }

  @Computed
  get currentCity() {
    return this.persistenceData.currentCity;
  }

  @Computed
  get cityAlphaGroupList(): CityAlphaGroup[] {
    return this.getCityAlphaList(this.cityList);
  }

  @Computed
  get alphaIndexList(): string[] {
    return this.cityAlphaGroupList.map(item => item.name);
  }

  handleScrollIndex(start: number) {
    this.selectIndex = start;
  }

  handleAlphaSelect(tabIndex: number) {
    this.scrollerOut.scrollEdge(Edge.Bottom);
    this.scroller.scrollToIndex(tabIndex);
  }

  addVisitCity(city: City) {
    const recentVisitList = this.persistenceData.recentVisitList;
    const record = recentVisitList.find(item => item.name === city.name);
    if (!record) {
      recentVisitList.unshift(city);
      if (recentVisitList.length > this.maxVisitNum + 1) {
        recentVisitList.pop();
      }
    } else {
      recentVisitList.splice(recentVisitList.indexOf(record), 1)
      recentVisitList.unshift(record);
    }
  }

  async getLocationCity() {
    this.isLoading = true;
    const city = await getLocationCity();
    if (city) {
      this.persistenceData.currentCity = city;
    }
    this.isLoading = false;
    return city;
  }

  setLoading(isLoading: boolean): void {
    this.isLoading = isLoading;
  }

  private getCityAlphaList(cityList: City[]): CityAlphaGroup[] {
    let transliterator = i18n.Transliterator.getInstance('Any-Latn;Latin-Ascii');
    const alphaMap: Record<string, City[]> = {}
    for (const city of cityList) {
      const result: string = transliterator.transform(city.name);
      const alpha = result[0].toUpperCase();
      if (alphaMap[alpha]) {
        alphaMap[alpha].push(city)
      } else {
        alphaMap[alpha] = [city]
      }
    }
    return Object.keys(alphaMap).map((name) => {
      return {
        name: name,
        list: alphaMap[name],
      } as CityAlphaGroup
    }).sort((a, b) => a.name.charCodeAt(0) - b.name.charCodeAt(0))
  }
}

@ObservedV2
class PersistenceData {
  @Type(City)
  @Trace recentVisitList: City[] = [];
  @Trace currentCity: City = new City();
}