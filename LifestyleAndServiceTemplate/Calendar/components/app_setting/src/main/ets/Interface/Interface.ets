import { updateManager } from '@kit.AppGalleryKit';
import { ErrorMessage } from '../models/ErrorMessageModel';

export interface CheckUpdateCallback {
  onSuccess?: (checkResult:updateManager.CheckUpdateResult) => void;
  onFailed?: (error:ErrorMessage) => void;
}

export interface UpdateCallback {
  onSuccess?: (checkResult:updateManager.ShowUpdateResultCode) => void;
  onFailed?: (error:ErrorMessage) => void;
}

export interface CommentCallback {
  onSuccess?: () => void;
  onFailed?: (error:ErrorMessage) => void;
}
