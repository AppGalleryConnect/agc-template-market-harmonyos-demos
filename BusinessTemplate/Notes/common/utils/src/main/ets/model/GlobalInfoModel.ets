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
export class GlobalInfoModel {
  @Trace currentBreakpoint: BreakpointTypeEnum = BreakpointTypeEnum.MD;
  /**
   * 当前窗口宽度（vp）。用于平板/折叠屏等场景下做稳定的比例布局计算。
   * 由 EntryAbility 在 windowSizeChange 时持续刷新。
   */
  @Trace screenWidthVp: number = 0;
}


export enum BreakpointTypeEnum {
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
}