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

@ObservedV2
export class SetupItem {
  @Trace msg: string
  @Trace icon: ResourceStr
  @Trace cache?: string
  @Trace url?: string

  constructor(msg: string, icon: ResourceStr, cache?: string, url?: string) {
    this.msg = msg
    this.icon = icon
    this.cache = cache
    this.url = url
  }
}

@ObservedV2
export class CollectionItem {
  @Trace id: number
  @Trace name: string
  @Trace title: string
  @Trace isDelete: boolean

  constructor(id: number, name: string, title: string, isDelete: boolean) {
    this.id = id
    this.name = name
    this.title = title
    this.isDelete = isDelete
  }
}