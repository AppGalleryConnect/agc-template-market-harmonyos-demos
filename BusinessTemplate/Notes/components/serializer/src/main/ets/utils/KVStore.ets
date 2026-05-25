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

import { bundleManager, common } from '@kit.AbilityKit';
import { distributedKVStore } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { KVStoreType } from '../viewmodel/KVStoreType';
import { BusinessError } from '@kit.BasicServicesKit';

export class KVStore {
  kvManager: distributedKVStore.KVManager | undefined = undefined;
  kvStore: distributedKVStore.SingleKVStore | undefined = undefined;
  bundleName: string = '';

  createKVStore(encrypt: boolean, securityLevel: distributedKVStore.SecurityLevel,
    uiContext: UIContext): Promise<distributedKVStore.SingleKVStore> {
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT;
    let hContext = uiContext.getHostContext() as common.UIAbilityContext;

    // 获取当前应用的Bundle信息
    let data = bundleManager.getBundleInfoForSelfSync(bundleFlags)
    this.bundleName = data.name;

    const kvManagerConfig: distributedKVStore.KVManagerConfig = {
      context: hContext,
      bundleName: this.bundleName
    };

    // 创建KVManager实例
    this.kvManager = distributedKVStore.createKVManager(kvManagerConfig);
    const options: distributedKVStore.Options = {
      createIfMissing: true,
      backup: false,
      autoSync: false,
      kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
      encrypt: encrypt,
      securityLevel: securityLevel
    };


    return new Promise((resolve, reject) => {
      if (this.kvManager === undefined) {
        hilog.error(0x0000, 'KVStore', 'createKVStore: kvManager is undefined');
        reject(new Error('kvManager is undefined'));
        return;
      }
      try {
        this.kvManager.getKVStore<distributedKVStore.SingleKVStore>(`${securityLevel}${JSON.stringify(encrypt)}`,
          options,
          (err, store: distributedKVStore.SingleKVStore) => {
            if (err) {
              hilog.error(0x0000, 'KVStore', `Failed to get KVStore: Code:${err.code},message:${err.message}`);
              reject(err);
              return;
            }
            hilog.info(0x0000, 'KVStore', 'Succeeded in getting KVStore.');
            resolve(store);
          });
      } catch (error) {
        const err = error as BusinessError;
        hilog.error(0x0000, 'KVStore', `getKVStore threw: Code:${err.code},message:${err.message}`);
        reject(err);
      }
    });
  }

  async put(key: string, value: Uint8Array | string | number | boolean) {
    if (!this.kvStore) {
      hilog.error(0x0000, 'KVStore', 'put: kvStore is undefined');
      return;
    }
    try {
      this.kvStore.put(key, value, (err) => {
        if (err !== undefined) {
          hilog.error(0x0000, 'KVStore', `Failed to put data. Code:${err.code},message:${err.message}`);
          return;
        }
        hilog.info(0x0000, 'KVStore', 'Succeeded in putting data.');
      });
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, 'KVStore', `put threw. Code:${err.code},message:${err.message}`);
    }
  }

  delete(key: string) {
    if (!this.kvStore) {
      hilog.error(0x0000, 'KVStore', 'delete: kvStore is undefined');
      return;
    }
    try {
      this.kvStore.delete(key, (err) => {
        if (err !== undefined) {
          hilog.error(0x0000, 'KVStore', `Failed to delete data. Code:${err.code},message:${err.message}`);
          return;
        }
        hilog.info(0x0000, 'KVStore', 'Succeeded in deleting data.');
      });
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, 'KVStore', `delete threw. Code:${err.code},message:${err.message}`);
    }
  }

  async get(key: string): Promise<KVStoreType | undefined> {
    if (!this.kvStore) {
      return undefined;
    }

    try {
      const entries = await this.kvStore.getEntries(key);

      for (let i = 0; i < entries.length; i++) {
        let type: string = typeof entries[i].value.value;
        if (type === 'object') {
          type = 'Uint8Array';
        }
        return new KVStoreType(entries[i].key, entries[i].value.value, type);
      }

      return undefined;

    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, 'KVStore', `Failed to getEntries. Code:${error.code},message:${error.message}`);
      return undefined;
    }
  }

  async getAll(key: string): Promise<KVStoreType[] | undefined> {
    if (!this.kvStore) {
      return undefined;
    }

    let allKVStore: KVStoreType[] = [];
    await this.kvStore!.getEntries(key).then((entries: distributedKVStore.Entry[]) => {
      let i = 0;
      for (i; i < entries.length; i++) {
        let type: string = typeof entries[i].value.value;
        if (type === 'object') {
          type = 'Uint8Array';
        }
        let kvStoreType = new KVStoreType(entries[i].key, entries[i].value.value, type);
        allKVStore.push(kvStoreType);
      }
    }).catch((error: BusinessError) => {
      hilog.error(0x0000, 'KVStore', `Failed to getEntries. Code:${error.code},message:${error.message}`);
    })
    hilog.info(0x0000, 'KVStore', `kvStoreType: ${JSON.stringify(allKVStore)}`);
    return allKVStore;
  }
}