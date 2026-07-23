/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { UIDialog } from '@hw-agconnect/ui-dialog';
import {
  BROWSING_HISTORY_DATA,
  BrowsingHistoryModel,
  Logger,
  TopBar,
  BreakpointType,
  RouterMap,
  RouterModule
} from 'commonlib';
import { UserInfo } from 'login_info';
import { MineVM } from '../viewModel/MineVM';

const TAG = 'BrowsingHistoryPage';

@ComponentV2
export struct BrowsingHistoryPage {
  @Local browsingHistoryModels: BrowsingHistoryModel[] = [];
  @Local historyModels: HistoryModel[] = [];
  @Local isSelectDelete: boolean = false;
  @Local swipeDelete: boolean = false;
  @Local isSelectAll: boolean = false;
  @Local selectCount: number = 0;
  // 获取用户信息
  private userInfo?: UserInfo = RouterModule.getNavParam({ url: RouterMap.BROWSING_HISTORY_PAGE });
  mineVM: MineVM = MineVM.instance;

  aboutToAppear(): void {
    Logger.info(TAG, 'aboutToAppear');
    this.browsingHistoryModels = BROWSING_HISTORY_DATA;
    //按照时间顺序由近及远
    this.browsingHistoryModels.sort((a, b) => b.browseTime - a.browseTime);
    this.browsingHistoryModels.forEach((item: BrowsingHistoryModel) => {
      let historyModel: HistoryModel = new HistoryModel();
      historyModel.keyID = item.keyID;
      historyModel.browseTime = item.browseTime;
      historyModel.routerRouter = item.routerRouter;
      historyModel.courseName = item.courseName;
      historyModel.isDelete = false;
      this.historyModels.push(historyModel);
    });
  }

  aboutToDisappear(): void {
    Logger.info(TAG, 'aboutToDisappear');
  }

  build() {
    Column() {
      // 顶部
      this.topBuilder();
      Column() {
        if (this.historyModels.length > 0) {
          // 浏览列表
          this.browseListBuilder();
        } else {
          Text('当前暂无课程的浏览记录。')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.icon_secondary'))
            .height('100%');
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM]);
  }

  confirmDialog(confirmCallback: () => void) {
    UIDialog.open({
      title: `是否删除${this.selectCount || 1}条记录？`,
      contentOptions: {
        content: '将在同账号其他设备的数据中同步删除',
        contentFontSize: 14,
        contentFontWeight: 400,
        contentFontColor: 'rgba(0, 0, 0, 0.9)'
      },
      confirmButtonOptions: {
        button: '删除',
        buttonFontColor: 'rgba(232, 64, 38, 1)',
      },
      cancelButtonOptions: {
        button: '取消',
        buttonFontColor: 'rgba(0, 0, 0, 0.9)',
      },
      showConfirmButton: true,
      showCancelButton: true,
      onConfirm: confirmCallback
    })
  }

  // 移除所选中的
  deleteSelectData() {
    this.historyModels = this.historyModels.filter((it: HistoryModel) => it.isDelete === false);
    this.isSelectDelete = false;
  }

  // 是否全选
  isSelectAllClick() {
    if (!this.isSelectAll) {
      this.historyModels.forEach((item: HistoryModel) => {
        item.isDelete = true;
      });
      this.isSelectAll = true;
      this.selectCount = this.historyModels.length;
    } else {
      this.historyModels.forEach((item: HistoryModel) => {
        item.isDelete = false;
      });
      this.isSelectAll = false;
      this.selectCount = 0;
    }
  }

  /**
   * 浏览列表
   */
  @Builder
  browseListBuilder() {
    List({ space: 8 }) {
      ForEach(this.historyModels, ((item: HistoryModel, index: number) => {
        ListItem() {
          Column() {
            Row() {
              Row() {
                Image((this.userInfo?.avatar && this.userInfo.avatar !== '') ? this.userInfo.avatar :
                  $r('app.media.path2x'))
                  .width($r('app.float.vp_24'))
                  .height($r('app.float.vp_24'))
                  .borderRadius($r('app.float.vp_24'));
                Text(this.userInfo?.name)
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_primary'))
                  .margin({ left: $r('app.float.vp_12') });
              };

              // 父组件 点击右上角删除按钮显示  否则不显示
              if (this.isSelectDelete) {
                Row() {
                  Image(item.isDelete ? $r('app.media.icon_Checked') : $r('app.media.icon_ans_common'))
                    .width($r('app.float.vp_20'))
                    .height($r('app.float.vp_20'));
                }
                .height($r('app.float.vp_24'))
                .onClick(() => {
                  item.isDelete = !item.isDelete;
                  if (item.isDelete) {
                    this.selectCount++;
                  } else {
                    this.selectCount--;
                  }
                  if (this.selectCount < this.historyModels.length) {
                    this.isSelectAll = false;
                  } else {
                    this.isSelectAll = true;
                  }
                });
              }
            }
            .padding({ top: $r('app.float.vp_4') })
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%');

            Text(item.courseName)
              .fontWeight(FontWeight.Medium)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'))
              .padding({ left: $r('app.float.vp_12'), top: $r('app.float.vp_12') })
              .width('100%');
          }
          .width('100%')
          .padding($r('app.float.vp_12'))
          .borderRadius($r('app.float.vp_16'))
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .onClick(() => {
            if (!this.isSelectDelete) {
              RouterModule.push({ url: item.routerRouter, param: item.courseName });
            }
          });
        }
        .clip(true)
        .transition({ type: TransitionType.Delete, opacity: 0 })
        .swipeAction({
          edgeEffect: SwipeEdgeEffect.None,
          end: {
            builder: () => {
              this.itemEnd(item, index);
            },
            actionAreaDistance: 26,
            onStateChange: (state: SwipeActionState) => {
              if (state === SwipeActionState.EXPANDED) {
                this.isSelectAll = false;
                this.selectCount = 0;
                this.isSelectDelete = false;
                this.swipeDelete = true;
                this.historyModels.forEach((item: HistoryModel) => {
                  item.isDelete = false;
                });
              } else if (state === SwipeActionState.COLLAPSED) {
                this.swipeDelete = false;
              }
            },
          }
        });
      }), (item: HistoryModel, index: number) => item.keyID + index);
    }
    .width('100%')
    .height('auto')
    .scrollBar(BarState.Off)
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
      top: $r('app.float.vp_20'),
      bottom: $r('app.float.vp_46')
    })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .lanes(new BreakpointType<number>({
      sm: 1,
      md: 2,
      lg: 3,
      xl: 3
    }).getValue(this.mineVM.breakPointModel.currentBreakpoint), 12);
  }

  @Builder
  itemEnd(_item: HistoryModel, index: number) {
    Row() {
      Image($r('app.media.ic_public_trash_red'))
        .height($r('app.float.vp_40'))
        .width($r('app.float.vp_40'))
        .margin({ left: $r('app.float.vp_12') })
        .onClick(() => {
          this.confirmDialog(() => {
            this.historyModels.splice(index, 1);
            this.swipeDelete = false;
          })
        });
    }.padding($r('app.float.vp_4')).justifyContent(FlexAlign.SpaceEvenly);
  }

  /**
   * 顶部
   */
  @Builder
  topBuilder() {
    Row() {
      // 浏览记录
      TopBar({
        onClickBack: () => {
          RouterModule.pop();
        },
        title: $r('app.string.browsing_history')
      });
      Row() {
        Image($r('app.media.ic_public_trash'))
          .height($r('app.float.vp_40'))
          .width($r('app.float.vp_40'))
          .opacity(this.historyModels.length === 0 || this.swipeDelete || !this.selectCount ? 0.4 : 1)
          .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.Hidden)
          .onClick(() => {
            if (this.selectCount > 0) {
              // 删除选中
              this.confirmDialog(() => {
                this.deleteSelectData()
              })
            }
          })

        Image($r('app.media.ic_edit'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .visibility(this.isSelectDelete ? Visibility.None : Visibility.Visible)
          .onClick(() => {
            if (!this.swipeDelete && this.historyModels.length > 0) {
              this.isSelectDelete = !this.isSelectDelete;
              if (!this.isSelectDelete) {
                this.selectCount = 0;
                this.isSelectAll = false;
                this.historyModels.forEach((item: HistoryModel) => {
                  item.isDelete = false;
                });
              }
            }
          });

        Image(this.isSelectAll ? $r('app.media.icon_select_all') : $r('app.media.icon_select_all_off'))
          .height($r('app.float.vp_40'))
          .width($r('app.float.vp_40'))
          .margin({ left: $r('app.float.vp_8') })
          .onClick(() => {
            this.isSelectAllClick();
          })
          .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.None);
      }
      .onClick(() => {
      });
    }
    .width('100%')
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), top: $r('app.float.vp_10') })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM]);
  }
}

@Builder
export function BrowsingHistoryBuilder() {
  BrowsingHistoryPage();
}

@ObservedV2
class HistoryModel {
  // 记录ID
  keyID: string = '';
  // 浏览时间
  browseTime: number = 0;
  // 课程路由
  routerRouter: string = '';
  // 课程名称
  courseName: string = '';
  // 是否删除
  @Trace isDelete: boolean = false;
}

