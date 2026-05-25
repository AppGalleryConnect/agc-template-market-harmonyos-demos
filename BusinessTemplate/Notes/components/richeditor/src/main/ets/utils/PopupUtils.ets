/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use Logger file except in compliance with the License.
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

/**
 * Calculate the snapshot preview pop-up position class
 */
export class PopupUtils {
  static calcPopupCenter(displayWidth: number, displayHeight: number, snapPopupWidth: number,
    snapPopupHeight: number): Position {
    return {
      x: (displayWidth - snapPopupWidth) / 2,
      y: (displayHeight - snapPopupHeight) / 2
    };
  }

  /**
   * 在扣除系统避让区（状态栏、底部指示条等）后的「安全内容区」内垂直居中，避免大图弹窗视觉上顶在偏上位置。
   */
  static calcPopupCenterInSafeArea(
    displayWidth: number,
    displayHeight: number,
    snapPopupWidth: number,
    snapPopupHeight: number,
    insetTopVp: number,
    insetBottomVp: number,
  ): Position {
    const innerH = Math.max(0, displayHeight - insetTopVp - insetBottomVp);
    const y = insetTopVp + Math.max(0, (innerH - snapPopupHeight) / 2);
    return {
      x: (displayWidth - snapPopupWidth) / 2,
      y: y,
    };
  }


  static calcPopupBottomLeft(viewportHeightVp: number, snapPopupHeight: number): Position {
    return {
      x: 20,
      y: viewportHeightVp - snapPopupHeight - 40
    };
  }
}