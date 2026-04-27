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
import { CategoryController, CategoryList } from 'category_list';
import {
  AppStorageBank,
  ClickId,
  CommonConstants,
  deleteHistoryList,
  getGood,
  getGuessList,
  getHistoryList,
  getResultList,
  getSearchSuggestion,
  GoodDeTailSource,
  GridRowColSetting,
  HomeBaseInfo,
  IJumpToDetailParam,
  JumpCategoryParam,
  RouterModule,
  updateCitySelected,
} from 'lib_foundation';
import { CommonUtils, IGoodCategory, IGoodInfo, RouterMap, WindowUtil } from 'module_base';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition';
import { PresentationType, SearchItem, SearchView, SearchViewController } from 'search';

@ComponentV2
export struct AllCategory {
  @Local breakpoint: string = '';
  @Local contentList: IGoodCategory[] = [];
  @Local homeBaseInfo: HomeBaseInfo = AppStorageV2.connect(HomeBaseInfo, () => new HomeBaseInfo())!;
  @Local clickId: ClickId = AppStorageV2.connect(ClickId, () => new ClickId())!;
  @Local jumpCategoryParam: JumpCategoryParam = AppStorageV2.connect(JumpCategoryParam, () => new JumpCategoryParam())!;
  controller: CategoryController = new CategoryController();
  searchController: SearchViewController = new SearchViewController();

  aboutToAppear(): void {
    WindowUtil.initWindowUtil(this.getUIContext());
    this.contentList = AppStorageBank.allCategoryList;
  }

  @Monitor('clickId.clickId')
  onChange(monitor: IMonitor) {
    this.controller.scrollToIndex(this.jumpCategoryParam.listInitialIndex);
  }

  build() {
    NavDestination() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS, }) {
          Column() {
            this.topBar()
            CategoryList({
              categoryTabs: this.contentList,
              initIndex: this.jumpCategoryParam.listInitialIndex,
              controller: this.controller,
              layoutType: 1,
              itemBuilderParam: this.itemBuilder,
              onItemClick: (itemDetail: IGoodInfo) => {
                this.pushToGoodsDetail(GoodDeTailSource.ALL_SERVICE + itemDetail.id, itemDetail);
              }
            })
              .layoutWeight(1)
              .width(CommonConstants.FULL_PERCENT)
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
        }
      }
      .onBreakpointChange((bp) => {
        this.breakpoint = bp;
      })
    }
    .onBackPressed(() => {
      return this.searchController.onBackPressed();
    })
    .title('全部服务', {
      paddingStart: { value: GridRowColSetting.getPageMargin(this.breakpoint), unit: 1 }
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  topBar() {
    Row({ space: 40 }) {
      Row({ space: 4 }) {
        Text(this.homeBaseInfo.citySelected)
          .fontSize(16)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: 92 })
        Image($r('app.media.ic_public_spinner_small')).width(10)
      }
      .width(108)
      .onClick(() => {
        RouterModule.push({
          url: RouterMap.CITY_SELECT_PAGE,
          onPop: (info: PopInfo) => {
            if (!info.result) {
              return;
            }
            updateCitySelected(info.result as string).then(() => {
              AppStorageBank.updateCitySelected(info.result as string);
            });
          },
        });
      })

      Row() {
        SearchView({
          componentId: GoodDeTailSource.ALL_SERVICE_SEARCH,
          presentationType: PresentationType.SEARCH_BOX,
          entranceText: ['保洁', '保姆月嫂', '维修'],
          routerStack: RouterModule.getStack(),
          showHotSearch: false,
          showFilterTag: false,
          controller: this.searchController,
          queryHistoryList: getHistoryList,
          queryGuessList: getGuessList,
          handleSearch: getResultList,
          searchSuggestion: getSearchSuggestion,
          deleteHistoryList: deleteHistoryList,
          onClickResultItem: async (listItem: SearchItem) => {
            const selectedGood = await getGood(listItem.id as string);
            this.pushToGoodsDetail(GoodDeTailSource.ALL_SERVICE_SEARCH + listItem.title, selectedGood);
          },
        })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
    }
    .padding({
      left: GridRowColSetting.getPageMargin(this.breakpoint),
      right: GridRowColSetting.getPageMargin(this.breakpoint)
    })
    .width(CommonConstants.FULL_PERCENT)
    .height(40)
    .margin({ top: 8 })
  }

  @Builder
  itemBuilder(item: IGoodInfo) {
    Row() {
      Image(CommonUtils.handleImgUrl(item.image))
        .width(80)
        .objectFit(ImageFit.Cover)
        .alt($r('app.media.ic_placeholder_img'))
        .aspectRatio(1)
        .borderRadius(8)
        .margin({ right: 8 })

      Column({ space: 4 }) {
        Text(item.title)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .width('100%')
        Text(item.subTitle)
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }
  }

  pushToGoodsDetail = (snapShotComponentId: string, goodInfo: IGoodInfo) => {
    const param: IJumpToDetailParam = { goodInfo: goodInfo };
    const longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(this.getUIContext(), snapShotComponentId, 9);
    if (longTakeTransitionParam) {
      param.longTakeTransitionParam = longTakeTransitionParam;
    }
    RouterModule.push({ url: RouterMap.GOOD_DETAIL, param: param });
  }
}
