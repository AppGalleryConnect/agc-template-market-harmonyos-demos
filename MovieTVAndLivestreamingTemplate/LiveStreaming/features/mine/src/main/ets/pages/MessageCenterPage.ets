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

import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { MessageItem, NumbObj } from '../viewModel/MessageModel';
import { RouterMap, RouterModule } from '@agctemplate/router_module';
import { TopBar } from '../component/TopBar';
import { AppStorageKeys, BarVM, BreakPoint, BreakPointValue } from '@agctemplate/widgets';
import { SystemMsgList } from './SystemMessagePage';
import { NewFansList } from './NewFansMessagePage';

@Preview
@ComponentV2
export struct MessageCenterPage {
  // 在AppStorageV2中创建一个key为Sample的键值对（如果存在，则返回AppStorageV2中的数据），并且和prop关联
  @Local message: NumbObj = AppStorageV2.connect(NumbObj, () => new NumbObj())!;
  @Local systemMsgList: SystemMsgList = AppStorageV2.connect(SystemMsgList, () => new SystemMsgList())!
  @Local newFansList: NewFansList = AppStorageV2.connect(NewFansList, () => new NewFansList())!
  @Local breakPoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint())!;

  aboutToAppear(): void {
    const params = RouterModule.getNavParam<NumbObj>({ url: RouterMap.MESSAGE_CENTER_PAGE })
    if (params) {
      this.message = params
    }
    this.getMessageCount()
  }

  getMessageCount() {
    this.message.listArr[0].count = this.systemMsgList.listArr.filter(item => !item.isRead).length
    this.message.listArr[1].count = this.newFansList.listArr.filter(item => !item.isRead).length
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          if (this.message.listArr.length > 0) {
            // 我的课程列表
            this.MessageItemsBuilder()
          } else {
            Text('当前暂无消息。')
              .height('100%')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.icon_secondary'))
          }
        }
        .width(this.breakPoint.value === BreakPointValue.LG ? '70%' : '100%')
        .height('100%')
      }
      .padding({
        left: $r('app.float.vp_16'),
        right: $r('app.float.vp_16')
      })
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({
      top: BarVM.instance.staBarH,
    })
    .title('消息中心')
    .menus(this.FunctionButton())
    .onBackPressed(() => {
      RouterModule.pop('result')
      return true
    })
  }

  /**
   * 我的课程列表
   */
  @Builder
  MessageItemsBuilder() {
    List() {
      ForEach(this.message.listArr, ((item: MessageItem, index: number) => {
        ListItem() {
          Row() {
            Stack() {
              Image(item.icon)
                .width(48)
                .height(48)
              if (item.count > 0) {
                Text(item.count.toString())
                  .width(16)
                  .backgroundColor($r('sys.color.warning'))
                  .fontColor($r('sys.color.font_on_primary'))
                  .fontSize(10)
                  .fontWeight(400)
                  .height(16)
                  .borderRadius(100)
                  .position({ right: 0, top: 0 })
                  .textAlign(TextAlign.Center)
              }
            }
            .width(48).height(48).margin({ right: 12 })

            Row() {
              Row() {
                Column() {
                  Text(item.title)
                    .fontColor($r('sys.color.font_primary'))
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Regular)
                    .lineHeight(21)
                  Text(item.subtitle)
                    .fontColor($r('sys.color.font_secondary'))
                    .fontWeight(FontWeight.Regular)
                    .width($r('app.float.vp_170'))
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .fontSize($r('sys.float.Caption_L'))
                    .lineHeight(16)
                }
                .alignItems(HorizontalAlign.Start)

                Text(item.time)
                  .fontColor($r('sys.color.font_secondary'))
                  .fontSize($r('sys.float.Caption_M'))
                  .fontWeight(FontWeight.Regular)
                  .margin({ top: 2.5 })
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Top)
              .size({ height: 39, width: '100%' })
            }
            .layoutWeight(1)
            .height(64)
            .border({ width: { bottom: 0.5 }, color: $r('sys.color.comp_divider') })
          }
          .width('100%')
          .onClick(() => {
            RouterModule.push({
              url: item.url, onPop: () => {
                this.getMessageCount()
              }
            })
          })
        }
      }), (item: MessageItem, index: number) => item.id + index)
    }
    .width('100%')
    .scrollBar(BarState.Off)

  }

  @Builder
  courseItemEnd(index: number) {
    Row() {
      Image($r('app.media.ic_public_trash_red'))
        .width($r('app.float.vp_24'))
        .margin({ left: $r('app.float.vp_12') })
        .height($r('app.float.vp_24'))
        .onClick(() => {
          this.message.listArr.splice(index, 1)
        })
    }.padding($r('app.float.vp_4')).justifyContent(FlexAlign.SpaceEvenly)
  }

  /**
   * 顶部
   */
  @Builder
  topBuilder() {
    Row() {
      TopBar({
        onClickBack: () => {
          RouterModule.pop('result')
        },
        title: '消息中心'
      })
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.clean'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
      }
      .height($r('app.float.vp_40'))
      .width($r('app.float.vp_40'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.clearAll()
      })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height($r('app.float.vp_56'))
  }

  @Builder
  FunctionButton() {
    Button({ type: ButtonType.Circle }) {
      SymbolGlyph($r('sys.symbol.clean'))
        .fontSize(24)
        .fontColor([$r('sys.color.icon_primary')])
    }
    .height($r('app.float.vp_40'))
    .width($r('app.float.vp_40'))
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .onClick(() => {
      this.clearAll()
    })
    .margin({ right: 16, top: 8 })
  }

  clearAll() {
    this.systemMsgList.listArr.forEach(item => item.isRead = true)
    this.newFansList.listArr.forEach(item => item.isRead = true)
    let hasMessageList = this.message.listArr.filter((item: MessageItem) => item.count > 0)
    if (hasMessageList.length === 0) {
      this.getUIContext().getPromptAction().showToast({
        message: '暂无未读消息'
      })
    } else {
      hasMessageList.forEach((item: MessageItem) => {
        item.count = 0;
      })
      this.getUIContext().getPromptAction().showToast({
        message: '操作成功'
      })
    }
  }
}

@Builder
export function MessageCenterBuilder() {
  MessageCenterPage()
}