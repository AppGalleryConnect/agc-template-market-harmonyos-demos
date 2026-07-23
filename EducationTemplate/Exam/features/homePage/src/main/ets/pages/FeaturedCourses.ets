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

import { BreakpointType, TopTabsBuilder } from 'commonlib';
import { Course } from '../model/Course';
import { CourseComponent } from '../components/CourseComponent';
import { HomeVM } from '../viewmodels/HomeVM';

// 精选课程页面
@ComponentV2
export struct FeaturedCourses {
  @Local textInput: string = '';
  controller: TextInputController = new TextInputController();
  @Local coursesSource: Course[] = [new Course('111', '华为用户', '一级建造师精华题库中级班', 423, 288),
    new Course('222', '华为用户', '一级建造师精华题库中级班', 423, 288)];
  @Local courses: Course[] = [];
  @Local enterTypes: Array<EnterKeyType> =
    [EnterKeyType.Go, EnterKeyType.Search, EnterKeyType.Send, EnterKeyType.Done, EnterKeyType.Next,
      EnterKeyType.PREVIOUS, EnterKeyType.NEW_LINE];
  @Local index: number = 0;
  homeVM: HomeVM = HomeVM.instance;

  aboutToAppear(): void {
    this.courses = this.coursesSource;
  }

  build() {
    Column() {
      TopTabsBuilder({ title: '精选课程', bgColor: $r('sys.color.comp_background_primary'), showBackButton: true })
        .margin({ bottom: '8vp' })
        .padding({ left: '16vp', right: '16vp' });

      Divider().width('100%');
      this.courseListBuilder();
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  /**
   * 资料列表
   */
  @Builder
  courseListBuilder() {
    List({ space: 12 }) {
      Repeat(this.courses)
        .each((ri: RepeatItem<Course>) => {
          ListItem() {
            CourseComponent({ course: ri.item })
              .width('100%')
          }
        })
        .key((item: Course) => JSON.stringify(item))
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .lanes(new BreakpointType<number>({
      sm: 1,
      md: 2,
      lg: 3,
      xl: 3
    }).getValue(this.homeVM.breakPointModel.currentBreakpoint))
    .backgroundColor($r('sys.color.comp_background_gray'))
    .padding({ left: 16, right: 16 })
    .contentStartOffset(12)
  }
}

@Builder
export function FeaturedCoursesBuilder() {
  FeaturedCourses();
}