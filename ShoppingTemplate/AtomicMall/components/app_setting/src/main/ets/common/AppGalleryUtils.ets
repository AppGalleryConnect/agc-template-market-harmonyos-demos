// @kit.AppGalleryKit (updateManager) is not supported in atomic service.
// Version check is stubbed — always returns "latest version".
import { common } from '@kit.AbilityKit';

const TAG = '[AppGalleryUtils]';

export class AppGalleryUtils {
  public static checkAppUpdate(
    _context: common.UIAbilityContext,
  ): Promise<boolean> {
    // updateManager.checkAppUpdate not supported in atomic service
    return Promise.resolve(false);
  }

  public static showUpdateDialog(_context: common.UIAbilityContext) {
    // updateManager.showUpdateDialog not supported in atomic service
  }
}
