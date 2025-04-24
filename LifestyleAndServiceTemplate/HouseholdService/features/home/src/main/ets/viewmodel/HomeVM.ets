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
  getAllCategoryServices,
  getGoodList,
  getHomeInfo,
  GoodDataSource,
  AppStorageBank,
  updateCitySelected,
  HomeBaseInfo,
  QueryGoodListSource,
  SystemSceneUtils,
  updateCurrentCity,
} from 'utils';
import { AppStorageV2 } from '@kit.ArkUI';

@ObservedV2
export class HomeVM {
  homeBaseInfo: HomeBaseInfo = AppStorageV2.connect(HomeBaseInfo, () => new HomeBaseInfo())!;
  goodDataSource: GoodDataSource = new GoodDataSource();
  static _instance: HomeVM;

  static get instance() {
    if (HomeVM._instance) {
      return HomeVM._instance;
    }
    HomeVM._instance = new HomeVM();
    return HomeVM._instance;
  }

  init() {
    this.applyLocationPermission()
    this.queryHomeBaseInfo();
    this.queryGoodList();
    this.queryCategoryList();
  }

  applyLocationPermission() {
    SystemSceneUtils.applyLocationPermission().then((isGranted) => {
      if (isGranted) {
        SystemSceneUtils.getCurrentCityInfo().then((city: string) => {
          if (city) {
            this.updateCityCurrentInfo(city);
            this.updateCitySelectedInfo(city);
          }
        });
      }
    });
  }

  queryHomeBaseInfo() {
    getHomeInfo().then((resp) => {
      AppStorageBank.setHomeBaseInfo(resp);
    });
  }

  queryGoodList() {
    getGoodList(QueryGoodListSource.HOME).then((resp) => {
      this.goodDataSource.batchPushData(resp);
    });
  }

  queryCategoryList() {
    getAllCategoryServices().then((resp) => {
      AppStorageBank.setAllCategoryList(resp);
    });
  }

  updateCitySelectedInfo(city: string) {
    updateCitySelected(city).then(() => {
      AppStorageBank.updateCitySelected(city);
    });
  }

  updateCityCurrentInfo(city: string) {
    updateCurrentCity(city).then(() => {
      AppStorageBank.updateCityCurrent(city);
    });
  }
}