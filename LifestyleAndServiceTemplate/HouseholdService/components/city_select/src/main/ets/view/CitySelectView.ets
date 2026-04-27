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
import { common } from '@kit.AbilityKit';
import { CityTags } from '../components/CityTags';
import { City, CityAlphaGroup, CitySelectController } from '../common/Model';
import { CitySelectViewModel } from '../viewmodel/CitySelectViewModel';
import { SearchViewModel } from '../viewmodel/SearchViewModel';
import { Constants } from '../common/Constant';
import { CityTagAndIcon } from '../components/CityTagAndIcon';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { setApplyLocPermAgain } from '../common/Location';

@ComponentV2
export struct CitySelect {
  @Event select: (city: City) => void;
  @Event cancel: () => void;
  @Event handleCurrentCity: (city: City) => void;
  @Require @Param cityList: City[] = [];
  @Param hotCityList: City[] = [];
  @Param controller: CitySelectController = new CitySelectController();
  citySelectVM = new CitySelectViewModel(this.cityList);
  searchVM = new SearchViewModel(this.cityList);
  context: Context | undefined = this.getUIContext().getHostContext();

  aboutToAppear(): void {
    setApplyLocPermAgain(false);
    this.searchVM.init();
    this.controller.onBackPressed = () => {
      if (this.searchVM.searchKey.length) {
        this.searchVM.searchKey = '';
        return true;
      }
      return false;
    }
    this.citySelectVM.getLocationCity(this.context as common.UIAbilityContext).then(currentCity => {
      if (currentCity) {
        this.handleCurrentCity(currentCity)
      }
    })
  }

  @Builder
  coreInfo() {
    Stack() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({
          span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
          offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
        }) {
          Column() {
            this.TopSearch()
            Stack() {
              Scroll(this.citySelectVM.scrollerOut) {
                Column() {
                  this.CurrentLocation()
                  if (this.citySelectVM.recentVisitList.length) {
                    this.RecentVisit()
                  }
                  if (this.hotCityList.length) {
                    this.HotCityList()
                  }
                  this.AllCityList()
                }
                .alignItems(HorizontalAlign.Start)
              }
              .width(Constants.FULL_PERCENT)
              .layoutWeight(1)
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Spring)

              if (this.searchVM.showSearchResult) {
                Column() {
                  Column()
                    .width(Constants.FULL_PERCENT)
                    .height(Constants.PADDING_S)
                    .backgroundColor($r('sys.color.background_secondary'))
                  this.SearchRsp()
                }
              }
            }
            .height(Constants.FULL_PERCENT)
            .alignContent(Alignment.Top)

          }
          .margin({ bottom: Constants.CITY_TAG_HEIGHT })
        }
      }
      .padding({
        left: GridRowColSetting.getPageMargin(this.citySelectVM.breakpoint),
        right: GridRowColSetting.getPageMargin(this.citySelectVM.breakpoint),
      })
      .onBreakpointChange((bp: string) => {
        this.citySelectVM.breakpoint = bp;
        if (bp === 'sm') {
          this.citySelectVM.columnsNum = 4;
          this.citySelectVM.maxVisitNum = 4;
          this.citySelectVM.buttonPadding = 8;
        } else if (bp === 'md') {
          this.citySelectVM.columnsNum = 8;
          this.citySelectVM.maxVisitNum = 8;
          this.citySelectVM.buttonPadding = 12;
        } else {
          this.citySelectVM.columnsNum = 8;
          this.citySelectVM.maxVisitNum = 8;
          this.citySelectVM.buttonPadding = 16;
        }
      })

      if (!this.searchVM.showSearchResult) {
        this.AlphaIndex()
      }
    }
    .layoutWeight(1)
    .alignContent(Alignment.End)
  }

  build() {
    Column() {
      this.coreInfo()
    }
    .height(Constants.FULL_PERCENT)
  }

  onClickCity(city: City) {
    this.citySelectVM.addVisitCity(city);
    this.select(city);
  }

  @Builder
  AlphaIndex() {
    AlphabetIndexer({ arrayValue: this.citySelectVM.alphaIndexList, selected: this.citySelectVM.selectIndex })
      .alignStyle(IndexerAlign.Right)
      .onSelect((tabIndex: number) => {
        this.citySelectVM.handleAlphaSelect(tabIndex);
      })
  }

  @Builder
  TopSearch() {
    Row() {
      Search({ value: $$this.searchVM.searchKey, placeholder: $r('app.string.input_city_name') })
        .placeholderFont({ size: $r('sys.float.Body_L') })
        .placeholderColor($r('sys.color.font_secondary'))
        .fontColor($r('sys.color.font_primary'))
        .layoutWeight(1)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.REGULAR_HEIGHT)
    .margin({ top: Constants.PADDING_S })
  }

  @Builder
  SearchRsp() {
    Scroll() {
      Column() {
        if (!this.searchVM.searchList.length) {
          Column({ space: Constants.SPACE_M }) {
            Image($r('app.media.search_no_result'))
              .width(Constants.IMG_SEARCH_WIDTH).height(Constants.IMG_SEARCH_WIDTH)
            Text(this.searchVM.emptyLabel)
              .fontColor($r('sys.color.font_secondary')).fontSize($r('sys.float.Body_M'))
          }
          .width(Constants.FULL_PERCENT)
          .layoutWeight(1)
          .margin({ top: Constants.MARGIN_TOP })
        } else {
          ForEach(this.searchVM.searchList, (item: City) => {
            Column() {
              Text(item.name)
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_primary'))
                .width(Constants.FULL_PERCENT)
                .height(Constants.TITLE_HEIGHT)
                .onClick(() => {
                  this.onClickCity(item);
                })
              Divider()
                .color($r('sys.color.comp_divider'))
            }
            .alignItems(HorizontalAlign.Start)
            .backgroundColor($r('sys.color.background_secondary'))
          }, (item: City) => item.name)
        }
      }
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .align(Alignment.Top)
    .height(Constants.FULL_PERCENT)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  CurrentLocation() {
    Column() {
      Row() {
        Text('定位')
          .textStyle()

        Row({ space: Constants.SPACE_XS }) {
          if (this.citySelectVM.isLoading) {
            LoadingProgress()
              .width(Constants.BACK_WIDTH).height(Constants.BACK_WIDTH)
          } else {
            SymbolGlyph($r('sys.symbol.arrow_clockwise'))
              .width(Constants.ICON_WIDTH)
              .height(Constants.ICON_WIDTH)
              .fontColor([$r('sys.color.icon_emphasize')])
            Text('重新定位')
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_emphasize'))
          }
        }
        .onClick(() => {
          this.citySelectVM.getLocationCity(this.context as common.UIAbilityContext).then(currentCity => {
            if (currentCity) {
              this.handleCurrentCity(currentCity)
            }
          })
        })
      }
      .padding({ top: Constants.PADDING_TITLE, bottom: Constants.PADDING_S })
      .justifyContent(FlexAlign.SpaceBetween)
      .width(Constants.FULL_PERCENT)
      .height(Constants.TITLE_HEIGHT)

      Row() {
        CityTagAndIcon({
          city: this.citySelectVM.currentCity.name || '无法获取',
        }).onClick(() => {
          if (this.citySelectVM.currentCity.name) {
            this.onClickCity(this.citySelectVM.currentCity);
          }
        })
      }
      .margin({ top: Constants.PADDING_XXS })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  RecentVisit() {
    Column() {
      Row() {
        Text('最近访问')
          .textStyle()
      }
      .padding({ top: Constants.PADDING_TITLE, bottom: Constants.PADDING_S })
      .justifyContent(FlexAlign.SpaceBetween)
      .width(Constants.FULL_PERCENT)
      .height(Constants.TITLE_HEIGHT)

      CityTags({
        columnsNum: this.citySelectVM.columnsNum,
        buttonPadding: this.citySelectVM.buttonPadding,
        cityList: this.citySelectVM.recentVisitList,
        selectCity: ((city: City) => {
          this.onClickCity(city);
        })
      })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  HotCityList() {
    Column() {
      Row() {
        Text('热门城市')
          .textStyle()
      }
      .padding({ top: Constants.PADDING_TITLE, bottom: Constants.PADDING_S })
      .justifyContent(FlexAlign.SpaceBetween)
      .width(Constants.FULL_PERCENT)
      .height(Constants.TITLE_HEIGHT)

      CityTags({
        columnsNum: this.citySelectVM.columnsNum,
        buttonPadding: this.citySelectVM.buttonPadding,
        cityList: this.hotCityList,
        selectCity: ((city: City) => {
          this.onClickCity(city);
        })
      })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  itemHead(text: string) {
    // 列表分组的头部组件，对应分组A、B等位置的组件
    Row() {
      Text(text)
        .textStyle()
    }
    .padding({ top: Constants.PADDING_TITLE, bottom: Constants.PADDING_S })
    .backgroundColor($r('sys.color.background_secondary'))
    .justifyContent(FlexAlign.SpaceBetween)
    .width(Constants.FULL_PERCENT)
    .height(Constants.TITLE_HEIGHT)
  }

  @Builder
  AllCityList() {
    Column() {
      List({
        scroller: this.citySelectVM.scroller,
      }) {
        ForEach(this.citySelectVM.cityAlphaGroupList, (item: CityAlphaGroup) => {
          ListItemGroup({ header: this.itemHead(item.name) }) {
            ForEach(item.list, (city: City) => {
              ListItem() {
                Column() {
                  Text(city.name)
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.font_primary'))
                    .width(Constants.FULL_PERCENT)
                    .height(Constants.TITLE_HEIGHT)
                    .onClick(() => {
                      this.onClickCity(city);
                    })
                  Divider()
                    .color($r('sys.color.comp_divider'))
                }
              }
            }, (item: City) => item.name)
          }
        }, (item: CityAlphaGroup) => item.name)
      }
      .sticky(StickyStyle.Header)
      .width(Constants.FULL_PERCENT)
      .height(Constants.FULL_PERCENT)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST,
      })
      .onScrollIndex((start: number) => {
        this.citySelectVM.handleScrollIndex(start);
      })
    }
    .alignItems(HorizontalAlign.Start)
  }
}

@Extend(Text)
function textStyle() {
  .fontSize($r('sys.float.Subtitle_M'))
  .fontWeight(FontWeight.Medium)
  .fontColor($r('sys.color.font_primary'))
}
