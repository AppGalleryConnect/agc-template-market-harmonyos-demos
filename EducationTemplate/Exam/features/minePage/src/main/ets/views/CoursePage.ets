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
import { AppStorageV2, } from '@kit.ArkUI';
import {
  SampleOrderInfo, OrderInfo, Logger, TopBar, BreakpointType, RouterMap, RouterModule
} from 'commonlib';
import { MineVM } from '../viewModel/MineVM';

const TAG = 'CoursePage';

@ComponentV2
export struct CoursePage {
  @Local isSelectDelete: boolean = false;
  @Local swiperDel: boolean = false;
  @Local isSelectAll: boolean = false;
  @Local selectCount: number = 0;
  // 在AppStorageV2中创建一个key为Sample的键值对（如果存在，则返回AppStorageV2中的数据），并且和prop关联
  @Local propOrderInfo: SampleOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;
  mineVM: MineVM = MineVM.instance;

  aboutToDisappear(): void {
    Logger.info(TAG, 'aboutToDisappear');
  }

  build() {
    Column() {
      // 顶部
      this.topBuilder();
      Column() {
        if (this.propOrderInfo.orderInfos.length > 0) {
          // 我的课程列表
          this.orderInfosBuilder();
        } else {
          Text('当前暂无课程。')
            .fontColor($r('sys.color.icon_secondary'))
            .fontSize($r('sys.float.Body_S'))
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
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
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
    this.isSelectDelete = false;
    this.propOrderInfo.orderInfos = this.propOrderInfo.orderInfos.filter((it: OrderInfo) => it.isDelete === false);
  }

  deleteSingleData(index: number) {
    this.propOrderInfo.orderInfos.splice(index, 1);
    this.swiperDel = this.propOrderInfo.orderInfos.length === 0 ? true : false;
  }

  // 是否全选
  isSelectAllClick() {
    if (!this.isSelectAll) {
      this.propOrderInfo.orderInfos.forEach((item: OrderInfo) => {
        item.isDelete = true;
      });
      this.selectCount = this.propOrderInfo.orderInfos.length;
      this.isSelectAll = true;
    } else {
      this.propOrderInfo.orderInfos.forEach((item: OrderInfo) => {
        item.isDelete = false;
      });
      this.selectCount = 0;
      this.isSelectAll = false;
    }
  }

  /**
   * 我的课程列表
   */
  @Builder
  orderInfosBuilder() {
    List({ space: 8 }) {
      ForEach(this.propOrderInfo.orderInfos, ((item: OrderInfo, index: number) => {
        ListItem() {
          Column() {
            Row() {
              Image($r('app.media.ic_avatar'))
                .height($r('app.float.vp_24'))
                .width($r('app.float.vp_24'))
                .margin({ right: '12vp' });
              Text('华为用户')
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium);
              Blank();
              // 父组件 点击右上角删除按钮显示  否则不显示
              if (this.isSelectDelete) {
                Row() {
                  Image(item.isDelete ? $r('app.media.icon_Checked') : $r('app.media.icon_ans_common'))
                    .height($r('app.float.vp_20'))
                    .width($r('app.float.vp_20'))
                    .margin({ right: $r('app.float.vp_8') });
                }
                .height($r('app.float.vp_24'))
                .onClick(() => {
                  item.isDelete = !item.isDelete;
                  if (item.isDelete) {
                    this.selectCount++;
                  } else {
                    this.selectCount--;
                  }
                  if (this.selectCount < this.propOrderInfo.orderInfos.length) {
                    this.isSelectAll = false;
                  } else {
                    this.isSelectAll = true;
                  }
                });
              }
            }
            .height('24vp')
            .padding({ left: '12vp' })
            .width('100%');

            Column() {
              Row() {
                Text(item.content)
                  .fontSize($r('sys.float.Body_M'))
                  .width('100%')
                  .fontWeight(FontWeight.Medium);
              }
              .justifyContent(FlexAlign.Start)
              .width('100%')
              .margin({ top: '12vp', bottom: '2vp' });

              Row() {
                Column() {
                  Text(`￥${item.price}`)
                    .fontColor($r('sys.color.multi_color_08'))
                    .fontSize($r('sys.float.Title_S'))
                    .fontWeight(FontWeight.Medium)
                    .textAlign(TextAlign.Start)
                    .width('100%');
                  Text(`已有 ${item.buyNumbers}人 购买`)
                    .fontWeight(FontWeight.Lighter)
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor('rgb(2, 2, 3)')
                    .textAlign(TextAlign.Start)
                    .width('100%');
                }
                .justifyContent(FlexAlign.Start)
                .width('50%');

                Column() {
                  Row() {
                    Button('去学习')
                      .fontWeight(FontWeight.Medium)
                      .fontSize($r('sys.float.Body_M'))
                      .fontColor($r('app.color.system_color_background_white'))
                      .fontWeight(FontWeight.Bold)
                      .backgroundColor('#4B5CC4')
                      .onClick(() => {
                        RouterModule.push({ url: RouterMap.COURSE_INTRODUCTION_PAGE });
                      });
                  }.width('100%')
                  .justifyContent(FlexAlign.End);
                }
                .width('50%');
              }
              .width('100%')
              .height('auto');
            }
            .padding({ left: '24vp', right: '24vp' })
            .width('100%');
          }
          .padding({ top: '16vp', bottom: '16vp' })
          .borderRadius(16)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .height('138vp')
          .width('100%');
        }
        .clip(true)
        .transition({ type: TransitionType.Delete, opacity: 0 })
        .swipeAction({
          edgeEffect: SwipeEdgeEffect.None,
          end: {
            builder: () => {
              this.courseItemEnd(index);
            },
            actionAreaDistance: 26,
            onStateChange: (state: SwipeActionState) => {
              if (state === SwipeActionState.EXPANDED) {
                this.swiperDel = true;
                this.isSelectDelete = false;
              } else if (state === SwipeActionState.COLLAPSED) {
                this.swiperDel = false;
              }
            },
          }
        });
      }), (item: OrderInfo, index: number) => item.orderNo + index);
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .layoutWeight(1)
    .padding({
      top: $r('app.float.vp_12'),
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
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
  courseItemEnd(index: number) {
    Row() {
      Image($r('app.media.ic_public_trash_red'))
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .margin({ left: $r('app.float.vp_12') })
        .onClick(() => {
          this.selectCount = 1;
          this.confirmDialog(() => {
            this.deleteSingleData(index)
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
      TopBar({
        onClickBack: () => {
          RouterModule.pop();
        },
        title: '我的课程'
      });
      Row() {
        Image($r('app.media.ic_public_trash'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .opacity(this.propOrderInfo.orderInfos.length === 0 || this.swiperDel || !this.selectCount ? 0.4 : 1)
          .margin({ left: $r('app.float.vp_8') })
          .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.Hidden)
          .onClick(() => {
            if (this.selectCount === 0) {
              return;
            }
            this.confirmDialog(() => {
              this.deleteSelectData()
            })
          })

        Image($r('app.media.ic_edit'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .visibility(this.isSelectDelete ? Visibility.None : Visibility.Visible)
          .onClick(() => {
            if (!this.swiperDel && this.propOrderInfo.orderInfos.length > 0) {
              this.isSelectDelete = !this.isSelectDelete;

              this.isSelectAll = false;
              this.selectCount = 0;
              this.propOrderInfo.orderInfos.forEach((item: OrderInfo) => {
                item.isDelete = false;
              });
            }
          });

        Image(this.isSelectAll ? $r('app.media.icon_select_all') : $r('app.media.icon_select_all_off'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .margin({ left: $r('app.float.vp_8') })
          .onClick(() => {
            this.isSelectAllClick();
          })
          .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.None);

      }
    }
    .width('100%')
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), top: $r('app.float.vp_10') })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM]);
  }
}

@Builder
export function CoursePageBuilder() {
  CoursePage();
}




