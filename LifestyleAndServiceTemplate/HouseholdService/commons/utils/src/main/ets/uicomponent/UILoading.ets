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

export class FullLoadingParam {
  label?: string;
}

@Builder
export function fullLoading(param: FullLoadingParam) {
  Stack({ alignContent: Alignment.Center }) {
    Column() {
      LoadingProgress().width(32).height(32).color($r('sys.color.icon_on_primary'))
    }
    .justifyContent(FlexAlign.Center)
    .width(100)
    .height(100)
    .backgroundColor('#88000000')
    .borderRadius(8)
  }
  .width('100%')
  .height('100%')
  .backgroundColor(Color.Transparent)
}