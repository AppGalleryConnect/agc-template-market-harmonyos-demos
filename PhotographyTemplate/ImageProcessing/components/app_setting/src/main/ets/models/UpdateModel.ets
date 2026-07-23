import { updateManager } from '@kit.AppGalleryKit';
import { ErrorMessage } from './ErrorMessageModel';

export type UpdateCheckResult = updateManager.ShowUpdateResultCode | ErrorMessage
