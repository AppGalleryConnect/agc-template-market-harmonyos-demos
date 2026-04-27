/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import { RouterMap } from '@agctemplate/router_module'

@ObservedV2
export class MessageItem {
  @Trace id: string
  @Trace icon: ResourceStr
  @Trace title: string
  @Trace subtitle: string
  @Trace time: string
  @Trace isDelete: boolean = false
  @Trace url: string = ''
  @Trace count: number = 0

  constructor(id: string, icon: ResourceStr, title: string, subtitle: string, time: string, isDelete: boolean,
    count: number,
    url: string) {
    this.id = id
    this.icon = icon
    this.title = title
    this.subtitle = subtitle
    this.time = time
    this.isDelete = isDelete
    this.url = url
    this.count = count
  }
}

// 存储消息中心数据
@ObservedV2
export class NumbObj {
  @Trace listArr: MessageItem[] = [
    new MessageItem('11', $r('app.media.icon_envelope'), '系统消息', '用户协议及隐私政策更新通知', '3分钟前', false, 4,
      RouterMap.SYS_MESSAGE_PAGE),
    new MessageItem('22', $r('app.media.icon_envelope1'), '新增粉丝', '娱乐大杂烩 关注了你', '1小时前',
      false, 6, RouterMap.NEW_FANS_MESSAGE_PAGE)
  ]

  get totalUnreadCount(): number {
    return this.listArr.reduce((sum, item) => sum + item.count, 0);
  }
}