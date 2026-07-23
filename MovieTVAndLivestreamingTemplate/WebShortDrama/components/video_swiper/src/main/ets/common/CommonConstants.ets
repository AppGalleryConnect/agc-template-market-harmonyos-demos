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

export class AVPlayerConstants {
  public static readonly MIN_SEEK_TIME_MS: number = 0;
  public static readonly SEEK_STEP: number = 1;
  public static readonly BUFFER_INFO_TYPES: Array<string> = [
    'BUFFERING_START',
    'BUFFERING_END',
    'BUFFERING_PERCENT',
    'CACHED_DURATION'
  ];
  public static readonly PLAYBACK_INTERVAL_MS: number = 500;
  public static readonly NET_CHECK_INTERVAL_MS: number = 500;
  public static readonly RECENT_DOWNLOAD_LIST_LENGTH: number = 3;
  public static readonly WEAK_NET_CHECK_INTERVAL: number = 10000;
  public static readonly BITRATE_UP_CHECK_INTERVAL: number = 10000;
}

export class ViewConstants {
  public static readonly TOAST_TIME_MS: number = 2000;
  public static readonly VIDEO_ASPECT_RATIO: number = 16 / 9;
  public static readonly FULL_SIZE: string = '100%';
  public static readonly AUTO_SIZE: string = 'auto';
  public static readonly DIVIDER_STROKE_WIDTH: number = 0.5;
}

export class CommonConstants {
  public static readonly SECOND_TO_MS: number = 1000;
  public static readonly MINUTE_TO_SECOND: number = 60;
  public static readonly HOUR_TO_MINUTE: number = 60;
  public static readonly TIME_CONST_TEN: number = 10;
  public static readonly MB_TO_BIT: number = 8 * 1024 * 1024;
  public static readonly ZERO_VALUE: number = 0;
}

export class NetConstants {
  public static readonly NET_PATH_TYPES: Array<string> = [
    'CELLULAR_PRIMARY',
    'CELLULAR_SECONDARY',
    'WIFI_PRIMARY',
    'WIFI_SECONDARY'
  ];
}