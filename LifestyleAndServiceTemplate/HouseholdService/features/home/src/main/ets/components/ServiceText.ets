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

import { CommonUtils, IServiceDetailItem } from 'utils'

@ComponentV2
export struct ServiceText {
  @Require @Param content: IServiceDetailItem;

  @Computed
  get descList() {
    return this.content.desc.replace('#count', this.content.count.toString())
      .split('#price');
  }

  build() {
    Text() {
      Span(this.descList[0] ?? '')
      Span(CommonUtils.handleCash(this.content.price)).fontColor($r('app.color.common_red'))
      Span(this.descList[1] ?? '')
    }
    .fontSize(12)
    .fontWeight(500)
  }
}