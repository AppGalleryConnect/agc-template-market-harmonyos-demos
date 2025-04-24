/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

/**
 * Play constants for all features.
 */
export class PlayConstants {
  /**
   * time system, Hour-minute-second conversion.
   */
  static readonly TIME_UNIT: number = 60;
  /**
   * String zero padding.
   */
  static readonly PADDING_STR: string = '0';

  /**
   * Start playing.
   */
  static readonly STATUS_START: number = 1;
  /**
   * Playing Pause.
   */
  static readonly STATUS_PAUSE: number = 2;
  /**
   * Stop Playing.
   */
  static readonly STATUS_STOP: number = 3;
  /**
   * Initial Time UNIT.
   */
  static readonly INITIAL_TIME_UNIT: string = '00';
  /**
   * Zero padding, 2 bits.
   */
  static readonly PADDING_LENGTH: number = 2;

  /**
   * Video playback control constant.
   */
  static readonly CONTROL_NEXT: number = 1;

  /**
   * Progress bar page constant.
   */
  static readonly PROGRESS_TRACK_THICKNESS: number = 4;
  static readonly PROGRESS_MARGIN_LEFT: string = '2.2%';
  static readonly ASPECT_RATIO: number = 1.77777778; // 元素宽高比

  static readonly FIRST_NUMBER = '已经是第一集了 ~'
  static readonly LAST_NUMBER = '已经是最后一集了 ~'
  static readonly NOT_ALLOW_WATCH = '在休息时间内，不允许观看和收听哦 ~'
}