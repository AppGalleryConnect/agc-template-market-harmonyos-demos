import { BackupExtensionAbility, BundleVersion } from '@kit.CoreFileKit';
import { TCLogger } from 'common';

const TAG = 'EntryBackupAbility';

export default class EntryBackupAbility extends BackupExtensionAbility {
  async onBackup() {
    TCLogger.info(TAG, 'onBackup ok');
    await Promise.resolve();
  }

  async onRestore(bundleVersion: BundleVersion) {
    TCLogger.info(TAG, 'onRestore ok ' + JSON.stringify(bundleVersion));
    await Promise.resolve();
  }
}