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
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import {
  AppStorageBank,
  CommonUtils,
  HomeBaseInfo,
  IGoodCategory,
  IGoodInfo,
  RouterMap,
  RouterModule,
  updateCitySelected,
  CommonConstants,
  JumpCategoryParam,
} from 'utils'

@Builder
export function AllCategoryBuilder() {
  AllCategory()
}

@ComponentV2
export struct AllCategory {
  @Local contentList: IGoodCategory[] = [];
  homeBaseInfo: HomeBaseInfo = AppStorageV2.connect(HomeBaseInfo, () => new HomeBaseInfo())!;
  @Local jumpCategoryParam: JumpCategoryParam = AppStorageV2.connect(JumpCategoryParam, () => new JumpCategoryParam())!;
  @Local localScrollIndex: number = 0;
  listScroller: Scroller = new Scroller();

  @Monitor('jumpCategoryParam.listInitialIndex')
  onChange(monitor: IMonitor) {
    this.scrollToAssignIndex(this.jumpCategoryParam.listInitialIndex);
  }

  aboutToAppear(): void {
    this.localScrollIndex = this.jumpCategoryParam.listInitialIndex;
    this.queryAllServices();
  }

  queryAllServices() {
    this.contentList = AppStorageBank.allCategoryList;
  }

  scrollToAssignIndex(targetIndex: number) {
    this.localScrollIndex = targetIndex;
    this.listScroller.scrollToIndex(this.localScrollIndex);
  }

  build() {
    NavDestination() {
      Column() {
        this.TopBar()
        Row() {
          this.LeftMenu()
          this.MainContent()
        }
        .height('calc(100% - 40vp)')
        .padding({ top: 10 })
        .width(CommonConstants.FULL_PERCENT)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .title('全部服务', { backgroundColor: Color.White, paddingStart: new LengthMetrics(10) })
  }

  @Builder
  TopBar() {
    Row({ space: 10 }) {
      Row({ space: 4 }) {
        Text(this.homeBaseInfo.citySelected)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: 120 })
        Image($r('app.media.ic_public_spinner_small')).width(10)
      }
      .onClick(() => {
        RouterModule.push({
          url: RouterMap.CITY_LIST,
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

      Search({
        placeholder: '请输入你想要查找的',
      })
        .layoutWeight(1)
        .focusable(false)
        .onClick(() => {
          RouterModule.push({ url: RouterMap.SEARCH_PAGE });
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(40)
    .padding({ left: 10, right: 10 })
  }

  @Builder
  LeftMenu() {
    Scroll() {
      Column() {
        ForEach(this.contentList, (v: IGoodCategory, index: number) => {
          Text(v.categoryLabel)
            .fontSize(14)
            .fontWeight(500)
            .width(CommonConstants.FULL_PERCENT)
            .height(52)
            .textAlign(TextAlign.Center)
            .backgroundColor(index === this.localScrollIndex ? $r('app.color.common_page_bg') : null)
            .onClick(() => {
              this.scrollToAssignIndex(index);
            })
        }, (v: IGoodCategory) => v.categoryId)
      }
    }
    .width(90)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor(Color.White)
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
  }

  @Builder
  ListGroupHeader(v: IGoodCategory) {
    Text(v.categoryLabel)
      .fontSize(14)
      .fontWeight(400)
      .fontColor(Color.Black)
      .padding({ top: 10, bottom: 10 })
  }

  @Builder
  MainContent() {
    List({
      initialIndex: this.localScrollIndex,
      scroller: this.listScroller,
    }) {
      ForEach(this.contentList, (v: IGoodCategory) => {
        ListItemGroup({ header: this.ListGroupHeader(v) }) {
          ForEach(v.list, (good: IGoodInfo) => {
            ListItem() {
              Column() {
                Row({ space: 10 }) {
                  Image(CommonUtils.handleImgUrl(good.image))
                    .width(60)
                    .height(50)
                    .borderRadius(4)
                    .alt($r('app.media.ic_placeholder_img'))
                  Column({ space: 10 }) {
                    Text(good.title).fontSize(14).fontWeight(500)
                    Text(good.subTitle).fontSize(12).fontColor($r('app.color.common_grey'))
                  }
                  .alignItems(HorizontalAlign.Start)
                }
                .width(CommonConstants.FULL_PERCENT)
                .padding({ top: 10, bottom: 10 })
                .onClick(() => {
                  RouterModule.push({ url: RouterMap.GOOD_DETAIL, param: good });
                })

                Divider()
              }
            }
          }, (v: IGoodInfo) => v.id.toString() + v.subIndex)
        }
      }, (v: IGoodCategory) => v.categoryId)
    }
    .padding({ left: 10, right: 10 })
    .backgroundColor($r('app.color.common_page_bg'))
    .width('calc(100% - 90vp)')
    .height(CommonConstants.FULL_PERCENT)
    .onScrollIndex((start: number) => {
      this.localScrollIndex = start;
    })
  }
}
