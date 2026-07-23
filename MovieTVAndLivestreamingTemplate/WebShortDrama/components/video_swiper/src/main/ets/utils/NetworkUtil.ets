/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { BusinessError, request } from '@kit.BasicServicesKit';
import { connection } from '@kit.NetworkKit';
import { netQuality } from '@kit.NetworkBoostKit';
import { AppStorageV2, PromptAction, window } from '@kit.ArkUI';
import { NetWorkModel } from './NetWorkModel';
import { hilog } from '@kit.PerformanceAnalysisKit';


const TAG = 'NetworkUtilTag';

export class NetworkUtil {
  private windowStage: window.WindowStage = AppStorage.get('windowStage')!
  private promptAction: PromptAction = this.windowStage.getMainWindowSync().getUIContext().getPromptAction();
  private netStatus: NetWorkModel =
    AppStorageV2.connect(NetWorkModel, 'netStatus', () => new NetWorkModel())!

  // [Start is_network_available]
  public isNetworkAvailable(): boolean {
    try {
      let netHandle = connection.getDefaultNetSync();
      if (netHandle.netId === 0) {
        // If there is no network connected, the netid of the obtained netHandler is 0
        return false;
      }
      let netCapability = connection.getNetCapabilitiesSync(netHandle);
      let networkCaps: connection.NetCap[] = netCapability.networkCap || [];
      return networkCaps.includes(connection.NetCap.NET_CAPABILITY_VALIDATED)
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, TAG, `getNetworkType err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
    return false;
  }

  // [End is_network_available]

  public isCellular(): boolean {
    try {
      let netHandle = connection.getDefaultNetSync();
      if (netHandle.netId === 0) {
        // If there is no network connected, the netid of the obtained netHandler is 0
        return false;
      }
      let netCapability = connection.getNetCapabilitiesSync(netHandle);
      let bearTypes: connection.NetBearType[] = netCapability.bearerTypes;
      return bearTypes.includes(connection.NetBearType.BEARER_CELLULAR);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, TAG, `isCellular err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
    return true;
  }

  // [Start scene_change_step]
  public onNetSceneChange() {
    // Subscribe to network scene information
    try {
      netQuality.on('netSceneChange', (list: netQuality.NetworkScene[]) => {
        hilog.info(0x0000, TAG, `on netSceneChange, Succeeded receive netSceneChange info: ${list.length}`);
        if (list.length > 0) {
          list.forEach((networkScene) => {
            if (networkScene.scene === 'weakSignal' || networkScene.scene === 'congestion') {
              this.promptAction.showToast({ message: '当前网络不佳' });
            }
          });
        }
      });
    } catch (err) {
      hilog.error(0x0000, TAG, `on netSceneChange err: ${JSON.stringify(err)}`);
    }
  }

  // [End scene_change_step]

  public onNetworkChange() {
    // [Start network_available_step]
    // Create a NetConnection object
    this.netStatus.netCon = connection.createNetConnection();
    // Subscribe to a network available event that triggers when the network is available
    this.netStatus.netCon!.on('netAvailable', (data: connection.NetHandle) => {
      hilog.info(0x0000, TAG, `on netAvailable, Succeeded to get netAvailable: ${JSON.stringify(data)}`);
      this.netStatus.isNetAvailable = this.isNetworkAvailable();
      this.netStatus.isCellular = this.isCellular();
      if (this.netStatus.isNetAvailable && !this.netStatus.isCellular && !this.netStatus.noReInit) {
        this.netStatus.reInit = true
      }
    });
    // [End network_available_step]

    // [Start network_unavailable_step]
    // Subscribe to a network unavailability event that triggers when the network is unavailable
    this.netStatus.netCon!.on('netUnavailable', () => {
      hilog.info(0x0000, TAG, 'on netUnavailable, Succeeded to get unavailable net event');
      this.netStatus.isNetAvailable = false;
      this.promptAction.showToast({ message: '网络不可用' });
    });
    // [End network_unavailable_step]

    // [Start network_abilities_change_step]
    // Subscribe to network capability change events that trigger when network capability changes,
    // such as from no network to network with network, or when switching from WIFI to cellular
    this.netStatus.netCon!.on('netCapabilitiesChange', (data: connection.NetCapabilityInfo) => {
      hilog.info(0x0000, TAG, `on netCapabilitiesChange, Succeeded to get netCapabilitiesChange: ${JSON.stringify(data)}`);
      if (data.netCap.bearerTypes.includes(connection.NetBearType.BEARER_CELLULAR)) {
        // For cellular networks, pause playback
        this.netStatus.isCellular = true;
        // this.netStatus.isShowController = false;
        // this.netStatus.controller.pause();
        this.promptAction.showToast({ message: '当前为蜂窝网络' });
        this.netStatus.isShowGoOn = true;
        this.netStatus.noReInit = true;
      } else if (data.netCap.bearerTypes.includes(connection.NetBearType.BEARER_WIFI)){
        this.netStatus.isCellular = false;
        // this.netStatus.isShowController = true;
        // this.netStatus.controller.play();
        this.netStatus.isShowGoOn = false;
      }
    });
    // [End network_abilities_change_step]

    // [Start network_lost_step]
    // Subscribe to a network loss event, triggered when the network is severely interrupted or normally disconnected,
    // and the network interruption pauses playback
    this.netStatus.netCon!.on('netLost', (data: connection.NetHandle) => {
      hilog.info(0x0000, TAG, `on netLost, Succeeded to get netLost: ${JSON.stringify(data)}`);
      this.netStatus.isNetAvailable = false;
      this.netStatus.isCellular = false;
      this.netStatus.reInit = false
      this.promptAction.showToast({ message: '网络已断开' });
    });
    // [End network_lost_step]

    // [Start register_network_change_step]
    this.netStatus.netCon!.register((error: BusinessError) => {
      if (error) {
        hilog.error(0x0000, TAG, `networkListen fail: ${JSON.stringify(error)}`);
      }
    });
    // [End register_network_change_step]
  }

  public unregister() {
    this.netStatus.netCon?.unregister((err: BusinessError) => {
      if (err) {
        hilog.error(0x0000, TAG, `unregister failed, err: ${JSON.stringify(err)}`);
      }
    });
    // Unsubscribe from network scenario information
    try {
      netQuality.off('netSceneChange');
    } catch (err) {
      hilog.error(0x0000, TAG, `off netSceneChange err: ${JSON.stringify(err)}`);
    }
  }
}