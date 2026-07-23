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
import {
  AdInfo,
  AppStorageBank,
  BreakpointNameEnum,
  CommonConstants,
  deleteHistoryList,
  getGood,
  getGuessList,
  getHistoryList,
  getResultList,
  getSearchSuggestion,
  GoodDeTailSource,
  GridRowColSetting,
  IMenuItem,
  LinkState,
  MENU_LIST,
  RouterModule,
  ServiceCard,
  WindowUtils
} from 'lib_foundation';
import { CommonUtils, IGoodInfo, RouterMap, TypeGood, WindowUtil } from 'module_base';
import { DialPanel } from 'dial_panel';
import { PresentationType, SearchItem, SearchView, SearchViewController } from 'search';
import { HomeVM } from '../viewmodel/HomeVM';
import { AdvertisementComponent } from '../components/Advertisement';


@ComponentV2
export struct HomePage {
  @Local breakpoint: BreakpointNameEnum = BreakpointNameEnum.SM;
  linkState: LinkState = AppStorageV2.connect(LinkState, () => new LinkState())!;
  homeVM: HomeVM = HomeVM.instance;
  controller: SearchViewController = new SearchViewController();
  private uiContext: UIContext = this.getUIContext();
  private dialPanel: DialPanel = new DialPanel(this.uiContext)

  aboutToAppear(): void {
    WindowUtil.initWindowUtil(this.getUIContext());
    this.homeVM.init(this.uiContext);
    this.homeVM.adVisibilityState = true;
  }

  build() {
    NavDestination() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS, }) {
          Column() {
            this.TopBar()
            Scroll() {
              Column() {
                this.Banner()
                this.Menus()
                this.ServiceList()
              }
            }
            .align(Alignment.Top)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
            .layoutWeight(1)
          }
          .margin({
            left: GridRowColSetting.getPageMargin(this.breakpoint),
            right: GridRowColSetting.getPageMargin(this.breakpoint)
          })
          .height(CommonConstants.FULL_PERCENT)
        }
      }
      .onBreakpointChange((bp) => {
        this.breakpoint = bp as BreakpointNameEnum;
      })
    }
    .padding({
      top: WindowUtils.windowTopPadding,
      bottom: [BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.breakpoint) ?
        WindowUtils.windowBottomPadding : 0,
    })
    .onBackPressed(() => {
      return this.controller.onBackPressed();
    })
    .title('首页', {
      paddingStart: { value: GridRowColSetting.getPageMargin(this.breakpoint), unit: 1 }
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  TopBar() {
    Row({ space: 40 }) {
      Row({ space: 4 }) {
        Text(this.homeVM.homeBaseInfo.citySelected)
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
            if (info.result) {
              const citySelected = info.result as string;
              this.homeVM.updateCitySelectedInfo(citySelected);
            }
          },
        });
      })

      Row() {
        SearchView({
          componentId: GoodDeTailSource.HOME_SEARCH,
          presentationType: PresentationType.SEARCH_BOX,
          entranceText: ['保洁', '保姆月嫂', '维修'],
          routerStack: RouterModule.getStack(),
          showHotSearch: false,
          showFilterTag: false,
          windowTopPadding: WindowUtils.windowTopPadding,
          windowBottomPadding: WindowUtils.windowBottomPadding,
          controller: this.controller,
          queryHistoryList: getHistoryList,
          queryGuessList: getGuessList,
          handleSearch: getResultList,
          searchSuggestion: getSearchSuggestion,
          deleteHistoryList: deleteHistoryList,
          onClickResultItem: async (listItem: SearchItem) => {
            const selectedGood = await getGood(listItem.id as string);
            this.homeVM.pushToGoodsDetail(GoodDeTailSource.HOME_SEARCH + listItem.title, selectedGood);
          },
        })
      }
      .width(180)
      .justifyContent(FlexAlign.End)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(CommonConstants.FULL_PERCENT)
    .height(40)
    .margin({ top: 8, bottom: 12 })
  }

  @Builder
  Banner() {
    Swiper() {
      if (this.homeVM.adVisibilityState) {
        AdvertisementComponent({ adId: AdInfo.AD_INFO })
      }

      ForEach(this.homeVM.homeBaseInfo.bannerGoods, (v: IGoodInfo, index: number) => {
        Image(CommonUtils.handleImgUrl(v.image))
          .imageStyle()
          .id(GoodDeTailSource.HOME_BANNER + index)
          .onClick(() => {
            this.homeVM.pushToGoodsDetail(GoodDeTailSource.HOME_BANNER + index, v);
          })
      }, (v: IGoodInfo) => v.id ?? '')
    }
    .itemSpace(this.breakpoint === BreakpointNameEnum.SM ? 0 : 12)
    .displayCount(this.breakpoint === BreakpointNameEnum.SM ? 1 : 2, true)
    .width(CommonConstants.FULL_PERCENT)
    .margin({ bottom: 12 })
    .autoPlay(true)
    .loop(true)
  }

  @Builder
  Menus() {
    Row() {
      ForEach(MENU_LIST, (item: IMenuItem) => {
        Column({ space: 8 }) {
          Button() {
            SymbolGlyph(item.imgUrl as Resource)
              .fontColor([$r('sys.color.icon_on_primary')])
              .fontSize(24)
          }
          .width(40)
          .height(40)
          .type(ButtonType.Circle)
          .backgroundColor(item.backgroundColor ?? Color.White)

          Text(item.textLabel)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(400)
        }
        .layoutWeight(1)
        .height(67)
        .onClick(() => {
          AppStorageBank.updateJumpCategoryParam(item.mainParam!);
        })
      }, (item: IMenuItem) => item.imgUrl + item.textLabel)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding(12)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
  }

  @Builder
  ServiceList() {
    Row() {
      Text('精选服务')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Bold)
        .fontFamily('HarmonyHeiTi')
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(56)
    .padding({ top: 24, bottom: 8, })

    List({ space: 12 }) {
      LazyForEach(this.homeVM.goodDataSource, (v: IGoodInfo, index: number) => {
        ListItem() {
          ServiceCard({
            goodInfo: v,
            onBtnClick: () => {
              if (v.type === TypeGood.PAY) {
                RouterModule.push({ url: RouterMap.ORDER_PAGE, param: v });
              } else {
                this.dialPanel
                  .setTitle('联系客服')
                  .setPhoneNumber(this.homeVM.homeBaseInfo.hotline)
                  .open();
              }
            },
            onCardClick: () => {
              this.homeVM.pushToGoodsDetail(GoodDeTailSource.HOME_SERVICE + index, v);
            },
          })
            .id(GoodDeTailSource.HOME_SERVICE + index)
        }
      }, (v: IGoodInfo) => v.id.toString() + v.subIndex)
      ListItem() {
        Text('--已经到底啦--').fontSize(14).height(40).width(CommonConstants.FULL_PERCENT).textAlign(TextAlign.Center)
      }
    }
    .lanes([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.breakpoint) ? 3 : 1, 12)
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

@Extend(Image)
function imageStyle() {
  .layoutWeight(1)
  .aspectRatio(16 / 9)
  .objectFit(ImageFit.Cover)
  .borderRadius(16)
}