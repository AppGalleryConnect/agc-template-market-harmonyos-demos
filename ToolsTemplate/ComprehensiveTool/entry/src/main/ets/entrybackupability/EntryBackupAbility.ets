import { BackupExtensionAbility, BundleVersion } from '@kit.CoreFileKit';
import { UtilLog } from '@hw-agconnect/util-log';

export default class EntryBackupAbility extends BackupExtensionAbility {
  async onBackup() {
    UtilLog.info('testTag', 'onBackup ok');
    await Promise.resolve();
  }

  async onRestore(bundleVersion: BundleVersion) {
    UtilLog.info('onRestore ok %{public}s', JSON.stringify(bundleVersion));
    await Promise.resolve();
  }
};