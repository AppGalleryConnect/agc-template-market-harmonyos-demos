/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { GlobalContextUtils } from 'commonlib';
import { Score } from '../model/CommentModel';

@ComponentV2
export struct CommentPopup {
  @Param submitEvent: (count: number, content: string) => void = () => {
  };
  @Local arr: Score[] = []
  @Local count: number = 1
  @Local content: string = ''

  aboutToAppear(): void {
    this.arr = [
      new Score('0', true),
      new Score('1', false),
      new Score('2', false),
      new Score('3', false),
      new Score('4', false),
    ]
  }

  build() {
    Column() {
      Text('请您对该菜谱进行推荐')
        .fontSize($r('sys.float.Subtitle_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .margin({ top: 50 })

      Row() {
        ForEach(this.arr, (item: Score, idx: number) => {
          Image(item.select ? $r('app.media.ic_star') : $r('app.media.ic_star_fill'))
            .width(20)
            .height(20)
            .objectFit(ImageFit.Fill)
            .margin({ right: 8 })
            .onClick(() => {
              this.scoreEvent(idx)
            })
        }, (item: number, index: number) => item + index + '')
      }
      .margin({ top: 8, bottom: 8 })

      Text(`${this.count}分`)
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_tertiary'))
        .fontWeight(FontWeight.Regular)

      TextArea({ placeholder: '请输入您的评价' })
        .width('100%')
        .height(80)
        .margin({ top: 20, bottom: 20 })
        .enterKeyType(EnterKeyType.NEW_LINE)
        .onChange((value: string) => {
          this.content = value
        })

      Button({
        type: ButtonType.Capsule,
        stateEffect: true,
      }) {
        Text('提交')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Medium)
      }
      .enabled(this.content.trim() === '' ? false : true)
      .backgroundColor($r('sys.color.multi_color_01'))
      .height(48)
      .width('100%')
      .onClick(() => {
        if (this.content.trim() === '') {
          GlobalContextUtils.showToast({ message: '请输入您的评价' })
          return
        }
        this.submitEvent(this.count, this.content)
      })
    }
    .padding(16)
    .width('100%')
    .height('100%')
  }

  // 打分
  scoreEvent(idx: number) {
    this.count = 0
    this.arr.forEach((element: Score, index: number) => {
      if (index <= idx) {
        element.select = true
        this.count += 1
      } else {
        element.select = false
      }
    });
  }
}
