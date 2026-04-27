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
import { BrandPageVM } from '../viewmodel/BrandPageVM';
import { BrandGroupItem, BrandNameInfo, BrandParam } from '../model/Index';
import { getInstance } from '../components/RouteModule';

@Builder
export function BrandPageBuilder() {
  BrandPage();
}

@ComponentV2
export struct BrandPage {
  vm: BrandPageVM = BrandPageVM.instance;
  scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.vm.keyWord = '';
    this.vm.getBrandList();
  }

  build() {
    NavDestination() {
      Row() {
        Row({ space: 8 }) {
          Image($r('app.media.ic_white_left'))
            .size({ height: 40, width: 40 }).onClick(() => {
            getInstance().pop();
          });

          Text('选择品牌')
            .fontSize(20)
            .width('50%')
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .fontColor($r('sys.color.white'))
            .fontWeight(FontWeight.Medium);
        };
      }
      .margin({ bottom: 8 })
      .height(56)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left: 12,
        right: 12,
      });

      Column() {
        Row() {
          Search({
            placeholder: '搜索',
            value: this.vm.keyWord,
          })
            .height(40)
            .width('100%')
            .searchIcon({ color: $r('sys.color.icon_on_secondary') })
            .placeholderColor($r('sys.color.font_on_secondary'))
            .placeholderFont({
              size: $r('sys.float.Body_L'),
              weight: FontWeight.Regular,
            })
            .fontColor($r('sys.color.font_on_secondary'))
            .backgroundColor('#1AFFFFFF')

            .onChange((res) => {
              this.vm.keyWord = res;
              this.vm.search();
            });
        }
        .padding({
          top: 8,
          left: 16,
          right: 16,
          bottom: 12,
        });

        Stack({ alignContent: Alignment.End }) {
          Column() {
            if (this.vm.totalBrand > 0) {
              List({ scroller: this.scroller }) {
                ForEach(this.vm.brandList, (item: BrandGroupItem, index) => {
                  ListItem() {
                    Column() {
                      ForEach(item.group, (val: BrandNameInfo, i) => {
                        Column() {
                          Text(val.name)
                            .fontSize($r('sys.float.Subtitle_M'))
                            .fontWeight(FontWeight.Medium)
                            .fontColor($r('sys.color.font_primary'));
                          Text(val.translation)
                            .fontSize($r('sys.float.Body_M'))
                            .fontWeight(FontWeight.Regular)
                            .fontColor($r('sys.color.font_secondary'));
                        }
                        .height(63)
                        .justifyContent(FlexAlign.SpaceBetween)
                        .padding({ top: 10, bottom: 10 })
                        .alignItems(HorizontalAlign.Start)
                        .width('100%')
                        .onClick(() => {
                          getInstance()
                            .pushPathByName('UserGuidePage', { name: val.name, brandId: val.brandId } as BrandParam);
                        });

                        Divider();
                      }, (val: BrandNameInfo) => val.brandId);
                    };
                  };
                }, (item: BrandGroupItem) => JSON.stringify(item));
              }.scrollBar(BarState.Off)
              .onScrollIndex((start: number) => {
                const alphabetIndex: number =
                  this.vm.alphabetArr.findIndex((item) => item === this.vm.brandList[start].firstName);
                if (alphabetIndex >= 0) {
                  this.vm.selectIndex = start;
                }
              });
            } else {
              Row() {
                Divider().width(40);
                Text('暂无数据').fontColor($r('sys.color.font_tertiary')).fontSize(14);
                Divider().width(40);
              }.margin({ top: 40 });
            }
          }.width('100%').height('100%').padding({ left: 28, right: 28, top: 8 });

          AlphabetIndexer({ arrayValue: this.vm.alphabetArr, selected: this.vm.selectIndex })
            .usingPopup(true)
            .alignStyle(IndexerAlign.Right)
            .padding({ right: 8 })
            .onSelect((index: number) => {
              this.scroller.scrollToIndex(this.vm.brandList.findIndex((item) => this.vm.alphabetArr[index] ===
              item.firstName));
            });
        }
        .backgroundColor($r('sys.color.background_primary'))
        .layoutWeight(1)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
      }.layoutWeight(1).expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
    }.hideTitleBar(true).backgroundColor($r('sys.color.background_emphasize'));
  }
}
