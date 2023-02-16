/*
 * Copyright 2020. Huawei Technologies Co., Ltd. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { Constants } from '../constants/Constants'

@Component
export struct Empty {
  build(){
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Image($r('app.media.empty')).width($r('app.float.img_middle')).height($r('app.float.img_middle')).objectFit(ImageFit.Contain)
      Text($r('app.string.result_empty')).fontSize($r('app.float.font_middle')).fontColor(Color.Gray)
    }.width(Constants.WIDTH_FULL).height(Constants.HIGH_FULL)
  }
}