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
import { AppStorageBank, CommonConstants, HomeBaseInfo, RecentVisitList, UIEmpty } from 'utils';
import { SingleBtn } from '../components/SingleBtn';
import { Utils } from '../common/Utils';
import { ALL_CITY_LIST, HOT_CITY_LIST } from '../common/Constant';
import { CitySearchController, ICityGroup } from '../common/Model';

@ComponentV2
export struct UICitySelect {
  @Param controller: CitySearchController = new CitySearchController();
  @Event goBack: (city?: string) => void = () => {
  };
  @Event syncShowSearchRsp: (isShow: boolean) => void = () => {
  };
  homeBaseInfo: HomeBaseInfo = AppStorageV2.connect(HomeBaseInfo, () => new HomeBaseInfo())!;
  recentVisitList: RecentVisitList = AppStorageV2.connect(RecentVisitList, () => new RecentVisitList())!;
  @Local showSearchRsp: boolean = false;
  @Local searchKey: string = '';
  @Local searchList: string[] = [];
  @Local selectIndex: number = 0;
  @Local isLoading: boolean = false;
  scrollerOut: Scroller = new Scroller();
  scroller: Scroller = new Scroller();
  alphaIndexList: string[] = Utils.generateAlphaList(ALL_CITY_LIST);
  flatList: string[] = [];

  aboutToAppear(): void {
    this.controller.clearParam = () => {
      this.searchKey = '';
      this.searchList = [];
      this.showSearchRsp = false;
      this.syncShowSearchRsp(this.showSearchRsp);
    };

    this.flatList = ALL_CITY_LIST.reduce((acc, obj) => {
      return acc.concat(obj.list);
    }, ['']);
  }

  build() {
    Stack() {
      Scroll(this.scrollerOut) {
        Column() {
          this.TopSearch()
          Stack() {
            Column() {
              Column({ space: 20 }) {
                this.CurrentLocation()
                this.RecentVisit()
                this.HotCityList()
              }
              .padding({ left: 10, right: 10 })

              this.ListDivider()
              this.AllCityList()
            }
            .alignItems(HorizontalAlign.Start)

            if (this.showSearchRsp) {
              this.SearchRsp()
            }
          }
          .alignContent(Alignment.Top)
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      if (!this.showSearchRsp) {
        this.AlphaIndex()
      }
    }
    .alignContent(Alignment.End)
    .padding({ bottom: 10 })
  }

  onClickCity(city: string) {
    this.goBack(city);
    AppStorageBank.updateRecentVisitList(city);
  }

  @Builder
  AlphaIndex() {
    AlphabetIndexer({ arrayValue: this.alphaIndexList, selected: this.selectIndex })
      .usingPopup(true)// 是否显示弹出框
      .alignStyle(IndexerAlign.Right)// 弹出框在索引条左侧弹出
      .padding({ right: 4 })
      .onSelect((tabIndex: number) => {
        this.scrollerOut.scrollEdge(Edge.Bottom);
        this.scroller.scrollToIndex(tabIndex);
      })
  }

  @Builder
  TopSearch() {
    Row({ space: 10 }) {
      Search({ value: $$this.searchKey, placeholder: '请输入名称或首字母查询' }).layoutWeight(1)
        .onClick(() => {
          this.showSearchRsp = true;
          this.syncShowSearchRsp(this.showSearchRsp);
        })
        .onChange(() => {
          if (!this.searchKey) {
            this.searchList = [];
            return;
          }
          this.searchList = this.flatList.filter(v => v.includes(this.searchKey));
        })

      Text('取消')
        .fontSize(14)
        .fontColor(Color.Black)
        .onClick(() => {
          this.goBack();
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(66)
    .padding({ left: 10, right: 10, bottom: 10 })
  }

  @Computed
  get emptyLabel() {
    if (this.searchKey && this.searchList.length === 0) {
      return '暂未查询相关城市信息';
    }
    return '输入关键词查找结果';
  }

  @Builder
  SearchRsp() {
    Scroll() {
      Column() {
        if (!this.searchList.length) {
          UIEmpty({ emptyDesc: this.emptyLabel }).margin({ top: 200 })
        } else {
          ForEach(this.searchList, (item: string) => {
            Column() {
              Text(item).height(40).onClick(() => {
                this.onClickCity(item);
              })
              Divider()
            }
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(Color.White)
          }, (v: string) => v)
        }
      }
    }
    .padding({ left: 10, right: 10 })
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
    .height('calc(100% - 66vp)')
    .backgroundColor(Color.White)

  }

  @Builder
  CurrentLocation() {
    Column({ space: 10 }) {
      Text('当前定位').fontSize(14).fontWeight(500)
      Row() {
        SingleBtn({
          city: this.homeBaseInfo.currentCity || '无法获取',
          fgColor: $r('app.color.common_theme_color'),
          onClickEvent: () => {
            if (this.homeBaseInfo.currentCity) {
              this.onClickCity(this.homeBaseInfo.currentCity);
            }
          },
        })

        Blank()
        if (this.isLoading) {
          LoadingProgress().width(24).height(24).color($r('app.color.common_theme_color')).margin({ left: 10 })
        } else {
          Text('重新定位')
            .fontSize(14)
            .fontColor($r('app.color.common_theme_color'))
            .onClick(() => {
              this.isLoading = true;
              Utils.applyLocationPermission().then(() => {
                this.isLoading = false;
              });
            })
        }

      }
      .width(CommonConstants.FULL_PERCENT)
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  RecentVisit() {
    Column({ space: 10 }) {
      Text('最近访问').fontSize(14).fontWeight(500)
      Grid() {
        ForEach(this.recentVisitList.list.slice(0, 8), (item: string) => {
          GridItem() {
            SingleBtn({
              city: item,
              onClickEvent: () => {
                this.onClickCity(item);
              },
            })
          }
        }, (v: string) => v)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(10)
      .rowsGap(10)
      .padding({ right: 40 })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  HotCityList() {
    Column({ space: 10 }) {
      Text('热门城市').fontSize(14).fontWeight(500)

      Grid() {
        ForEach(HOT_CITY_LIST, (item: string) => {
          GridItem() {
            SingleBtn({
              city: item,
              onClickEvent: () => {
                this.onClickCity(item);
              },
            })
          }
        }, (v: string) => v)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(10)
      .rowsGap(10)
      .padding({ right: 40, bottom: 20 })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ListDivider() {
    Row().width(CommonConstants.FULL_PERCENT).height(8).backgroundColor($r('app.color.common_page_bg'))
  }

  @Builder
  AllCityList() {
    Column() {
      Text('城市列表').fontSize(14)
        .fontWeight(500)
        .height(36)
      List({
        space: 10,
        scroller: this.scroller,
      }) {
        ForEach(ALL_CITY_LIST, (item: ICityGroup) => {
          ListItem() {
            Column() {
              Text(item.name).fontSize(14).fontWeight(500)
              ForEach(item.list, (city: string) => {
                Column() {
                  Text(city)
                    .width(CommonConstants.FULL_PERCENT)
                    .height(40)
                    .fontSize(14)
                    .fontWeight(400)
                    .onClick(() => {
                      this.onClickCity(city);
                    })
                  Divider()
                }
              }, (v: string) => v)
            }
            .alignItems(HorizontalAlign.Start)
          }
        }, (item: ICityGroup) => item.name)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height('calc(100% - 36vp)')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST,
      })
      .onScrollIndex((start: number) => {
        this.selectIndex = start;
      })
    }
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 10, right: 10 })
  }
}
