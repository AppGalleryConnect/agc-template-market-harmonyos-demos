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
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { goToAddressListPage } from 'address_management';
import { AtomicserviceLogin } from 'atomicservice_login';
import {
  CommonConstants,
  GoodDeTailSource,
  GridRowColSetting,
  IMenuItem,
  LinkState,
  LoginBtnInMine,
  LoginUtil,
  MY_ORDER_LIST,
  MY_TOOL_LIST,
  RouterModule,
  UserInfo,
} from 'lib_foundation';
import { GoodCard, GoodCardSize, IGoodInfo, RouterMap, WindowUtil } from 'module_base';
import { MineVM } from '../viewmodel/MineVM';

@ComponentV2
export struct Mine {
  @Local breakpoint: string = '';
  userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  linkState: LinkState = AppStorageV2.connect(LinkState, () => new LinkState())!;
  mineVM: MineVM = new MineVM();

  aboutToAppear(): void {
    WindowUtil.initWindowUtil(this.getUIContext());
    this.mineVM.init(this.getUIContext());
  }

  build() {
    NavDestination() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS, }) {
          Stack() {
            Scroll(this.mineVM.scroller) {
              Column() {
                Column() {
                  this.titleInside()
                  this.TopPersonInfo()
                  this.SubTitle('我的订单')
                  this.MineOrder()
                }
                .padding({
                  left: GridRowColSetting.getPageMargin(this.breakpoint),
                  right: GridRowColSetting.getPageMargin(this.breakpoint)
                })
                .linearGradient({
                  angle: 0,
                  colors: [['rgba(242, 204, 206, 0)', 0], ['rgba(242, 204, 206, 1)', 1]],
                })
                .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

                Column() {
                  this.SubTitle('服务与工具')
                  this.ToolCard()
                  this.SubTitle('为您推荐')
                  this.WaterFlowList()
                }
                .padding({
                  left: GridRowColSetting.getPageMargin(this.breakpoint),
                  right: GridRowColSetting.getPageMargin(this.breakpoint)
                })
              }
            }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT)
            .scrollBar(BarState.Off)
            .align(Alignment.Top)
            .edgeEffect(EdgeEffect.Spring)
            .onDidScroll(() => {
              this.mineVM.titleBgOpacity = this.mineVM.scroller.currentOffset().yOffset / 56;
            })

            this.titleBuilder()
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .alignContent(Alignment.Top)
        }
      }
      .onBreakpointChange((bp) => {
        this.breakpoint = bp;
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.common_page_bg'))
  }

  @Builder
  titleBuilder() {
    Row() {
      Text('我的').fontSize(26).fontWeight(FontWeight.Bold).height(56)
    }
    .padding({ left: 16, right: 16 })
    .width(CommonConstants.FULL_PERCENT)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .backgroundColor(Color.White)
    .opacity(this.mineVM.titleBgOpacity)
  }

  @Builder
  titleInside() {
    Text('我的')
      .fontSize(26)
      .fontWeight(FontWeight.Bold)
      .height(56)
      .alignSelf(ItemAlign.Start)
      .opacity(1 - 2 * this.mineVM.titleBgOpacity)
  }

  @Builder
  TopPersonInfo() {
    AtomicserviceLogin({
      userInfo: this.userInfo,
      isLink: this.linkState.isLink,
      bindPhone: (code: string | undefined) => {
        LoginUtil.bindPhone(code);
      },
      onGetPhoneError: () => {
        LoginUtil.onGetPhoneNumberFail();
      },
      unBindPhone: async (): Promise<void> => {
        LoginUtil.unBindPhone();
      }
    })
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(16)
      .margin({ top: 8 })
      .onClick(() => {
        if (!this.linkState.isLink) {
          promptAction.showToast({ message: '请先关联账户~' });
        } else {
          RouterModule.push({ url: RouterMap.EDIT_PERSONAL });
        }
      })
  }

  @Builder
  MineOrder() {
    Column() {
      Grid() {
        ForEach(MY_ORDER_LIST, (v: IMenuItem, index: number) => {
          GridItem() {
            Stack() {
              Column({ space: 4 }) {
                SymbolGlyph(v.imgUrl as Resource).fontSize(24)
                Text(v.textLabel)
                  .fontSize($r('sys.float.Caption_L'))
                  .fontWeight(FontWeight.Medium)
                  .height(16)
              }
              .onClick(() => {
                RouterModule.push({ url: RouterMap.MY_ORDER_LIST, param: index });
              })

              LoginBtnInMine({
                btnHeight: 44,
                btnWidth: '100%',
                fontSize: $r('sys.float.Caption_L'),
                onBind: () => {
                  RouterModule.push({ url: RouterMap.MY_ORDER_LIST, param: index });
                }
              })
                .visibility(this.linkState.isLink ? Visibility.None : Visibility.Visible)
            }
          }
        }, (v: IMenuItem) => v.imgUrl + v.textLabel)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({ top: 8, bottom: 8 })
    .borderRadius(16)
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ToolCard() {
    Column() {
      ForEach(MY_TOOL_LIST, (v: IMenuItem, index: number) => {
        Stack() {
          Row({ space: 16 }) {
            SymbolGlyph(v.imgUrl as Resource).fontSize(24)
            Column() {
              Row() {
                Text(v.textLabel)
                  .lineHeight(21)
                  .fontSize($r('sys.float.Subtitle_M'))
                  .fontWeight(FontWeight.Medium)
                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontColor([$r('sys.color.icon_fourth')])
                  .fontSize(24)
              }
              .margin({ top: 17, bottom: 17 })
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)

              if (index !== MY_TOOL_LIST.length - 1) {
                Divider().strokeWidth('1px')
              }
            }
            .height('100%')
            .layoutWeight(1)
          }
          .height(56)
          .onClick(() => {
              v.textLabel === '地址管理' ? goToAddressListPage(RouterModule.getStack()) :
                RouterModule.push({ url: v.routerUrl! });
          })
          LoginBtnInMine({
            btnHeight: 56,
            btnWidth: '100%',
            fontSize: $r('sys.float.Subtitle_M'),
            onBind: () => {
              v.textLabel === '地址管理' ? goToAddressListPage(RouterModule.getStack()) :
                RouterModule.push({ url: v.routerUrl! });
            }
          })
            .visibility(this.linkState.isLink ? Visibility.None : Visibility.Visible)
        }
      }, (item: IMenuItem) => item.imgUrl + item.textLabel)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: 4,
      bottom: 4,
      right: 12,
      left: 12
    })
    .borderRadius(16)
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  WaterFlowList() {
    WaterFlow() {
      LazyForEach(this.mineVM.goodDataSource, (v: IGoodInfo, index: number) => {
        FlowItem() {
          GoodCard({
            goodInfo: v,
            type: GoodCardSize.SMALL,
            onCardClick: () => {
              this.mineVM.pushToGoodsDetail(GoodDeTailSource.MINE_CARD + index, v);
            },
          })
            .id(GoodDeTailSource.MINE_CARD + index)
        }
        .width(CommonConstants.FULL_PERCENT)
        .onAppear(() => {
          this.mineVM.preloadData(index);
        })
      }, (v: IGoodInfo) => v.id.toString() + v.subIndex)
    }
    .cachedCount(10)
    .columnsTemplate(this.breakpoint === 'sm' ? '1fr 1fr' : '1fr 1fr 1fr 1fr')
    .columnsGap(this.breakpoint === 'sm' ? 8 : 16)
    .rowsGap(this.breakpoint === 'sm' ? 8 : 16)
    .width(CommonConstants.FULL_PERCENT)
    .scrollBar(BarState.Off)
    .cachedCount(2)
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST,
    })
  }

  @Builder
  SubTitle(text: string) {
    Column() {
      Text(text)
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Bold)
        .lineHeight(24)
    }
    .width('100%')
    .height(56)
    .padding({ top: 24, bottom: 8 })
    .alignItems(HorizontalAlign.Start)
  }
}