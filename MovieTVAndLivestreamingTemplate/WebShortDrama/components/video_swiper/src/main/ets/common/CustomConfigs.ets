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

import { media } from '@kit.MediaKit';
import { netQuality } from '@kit.NetworkBoostKit';

// [Start PreferredBufferSize]
// entry/src/main/ets/common/CustomConfigs.ets
export class CustomConfigs {
  // [StartExclude PreferredBufferSize]
  // Custom x component id
  public static readonly X_COMPONENT_ID = 'NAVS';

  // Custom hls stream url
  public static readonly URL = '';

  // [EndExclude PreferredBufferSize]
  public static readonly PREFERRED_BUFFER_SIZE = 20;

  public static readonly PLAYBACK_STRATEGY: media.PlaybackStrategy = {
    preferredWidth: 1920,
    preferredHeight: 1080,
    preferredBufferDuration: CustomConfigs.PREFERRED_BUFFER_SIZE
  };
  // [StartExclude PreferredBufferSize]
  // Custom weak network buffer
  public static readonly CACHED_PERCENT_THRESHOLD: number = 0.2;

  /*
   * Custom media source for video initialization, example:
   * public static readonly MEDIA_SOURCE: media.MediaSource = media.createMediaSourceWithUrl(
   *   CustomConfigs.URL, // Custom hls stream url
   *   {
   *     'user_agent': '',
   *     'referer': 'https://xxx.xxx.xxx'
   *   } // Custom header, optional
   * );
   */
  public static readonly MEDIA_SOURCE: media.MediaSource = media.createMediaSourceWithUrl(CustomConfigs.URL);

  /**
   * Custom resolution map, which needs to be defined based on the video resolution height and bitrate to match
   * the actual playback effect
   */
  public static readonly SELECTABLE_RESOLUTIONS: Map<number, string> = new Map([
    [360, '360p'],
    [720, '720p'],
    [1080, '1080p']
  ]);

  // Custom net paths to display in information
  public static readonly SELECTABLE_NET_PATH: Array<netQuality.PathType> = [
      netQuality.PathType.WIFI_PRIMARY,
  ];
  // [EndExclude PreferredBufferSize]
}
// [End PreferredBufferSize]

