import { BackupExtensionAbility, BundleVersion } from '@kit.CoreFileKit';
import { TCLogger } from 'common';

const TAG = 'EntryBackupAbility';

export default class EntryBackupAbility extends BackupExtensionAbility {
  async onBackup() {
    await Promise.resolve();
  }

  async onRestore(bundleVersion: BundleVersion) {
    await Promise.resolve();
  }
}