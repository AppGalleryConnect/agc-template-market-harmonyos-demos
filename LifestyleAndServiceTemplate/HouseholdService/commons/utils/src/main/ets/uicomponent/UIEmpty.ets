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

import { CommonConstants } from '../common/Constant'

@ComponentV2
export struct UIEmpty {
  @Param emptyDesc: ResourceStr = '暂无内容';
  @Param fg: number = 14;

  build() {
    Column({ space: 10 }) {
      Image($r('app.media.ic_empty')).width(56).height(47)
      Text(this.emptyDesc).fontColor($r('app.color.common_grey')).fontSize(this.fg)
    }
    .width(CommonConstants.FULL_PERCENT)
  }
}