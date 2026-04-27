import { photoAccessHelper } from '@kit.MediaLibraryKit';

/**
 * 拉起图库选择器
 *
 * @param maxSelectNumber - 最大选择数量
 * @param preselectedUris - 预先选择的 URI 列表，与之对应的图片会被直接勾选
 * @returns 返回所选图片 URI 列表
 */
export async function pickImage(maxSelectNumber: number, preselectedUris?: string[]): Promise<string[]> {
  const options: photoAccessHelper.PhotoSelectOptions = {
    isEditSupported: true,
    isOriginalSupported: true,
    completeButtonText: photoAccessHelper.CompleteButtonText.TEXT_DONE,
    MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
    maxSelectNumber: maxSelectNumber,
    isPreviewForSingleSelectionSupported: true,
    preselectedUris: preselectedUris
  };
  const picker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
  try {
    const result: photoAccessHelper.PhotoSelectResult = await picker.select(options);
    return result.photoUris;
  } catch {
    return [];
  }
}
