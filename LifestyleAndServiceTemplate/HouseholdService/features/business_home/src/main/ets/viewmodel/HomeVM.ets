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
import { AppStorageV2 } from '@kit.ArkUI';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import {
  AppPrivacyUtils,
  AppStorageBank,
  getAllCategoryServices,
  getGoodList,
  getHomeInfo,
  GoodDataSource,
  HomeBaseInfo,
  IJumpToDetailParam,
  LoginUtil,
  QueryGoodListSource,
  RouterModule,
  updateCitySelected,
  updateCurrentCity,
} from 'lib_foundation';
import { IGoodInfo, RouterMap, SystemSceneUtils } from 'module_base';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition';

const TAG = 'HomeVM';

@ObservedV2
export class HomeVM {
  @Trace privacyImpl: AppPrivacyUtils = AppPrivacyUtils.instance;
  // 横幅广告是否可见
  @Trace adVisibilityState: boolean = true;
  homeBaseInfo: HomeBaseInfo = AppStorageV2.connect(HomeBaseInfo, () => new HomeBaseInfo())!;
  goodDataSource: GoodDataSource = new GoodDataSource();
  uiContext: UIContext | undefined;
  static _instance: HomeVM;

  static get instance() {
    if (HomeVM._instance) {
      return HomeVM._instance;
    }
    HomeVM._instance = new HomeVM();
    return HomeVM._instance;
  }

  @Monitor('privacyImpl.agreeFlag')
  agreeFlagChange() {
    if (this.privacyImpl.agreeFlag) {
      Logger.info(TAG, 'user has agree the privacy, start silent login and apply permission');
      LoginUtil.silentLogin();
      this.applyLocationPermission();
    }
  }

  init(uiContext: UIContext) {
    this.uiContext = uiContext;
    this.agreeFlagChange();
    this.queryHomeBaseInfo();
    this.queryGoodList();
    this.queryCategoryList();
  }

  pushToGoodsDetail = (snapShotComponentId: string, goodInfo: IGoodInfo) => {
    const param: IJumpToDetailParam = { goodInfo: goodInfo };
    const longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(this.uiContext!, snapShotComponentId, 9);
    if (longTakeTransitionParam) {
      param.longTakeTransitionParam = longTakeTransitionParam;
    }
    RouterModule.push({ url: RouterMap.GOOD_DETAIL, param: param });
  }

  applyLocationPermission() {
    SystemSceneUtils.applyLocationPermission()
      .then((isGranted) => {
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