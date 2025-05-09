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

import { BreakpointConstants } from '../constants/BreakpointConstants';

export class BreakpointType<T> {
  sm: T;
  md: T;

  constructor(sm: T, md: T) {
    this.sm = sm;
    this.md = md;
  }

  getValue(currentBreakpoint: string): T {
    if (currentBreakpoint === BreakpointConstants.BREAKPOINT_MD) {
      return this.md;
    } else {
      return this.sm;
    }
  }
}