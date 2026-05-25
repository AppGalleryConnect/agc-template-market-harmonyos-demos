/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the 'License');
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an 'AS IS' BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

@ObservedV2
export class MyCourseModel {
  id: string = '';
  // 课程标题
  courseTitle?: string;
  // 课程时长
  courseDuration?: number;
  // 学习进度
  @Trace learnProgress?: number;
  // 课程封面
  cover?: ResourceStr;
  // 时间
  time: number = 0;
  // 是否删除
  @Trace isDelete?: boolean;
}

@ObservedV2
export class MyCourseParam {
  static singleton: MyCourseParam;

  static instance() {
    if (!MyCourseParam.singleton) {
      MyCourseParam.singleton = new MyCourseParam();
    }
    return MyCourseParam.singleton;
  }

  @Trace isFreeCourseInit: boolean = false;
  @Trace isLearn: boolean = false;
}