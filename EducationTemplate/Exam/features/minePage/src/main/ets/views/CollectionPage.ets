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

import { AppStorageV2, } from '@kit.ArkUI';
import { SampleCollectInfo, OrderInfo, Logger, TopBar, BreakpointType, RouterMap, RouterModule,
  PreferConstant,
  PreferenceUtil} from 'commonlib';
import { MineVM } from '../viewModel/MineVM';
import { TopicItemType } from 'answer_questions';
import { CollectionModel } from '../model/CollectionModel';
import { UIDialog } from '@hw-agconnect/ui-dialog';

const TAG = 'CollectionPage';

@ComponentV2
export struct CollectionPage {
  @Local isSelectDelete: boolean = false;
  @Local swiperDelete: boolean = false;
  @Local isSelectAll: boolean = false;
  @Local selectCount: number = 0;
  @Local isGoodCourse: boolean = true;
  @Local propCollect: SampleCollectInfo = AppStorageV2.connect(SampleCollectInfo, () => new SampleCollectInfo())!;
  collectionArr: TopicItemType[] = [];
  @Local collectionQues: CollectionModel[] = [];
  mineVM: MineVM = MineVM.instance;

  aboutToAppear(): void {
    this.initData();
  }

  aboutToDisappear(): void {
    Logger.info(TAG, 'aboutToDisappear');
  }

  /**
   * 数据初始化
   */
  initData() {
    try {
      let arr: TopicItemType[] =
        PreferenceUtil.getInstance().get(PreferConstant.EXAM_PREFER_COLLECT, []) as TopicItemType[];
      arr.sort((a, b) => b.jlStamp - a.jlStamp);
      this.collectionArr = arr;
      if (arr && arr.length > 0) {
        arr.forEach((element: TopicItemType) => {
          let model: CollectionModel = new CollectionModel();
          model.title = element.title;
          model.keyID = element.keyID;
          model.isDelete = false;
          this.collectionQues.push(model);
        });
      }
      this.swiperDelete = this.collectionQues.length === 0;
    } catch (e) {
      this.collectionArr = [];
      this.collectionQues = [];
      this.swiperDelete = true;
    }
  }

  build() {
    Column() {
      // 顶部
      this.topBuilder();
      Column() {
        // 精选好课、我的课程 标题
        this.tabBuilder();
        if(this.isGoodCourse) {
          if(this.propCollect.orderInfos.length > 0) {
            this.collectListBuilder();
          } else {
            Text('当前暂无收藏的课程。')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.icon_secondary'))
              .height('100%');
          }
        } else {
          if(this.collectionQues.length > 0) {
            this.examListBuilder();
          } else {
            Text('当前暂无收藏的题目。')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.icon_secondary'))
              .height('100%');
          }
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
    if(this.isGoodCourse) {
      this.propCollect.orderInfos = this.propCollect.orderInfos.filter((it: OrderInfo) => it.isDelete === false);
    } else {
      this.collectionQues = this.collectionQues.filter((it: CollectionModel) => it.isDelete === false);
      PreferenceUtil.getInstance().put(PreferConstant.EXAM_PREFER_COLLECT, this.collectionQues);
    }
    this.isSelectDelete = false;
  }

  // 是否全选
  isSelectAllClick() {
    if(this.isGoodCourse) {
      if (!this.isSelectAll) {
        this.propCollect.orderInfos.forEach((item: OrderInfo) => {
          item.isDelete = true;
        });
        this.selectCount = this.propCollect.orderInfos.length;
        this.isSelectAll = true;
      } else {
        this.propCollect.orderInfos.forEach((item: OrderInfo) => {
          item.isDelete = false;
        });
        this.selectCount = 0;
        this.isSelectAll = false;
      }
    } else {
      if (!this.isSelectAll) {
        this.collectionQues.forEach((item: CollectionModel) => {
          item.isDelete = true;
        });
        this.selectCount = this.collectionQues.length;
        this.isSelectAll = true;
      } else {
        this.collectionQues.forEach((item: CollectionModel) => {
          item.isDelete = false;
        });
        this.selectCount = 0;
        this.isSelectAll = false;
      }
    }
  }

  // 重置数据
  resetData() {
    this.isSelectDelete = false;
    this.swiperDelete = false;
    this.isSelectAll = false;
    this.selectCount = 0;
  }

  /**
   * 精选好课、我的课程 标题
   */
  @Builder
  tabBuilder() {
    Row() {
      Text('课程')
        .width('50%')
        .height('100%')
        .textAlign(TextAlign.Center)
        .backgroundColor(this.isGoodCourse ? $r('sys.color.comp_background_primary_contrary_secondary')
          : Color.Transparent)
        .opacity(this.isGoodCourse ? 1 : 0.7)
        .borderRadius(this.isGoodCourse ? 20 : 0)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          this.resetData();
          this.propCollect.orderInfos.forEach((item: OrderInfo) => {
            item.isDelete = false;
          });
          this.isGoodCourse = true;
        });
      Text('题目')
        .width('50%')
        .height('100%')
        .textAlign(TextAlign.Center)
        .backgroundColor(this.isGoodCourse ? Color.Transparent
          : $r('sys.color.comp_background_primary_contrary_secondary'))
        .opacity(this.isGoodCourse ? 0.7 : 1)
        .borderRadius(this.isGoodCourse ? 0 : 20)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          this.resetData();
          this.collectionQues.forEach((item: CollectionModel) => {
            item.isDelete = false;
          });
          this.isGoodCourse = false;
        });
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .width(328)
    .height($r('app.float.vp_36'))
    .borderRadius(20)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .margin({ top: $r('app.float.vp_16')});
  }

  /**
   * 收藏列表
   */
  @Builder
  collectListBuilder() {
    List({ space: 8 }) {
      ForEach(this.propCollect.orderInfos, ((item: OrderInfo, index: number) => {
        ListItem() {
          Column() {
            Row() {
              Image($r('app.media.ic_avatar'))
                .width($r('app.float.vp_24'))
                .margin({ right: '12vp' })
                .height($r('app.float.vp_24'));
              Text('华为用户')
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium);
              Blank();
              // 父组件 点击右上角删除按钮显示  否则不显示
              if (this.isSelectDelete) {
                Row() {
                  Image(item.isDelete ? $r('app.media.icon_Checked') : $r('app.media.icon_ans_common'))
                    .width($r('app.float.vp_20'))
                    .margin({ right: $r('app.float.vp_8') })
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
                  if (this.selectCount < this.propCollect.orderInfos.length) {
                    this.isSelectAll = false;
                  } else {
                    this.isSelectAll = true;
                  }
                });
              }
            }
            .padding({ left: '12vp' })
            .width('100%')
            .height('24vp');

            Column() {
              Row() {
                Text(item.content)
                  .width('100%')
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.Body_M'));
              }
              .width('100%')
              .margin({ top: '12vp', bottom: '2vp' })
              .justifyContent(FlexAlign.Start);

              Row() {
                Column() {
                  Text(`￥${item.price}`)
                    .fontSize($r('sys.float.Title_S'))
                    .fontColor($r('sys.color.multi_color_08'))
                    .textAlign(TextAlign.Start)
                    .fontWeight(FontWeight.Medium)
                    .width('100%');
                  Text(`已有 ${item.buyNumbers}人 购买`)
                    .fontSize($r('sys.float.Body_S'))
                    .fontWeight(FontWeight.Lighter)
                    .textAlign(TextAlign.Start)
                    .fontColor('rgb(2, 2, 3)')
                    .width('100%');
                }
                .justifyContent(FlexAlign.Start)
                .width('50%');

                Column() {
                  Row() {
                    Button('查看详情')
                      .fontSize($r('sys.float.Body_M'))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('app.color.system_color_background_white'))
                      .backgroundColor('#4B5CC4')
                      .fontWeight(FontWeight.Bold)
                      .onClick(() => {
                        RouterModule.push({ url: RouterMap.GOOD_COURSE_DETAIL_PAGE, param: item });
                      });
                  }.width('100%')
                  .justifyContent(FlexAlign.End);
                }
                .width('50%');
              }
              .height('auto')
              .width('100%');
            }
            .width('100%')
            .padding({ left: '24vp', right: '24vp' });
          }
          .borderRadius(16)
          .padding({ top: '16vp', bottom: '16vp' })
          .height('138vp')
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .width('100%');
        }
        .clip(true)
        .transition({ type: TransitionType.Delete, opacity: 0 })
        .swipeAction({
          edgeEffect: SwipeEdgeEffect.None,
          end: {
            builder: () => {
              this.collectItemEnd(index);
            },
            actionAreaDistance: 26,
            onStateChange: (state: SwipeActionState) => {
              if (state === SwipeActionState.EXPANDED) {
                this.swiperDelete = true;
                this.isSelectDelete = false;
              } else if (state === SwipeActionState.COLLAPSED) {
                this.swiperDelete = false;
              }
            },
          }
        });
      }), (item: OrderInfo, index: number) => item.orderNo + index);
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .padding({ top: '8vp'})
    .margin({ left: '12vp', right: '12vp' })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .lanes(new BreakpointType<number>({
      sm: 1,
      md: 2,
      lg: 3,
      xl: 3
    }).getValue(this.mineVM.breakPointModel.currentBreakpoint), 12);
  }

  @Builder
  examListBuilder() {
    List({ space: 8 }) {
      ForEach(this.collectionQues, ((item: CollectionModel, index: number) => {
        ListItem() {
          Column() {
            Row() {
              Text($r('app.string.single_choice'))
                .width($r('app.float.vp_40'))
                .height($r('app.float.vp_24'))
                .textAlign(TextAlign.Center)
                .borderRadius($r('app.float.vp_8'))
                .backgroundColor('#4c5dc5')
                .fontColor($r('sys.color.font_on_primary'))
                .fontSize($r('sys.float.Caption_L'))
                .fontWeight(FontWeight.Regular)
                .margin({ bottom: $r('app.float.vp_4') });
              Blank();
              // 父组件 点击右上角删除按钮显示  否则不显示
              if (this.isSelectDelete) {
                Row() {
                  Image(item.isDelete ? $r('app.media.icon_Checked') : $r('app.media.icon_ans_common'))
                    .width($r('app.float.vp_20'))
                    .margin({ right: $r('app.float.vp_8') })
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
                  if (this.selectCount < this.collectionQues.length) {
                    this.isSelectAll = false;
                  } else {
                    this.isSelectAll = true;
                  }
                });
              }
            }
            .padding({ left: '12vp' })
            .width('100%')
            .height('24vp');

            Row() {
              Text(item.title)
                .fontColor($r('sys.color.font_primary'))
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Regular)
                .maxLines(2)
                .lineHeight($r('app.float.vp_20'))
                .textOverflow({ overflow: TextOverflow.Ellipsis });
            }
            .width('100%')
            .padding({ left: '12vp' })
          }
          .borderRadius(16)
          .padding({ top: '16vp', bottom: '16vp', left: 12, right: 12 })
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .width('100%');
        }
        .clip(true)
        .transition({ type: TransitionType.Delete, opacity: 0 })
        .swipeAction({
          edgeEffect: SwipeEdgeEffect.None,
          end: {
            builder: () => {
              this.collectExamItemEnd(index);
            },
            actionAreaDistance: 26,
            onStateChange: (state: SwipeActionState) => {
              if (state === SwipeActionState.EXPANDED) {
                this.swiperDelete = true;
                this.isSelectDelete = false;
              } else if (state === SwipeActionState.COLLAPSED) {
                this.swiperDelete = false;
              }
            },
          }
        });
      }), (item: CollectionModel, index: number) => item.keyID + index);
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .padding({ top: '8vp'})
    .margin({ left: '12vp', right: '12vp' })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .lanes(new BreakpointType<number>({
      sm: 1,
      md: 2,
      lg: 3,
      xl: 3
    }).getValue(this.mineVM.breakPointModel.currentBreakpoint), 12);
  }

  @Builder
  collectItemEnd(index: number) {
    Row() {
      Image($r('app.media.ic_public_trash_red'))
        .margin({ left: $r('app.float.vp_12') })
        .height($r('app.float.vp_40'))
        .width($r('app.float.vp_40'))
        .onClick(() => {
          this.selectCount = 1;
          this.confirmDialog(() => {
            this.propCollect.orderInfos.splice(index, 1);
            this.selectCount = this.propCollect.orderInfos.length;
            this.swiperDelete = false;
          })
        });
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .padding($r('app.float.vp_4'));
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
        title: '我的收藏'
      });
      Row() {
        Image($r('app.media.ic_public_trash'))
          .height($r('app.float.vp_40'))
          .opacity((this.isGoodCourse && !this.propCollect.orderInfos.length ||
            !this.isGoodCourse && !this.collectionQues.length) || this.swiperDelete || !this.selectCount ? 0.4 : 1)
          .margin({ left: $r('app.float.vp_8') })
          .width($r('app.float.vp_40'))
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
            if(this.isGoodCourse) {
              if (!this.swiperDelete && this.propCollect.orderInfos.length > 0) {
                this.isSelectDelete = !this.isSelectDelete;
                if (!this.isSelectDelete) {
                  this.selectCount = 0;
                  this.isSelectAll = false;
                  this.propCollect.orderInfos.forEach((item: OrderInfo) => {
                    item.isDelete = false;
                  });
                }
              }
            } else {
              if (!this.swiperDelete && this.collectionQues.length > 0) {
                this.isSelectDelete = !this.isSelectDelete;
                if (!this.isSelectDelete) {
                  this.selectCount = 0;
                  this.isSelectAll = false;
                  this.collectionQues.forEach((item: CollectionModel) => {
                    item.isDelete = false;
                  });
                }
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
    }
    .width('100%')
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), top: $r('app.float.vp_10') })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM]);
  }

  @Builder
  collectExamItemEnd(index: number) {
    Row() {
      Image($r('app.media.ic_public_trash_red'))
        .margin({ left: $r('app.float.vp_12') })
        .height($r('app.float.vp_40'))
        .width($r('app.float.vp_40'))
        .onClick(() => {
          this.selectCount = 1;
          this.confirmDialog(() => {
            this.collectionQues.splice(index, 1);
            this.selectCount = this.collectionQues.length;
            this.swiperDelete = false;
          })
        });
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .padding($r('app.float.vp_4'));
  }
}

@Builder
export function CollectionBuilder() {
  CollectionPage();
}




