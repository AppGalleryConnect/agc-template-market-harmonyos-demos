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
import { PreferenceUtil, PreferConstant, TopBar, RouterMap, RouterModule, GlobalContextUtils } from 'commonlib';

@ComponentV2
export struct MyWrongItem {
  @Event changeCollectionItem: (idx: number) => void = () => {
  };
  @Param @Require item: WrongModel;
  @Param @Require isSelectDelete: boolean;
  @Param @Require idx: number;

  build() {
    Column() {
      // 单选
      this.singleChoiceBuilder();
      // 错题标题
      this.titleBuilder();
    }
    .alignItems(HorizontalAlign.Start)
    .padding($r('app.float.vp_16'))
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius($r('app.float.vp_16'))
    .margin({ bottom: $r('app.float.vp_8') })
    .width('100%');
  }

  /**
   * 错题标题
   */
  @Builder
  titleBuilder() {
    Text(this.item.title)
      .fontColor($r('sys.color.font_primary'))
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(FontWeight.Regular)
      .lineHeight($r('app.float.vp_20'))
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis });
  }

  /**
   * 单选
   */
  @Builder
  singleChoiceBuilder() {
    Row() {
      Text($r('app.string.single_choice'))
        .textAlign(TextAlign.Center)
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Caption_L'))
        .fontWeight(FontWeight.Regular)
        .margin({ bottom: $r('app.float.vp_4') })
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_24'))
        .borderRadius($r('app.float.vp_8'))
        .backgroundColor('#4c5dc5');
      // 是否删除按钮
      Row() {
        Image(this.item.isDelete ? $r('app.media.icon_Checked') : $r('app.media.icon_ans_common'))
          .width($r('app.float.vp_20'))
          .height($r('app.float.vp_20'));
      }
      .width($r('app.float.vp_50'))
      .height($r('app.float.vp_24'))
      .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.None)
      .justifyContent(FlexAlign.End)
      .onClick(() => {
        this.changeCollectionItem(this.idx);
      });
    }.width('100%')
    .justifyContent(FlexAlign.SpaceBetween);
  }
}

@ComponentV2
export struct MyWrongIndexPage {
  @Local isSelectDelete: boolean = false;
  @Local wrongQues: WrongModel[] = [];
  wrongArr: TopicItemType[] = [];
  @Local isSelectAll: boolean = false;
  @Local selectCount: number = 0;
  @Local swipeDelete: boolean = false;

  aboutToAppear(): void {
    this.initData();
  }

  @Builder
  topBuilder() {
    Row() {
      // 我的错题
      TopBar({
        onClickBack: () => {
          RouterModule.pop();
        },
        title: $r('app.string.my_wrong')
      });
      Row() {
        Image($r('app.media.ic_public_trash'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .opacity(this.swipeDelete || !this.selectCount ? 0.4 : 1)
          .margin({ left: $r('app.float.vp_8') })
          .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.Hidden)
          .onClick(() => {
            // 删除选中
            if (this.selectCount === 0) {
              return;
            }
            this.confirmDialog(() => {
              this.deleteSelectData();
            })
          });

        Image($r('app.media.ic_edit'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .visibility(this.isSelectDelete ? Visibility.None : Visibility.Visible)
          .onClick(() => {
            if (!this.swipeDelete && this.wrongQues.length > 0) {
              this.isSelectDelete = !this.isSelectDelete;
              this.selectCount = 0;
              this.isSelectAll = false;
              this.wrongQues.forEach((item: WrongModel) => {
                item.isDelete = false;
              });
            }
          });

        Image(!this.isSelectAll ? $r('app.media.icon_select_all_off') : $r('app.media.icon_select_all'))
          .height($r('app.float.vp_40'))
          .width($r('app.float.vp_40'))
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
  itemEndComponent(idx: number) {
    Row() {
      Image($r('app.media.ic_public_trash_red'))
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .margin({ left: $r('app.float.vp_12') })
        .onClick(() => {
          this.selectCount = 1;
          this.swipeDelete = false;
          this.confirmDialog(() => {
            this.deleteData(idx);
          })
        });
    }
    .padding($r('app.float.vp_4'))
    .justifyContent(FlexAlign.SpaceEvenly);
  }

  build() {
    Column() {
      this.topBuilder();
      Column() {
        if (this.wrongQues.length <= 0) {
          Text('暂无错题记录')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.icon_secondary'))
            .height('100%');
        } else {
          // 错题列表
          this.wrongListBuilder();
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
   * 错题列表
   */
  @Builder
  wrongListBuilder() {
    Column() {
      List() {
        ForEach(this.wrongQues, (item: WrongModel, idx: number) => {
          ListItem() {
            MyWrongItem({
              isSelectDelete: this.isSelectDelete,
              item: item,
              changeCollectionItem: () => {
                item.isDelete = !item.isDelete;
                if (item.isDelete) {
                  this.selectCount++;
                } else {
                  this.selectCount--;
                }
                if (this.selectCount < this.wrongQues.length) {
                  this.isSelectAll = false;
                } else {
                  this.isSelectAll = true;
                }
              },
              idx: idx
            })
          }
          .transition({ type: TransitionType.Delete, opacity: 0 })
          .swipeAction({
            edgeEffect: SwipeEdgeEffect.None,
            end: {
              actionAreaDistance: 26,
              builder: () => {
                this.itemEndComponent(idx);
              },
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
            if (this.wrongArr.length > 0) {
              let routerModel: QuestionsRouterModel = new QuestionsRouterModel();
              routerModel.datalist = [this.wrongArr[idx]];
              routerModel.sourceType = '我的错题';
              RouterModule.push({ url: RouterMap.ANSWER_QUESTIONS_PAGE, param: routerModel });
            }
          });
        }, (item: WrongModel, idx: number) => JSON.stringify(item.keyID + idx + ''));
      }
      .clip(true)
      .margin({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), })
      .width('auto')
      .height('auto')
      .layoutWeight(1)
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true });
    }
    .layoutWeight(1)
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({
      top: $r('app.float.vp_12'),
    })
  }

  /**
   * 数据初始化
   */
  async initData() {
    try {
      let arr: TopicItemType[] =
        PreferenceUtil.getInstance().get(PreferConstant.ERROR_RECORDS, []) as TopicItemType[];
      arr.sort((a, b) => b.jlStamp - a.jlStamp);
      this.wrongArr = arr;
      if (arr && arr.length > 0) {
        arr.forEach((element: TopicItemType) => {
          let model: WrongModel = new WrongModel();
          model.isDelete = false;
          model.keyID = element.keyID;
          model.title = element.title;
          this.wrongQues.push(model);
        });
      }
      this.swipeDelete = this.wrongQues.length === 0;
    } catch (e) {
      this.wrongArr = [];
      this.wrongQues = [];
      this.swipeDelete = true;
    }
  }

  confirmDialog(confirmCallback: () => void) {
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
      onConfirm: confirmCallback
    })
  }

  // 移除
  deleteData(idx: number) {
    this.wrongQues.splice(idx, 1);
    this.swipeDelete = this.wrongQues.length === 0;
    this.wrongArr.splice(idx, 1);
    PreferenceUtil.getInstance().put(PreferConstant.ERROR_RECORDS, this.wrongArr);
  }

  // 移除所选中的
  deleteSelectData() {
    if (this.selectCount === 0) {
      return;
    }
    let arr: string[] = [];
    this.wrongQues.forEach((model: WrongModel) => {
      if (model.isDelete) {
        arr.push(model.keyID);
      }
    });
    this.wrongQues = this.wrongQues.filter((it: WrongModel) => !it.isDelete);
    this.wrongArr = this.wrongArr.filter((it: TopicItemType) => !arr.includes(it.keyID));
    PreferenceUtil.getInstance().put(PreferConstant.ERROR_RECORDS, this.wrongArr);
    if (this.wrongQues.length === 0) {
      this.isSelectDelete = false;
    }
    this.swipeDelete = this.wrongQues.length === 0;
  }

  // 是否全选
  isSelAll() {
    if (!this.isSelectAll) {
      this.wrongQues.forEach((item: WrongModel) => {
        item.isDelete = true;
      });
      this.isSelectAll = true;
      this.selectCount = this.wrongQues.length;
    } else {
      this.wrongQues.forEach((item: WrongModel) => {
        item.isDelete = false;
      });
      this.isSelectAll = false;
      this.selectCount = 0;
    }
  }
}

@Builder
export function MyWrongPageBuilder() {
  MyWrongIndexPage();
}

@ObservedV2
class WrongModel {
  title: string = '';
  keyID: string = '';
  @Trace isDelete: boolean = false;
}
