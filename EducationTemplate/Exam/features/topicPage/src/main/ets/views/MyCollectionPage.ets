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
import { QuestionsRouterModel, TopicItemType } from 'answer_questions';
import { PreferenceUtil, PreferConstant, TopBar, RouterMap, RouterModule } from 'commonlib';

@ComponentV2
export struct MyCollectionItem {
  @Event changeCollectionItem: (idx: number) => void = () => {
  };
  @Param @Require item: CollectionModel;
  @Param @Require isSelectDelete: boolean;
  @Param @Require idx: number;

  build() {
    Column() {
      Row() {
        // 单选
        this.singleChoiceBuilder();
        // 父组件 点击右上角删除按钮显示  否则不显示
        this.deleteStateButton();
      }.width('100%')
      .justifyContent(FlexAlign.SpaceBetween);

      // 收藏内容
      this.contentBuilder();
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding($r('app.float.vp_16'))
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius($r('app.float.vp_16'))
    .margin({ bottom: $r('app.float.vp_8') });
  }

  /**
   * 收藏内容
   */
  @Builder
  contentBuilder() {
    Text(this.item.title)
      .fontColor($r('sys.color.font_primary'))
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(FontWeight.Regular)
      .maxLines(2)
      .lineHeight($r('app.float.vp_20'))
      .textOverflow({ overflow: TextOverflow.Ellipsis });
  }

  /**
   * 是否删除按钮
   */
  @Builder
  deleteStateButton() {
    Row() {
      Image(this.item.isDelete ? $r('app.media.icon_Checked') : $r('app.media.icon_ans_common'))
        .height($r('app.float.vp_20'))
        .width($r('app.float.vp_20'));
    }
    .height($r('app.float.vp_24'))
    .width($r('app.float.vp_50'))
    .justifyContent(FlexAlign.End)
    .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.None)
    .onClick(() => {
      this.changeCollectionItem(this.idx);
    });
  }

  /**
   * 单选
   */
  @Builder
  singleChoiceBuilder() {
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
  }
}

@ComponentV2
export struct MyCollectionPage {
  @Local isSelectDelete: boolean = false;
  @Local collectionQues: CollectionModel[] = [];
  // 收藏集合
  collectionArr: TopicItemType[] = [];
  @Local isSelectAll: boolean = false;
  @Local selectCount: number = 0;
  @Local swipeDelete: boolean = false;

  aboutToAppear(): void {
    this.initData();
  }

  /**
   * 顶部
   */
  @Builder
  topBuilder() {
    Row() {
      // 我的收藏
      TopBar({
        onClickBack: () => {
          RouterModule.pop();
        },
        title: $r('app.string.my_collection')
      });
      Row() {
        Image($r('app.media.ic_public_trash'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .opacity(this.swipeDelete || this.selectCount === 0 ? 0.4 : 1)
          .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.Hidden)
          .onClick(() => {
            this.deleteSelectData()
          })

        Image($r('app.media.ic_edit'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .visibility(this.isSelectDelete ? Visibility.None : Visibility.Visible)
          .onClick(() => {
            if (!this.swipeDelete && this.collectionQues.length > 0) {
              this.isSelectDelete = !this.isSelectDelete;
              this.selectCount = 0;
              this.isSelectAll = false;
              this.collectionQues.forEach((item: CollectionModel) => {
                item.isDelete = false;
              });
            }
          });

        Image(!this.isSelectAll ? $r('app.media.icon_select_all_off') : $r('app.media.icon_select_all'))
          .height($r('app.float.vp_40'))
          .width($r('app.float.vp_40'))
          .margin({ left: $r('app.float.vp_8') })
          .onClick(() => {
            this.isSelAll();
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
  itemEnd(idx: number) {
    Row() {
      Image($r('app.media.ic_public_trash_red'))
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .margin({ left: $r('app.float.vp_12') })
        .onClick(() => {
          this.deleteData(idx);
          this.swipeDelete = false;
        });
    }
    .padding($r('app.float.vp_4'))
    .justifyContent(FlexAlign.SpaceEvenly);
  }

  build() {
    Column() {
      this.topBuilder();
      Column() {
        if (this.collectionQues.length <= 0) {
          Text('暂无收藏记录')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.icon_secondary'))
            .height('100%');
        } else {
          // 收藏列表
          this.collectionListBuilder();
        }
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('sys.color.comp_background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  /**
   * 收藏列表
   */
  @Builder
  collectionListBuilder() {
    Column() {
      List() {
        ForEach(this.collectionQues, (item: CollectionModel, idx: number) => {
          ListItem() {
            MyCollectionItem({
              item: item,
              isSelectDelete: this.isSelectDelete,
              changeCollectionItem: () => {
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
              },
              idx: idx
            })
          }
          .clip(true)
          .margin({
            left: $r('app.float.vp_16'),
            right: $r('app.float.vp_16'),
          })
          .transition({ type: TransitionType.Delete, opacity: 0 })
          .swipeAction({
            edgeEffect: SwipeEdgeEffect.None,
            end: {
              builder: () => {
                this.itemEnd(idx);
              },
              actionAreaDistance: 26,
              onStateChange: (state: SwipeActionState) => {
                if (state === SwipeActionState.EXPANDED) {
                  this.isSelectDelete = false;
                  this.swipeDelete = true;
                } else if (state === SwipeActionState.COLLAPSED) {
                  this.swipeDelete = false;
                }
              }
            }
          })
          .onClick(() => {
            if (this.collectionArr.length > 0) {
              let routerModel: QuestionsRouterModel = new QuestionsRouterModel();
              routerModel.sourceType = '我的收藏';
              routerModel.datalist = [this.collectionArr[idx]];
              RouterModule.push({ url: RouterMap.ANSWER_QUESTIONS_PAGE, param: routerModel });
            }
          });
        }, (item: CollectionModel, idx: number) => JSON.stringify(item.keyID + idx + ''));
      }
      .layoutWeight(1)
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false });
    }
    .padding({ top: $r('app.float.vp_12') })
    .layoutWeight(1)
    .backgroundColor($r('sys.color.background_secondary'))
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
      this.swipeDelete = this.collectionQues.length === 0;
    } catch (e) {
      this.collectionArr = [];
      this.collectionQues = [];
      this.swipeDelete = true;
    }
  }

  // 移除
  async deleteData(idx: number) {
    this.collectionQues.splice(idx, 1);
    this.swipeDelete = this.collectionQues.length === 0;
    this.collectionArr.splice(idx, 1);
    // 更新
    PreferenceUtil.getInstance().put(PreferConstant.EXAM_PREFER_COLLECT, this.collectionArr);
  }

  // 是否全选
  isSelAll() {
    if (!this.isSelectAll) {
      this.collectionQues.forEach((item: CollectionModel) => {
        item.isDelete = true;
      });
      this.isSelectAll = true;
      this.selectCount = this.collectionQues.length;
    } else {
      this.collectionQues.forEach((item: CollectionModel) => {
        item.isDelete = false;
      });
      this.isSelectAll = false;
      this.selectCount = 0;
    }
  }

  // 移除所选中的
  async deleteSelectData() {
    if (this.selectCount === 0) {
      return;
    }
    UIDialog.open({
      title: `是否删除${this.selectCount}条记录？`,
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
      onConfirm: () => {
        let arr: string[] = [];
        this.collectionQues.forEach((model: CollectionModel) => {
          if (model.isDelete) {
            arr.push(model.keyID);
          }
        });
        this.collectionArr = this.collectionArr.filter((it: TopicItemType) => !arr.includes(it.keyID));
        this.collectionQues = this.collectionQues.filter((it: CollectionModel) => !it.isDelete);
        // 更新
        PreferenceUtil.getInstance().put(PreferConstant.EXAM_PREFER_COLLECT, this.collectionArr);
        if (this.collectionQues.length === 0) {
          this.isSelectDelete = false;
        }
        this.swipeDelete = this.collectionQues.length === 0;
        this.selectCount = 0;
      }
    })
  }
}

@Builder
export function MyCollectionPageBuilder() {
  MyCollectionPage();
}

@ObservedV2
class CollectionModel {
  title: string = '';
  keyID: string = '';
  @Trace isDelete: boolean = false;
}