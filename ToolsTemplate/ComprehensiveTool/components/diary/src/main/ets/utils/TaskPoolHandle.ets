import { ImageUtils } from './ImageUtils';

// 将不使用的图片移除
export function handleTaskPoolDelete(imgSrcList: string[], newImgSrcList: string[] = []) {
  let removedList = imgSrcList;
  if (newImgSrcList.length) {
    const newSet = new Set(newImgSrcList);
    removedList = imgSrcList.filter((src: string) => !newSet.has(src));
  }
  for (let i = 0; i < removedList.length; i++) {
    const src = removedList[i]
    ImageUtils.removeSandboxImg(src);
  }
}