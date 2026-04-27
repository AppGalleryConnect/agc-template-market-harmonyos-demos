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
import { City } from '../common/Model';
import { CityTag } from './CityTag';

@ComponentV2
export struct CityTags {
  @Param @Require columnsNum: number;
  @Param @Require buttonPadding: number;
  @Require @Param cityList: City[];
  @Event selectCity: (city: City) => void;

  build() {
    Grid() {
      ForEach(this.cityList, (item: City) => {
        GridItem() {
          CityTag({
            city: item.name,
          }).onClick(() => {
            this.selectCity(item);
          })
        }
      }, (item: City) => item.name)
    }
    .columnsTemplate(this.getColumnsTemplate)
    .columnsGap(this.buttonPadding)
    .rowsGap(this.buttonPadding)
  }

  @Computed
  get getColumnsTemplate() {
    return Array(this.columnsNum).fill('1fr').join(' ');
  }
}