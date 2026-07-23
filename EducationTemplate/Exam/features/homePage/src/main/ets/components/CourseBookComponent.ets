/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
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

import { CourseBook } from '../model/CourseBook'
import { filePreview } from '@kit.PreviewKit'
import { viewFile, viewPDF, viewWord } from 'commonlib'

// 资料下载卡片组件
@ComponentV2
export struct CourseBookComponent {
  @Param @Require courseBook: CourseBook
  @Param @Require pageType: string = 'home'
  uiContext = this.getUIContext();

  // 计算属性用来通过文件类型添加不同图片
  @Computed
  get BookImage() {
    if (this.courseBook.type === 'pdf') {
      return $r('app.media.ic_public_pdf_file_textured')
    } else if (this.courseBook.type === 'zip') {
      return $r('app.media.ic_public_compressed_file_textured')
    } else if (this.courseBook.type === 'word') {
      return $r('app.media.ic_public_word_file_textured')
    }
    return ''
  }

  build() {
    Column() {
      // 资料简介
      this.courseBookDescBuilder()
      // 浏览下载人次
      this.visitorAndDownloadBuilder()
    }
    .borderRadius(16)
    .padding({ top: 8 })
    .height(68)
    .width(281)
    .onClick(() => {
      if (this.courseBook.type === 'pdf') {
        viewPDF(this.uiContext, this.courseBook.bookName);
      } else if (this.courseBook.type === 'zip') {
        viewFile('test.zip', '', this.uiContext);
      } else if (this.courseBook.type === 'word') {
        viewWord(this.uiContext, this.courseBook.bookName)
      }
    })
  }

  /**
   * 浏览下载人次
   */
  @Builder
  visitorAndDownloadBuilder() {
    Row() {
      Row() {
        Text(`已有 ${this.courseBook.visitors}人 浏览`)
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Lighter)
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Start)
          .width('auto')
        Text(`下载 ${this.courseBook.downloadTimes}次`)
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Lighter)
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Start)
          .margin({ left: '8vp' })
      }
      .justifyContent(FlexAlign.Start)
      .width('50%')
    }
    .padding({ left: 4 })
    .height('auto')
    .width('100%')
  }

  /**
   * 资料简介
   */
  @Builder
  courseBookDescBuilder() {
    Row() {
      Image(this.BookImage)
        .height('40vp')
        .width('40vp')
        .margin({ right: '16vp' })
      Column() {
        Text(this.courseBook.bookName)
          .margin({ bottom: '2vp' })
          .width('100%')
          .textAlign(TextAlign.Start)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
        if (this.pageType !== 'MaterialDownload') {
          Text(this.courseBook.bookTag)
            .width('100%')
            .textAlign(TextAlign.Start)
            .fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_S'))
        }
      }.justifyContent(FlexAlign.Start)
    }
    .padding({ bottom: 4 })
    .width('100%')
  }
}