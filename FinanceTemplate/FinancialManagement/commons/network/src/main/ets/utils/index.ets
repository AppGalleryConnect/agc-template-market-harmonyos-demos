import { AppStorageMap, HUAWEIAccountModel, Logger } from 'commonlib';
import { PersistenceV2 } from '@kit.ArkUI';
import { https } from '../apis/HttpRequestApi';

export function getTenantId() {
  const tenantId: number | undefined = AppStorage.get(AppStorageMap.TENANT_ID);
  if (!tenantId) {
    Logger.error('tenant id is not existed');
    return undefined;
  }
  return tenantId;
}

export function resetLoginToken() {
  const accountInfo: HUAWEIAccountModel | undefined = PersistenceV2.connect(
    HUAWEIAccountModel,
    'accountInfo',
    () => new HUAWEIAccountModel(),
  )!;
  accountInfo.loginToken = undefined;
  https.userLogin().then((res) => {
    if (res.code === 0) {
      accountInfo.loginToken = res.data.loginToken;
    }
  });
}
