/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License')
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { promptAction } from '@kit.ArkUI'

/**
 * 获取当前时间
 * @returns
 */
export function getDateStringWithTimeStamp(date?: Date): string {
  const now = new Date()
  const inputDate = date ? date : new Date()
  const isThisYear = inputDate.getFullYear() === now.getFullYear()
  const month = ('0' + (inputDate.getMonth() + 1)).slice(-2)
  const day = ('0' + inputDate.getDate()).slice(-2)
  const hour = ('0' + inputDate.getHours()).slice(-2)
  const min = ('0' + inputDate.getMinutes()).slice(-2)

  if (isThisYear) {
    // 今年的日期格式：xx/xx xx:xx
    return `${month}/${day} ${hour}:${min}`
  } else {
    const year = inputDate.getFullYear()
    // 非今年的日期格式：xxxx/xx/xx 年/月/日 xx时xx分
    return `${year}/${month}/${day} 年/${month}月/${day}日 ${hour}时${min}分`
  }
}

/**
 * 选择图片
 * @param preselectedUris 传入图片数组
 * @param num 选择最大图片数量
 * @returns
 */
export async function fileSelect(uiContext: UIContext, preselectedUris: Array<string>,
  num: number): Promise<Array<string>> {
  // 设置打开picker的选项
  let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
  photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE // 类型
  photoSelectOptions.maxSelectNumber = num // 数量
  photoSelectOptions.preselectedUris = preselectedUris // 预先的uri
  // 推荐参数
  let recommendationOptions: photoAccessHelper.RecommendationOptions = {
    recommendationType: photoAccessHelper.RecommendationType.QR_CODE // 配置枚举类型，不同的枚举值，推荐不同种类的图片
  }
  photoSelectOptions.recommendationOptions = recommendationOptions // 将推荐参数赋值给 photoSelectOptions.recommendationOptions
  let photoPicker = new photoAccessHelper.PhotoViewPicker() // 创建picker
  try {
    let photoSelectResult = await photoPicker.select(photoSelectOptions) // 拉起图片选择框
    if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
      let imgUris = photoSelectResult.photoUris
      for (let imgUri of imgUris) {
        if (imgUri.indexOf('media/Photo') < 0) {
          uiContext.getPromptAction().showToast({ message: '请选择图片进行上传' })
          return []
        }
      }
      return imgUris
    } else {
      return []
    }
  } catch (err) {
    return []
  }
}
