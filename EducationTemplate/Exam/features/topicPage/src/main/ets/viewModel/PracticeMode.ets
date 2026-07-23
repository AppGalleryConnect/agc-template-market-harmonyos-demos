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

// 练习模式
export class PracticeMode {
  // 选项图片
  imageSrc: ResourceStr;
  // 选项名称
  name: string;
  // 选项详情
  describe: string;

  constructor(imageSrc: ResourceStr, name: string, describe: string) {
    this.imageSrc = imageSrc;
    this.name = name;
    this.describe = describe;
  }
}

export const PRACTICE_LIST_DATA: PracticeMode[] = [
  new PracticeMode($r('app.media.ic_sequence'), '每日一练', '1/3256'),
  new PracticeMode($r('app.media.ic_practice_simulations'), '模拟考试', '仿真模拟'),
  new PracticeMode($r('app.media.ic_practice_test_paper'), '全真试卷', '深度检测备考水平'),
  new PracticeMode($r('app.media.ic_wrong_question'), '错题练习', '做错题查漏补缺'),
]

/**
 * 实现IDataSource接口的对象，用于瀑布流组件加载数据
 */
export class PracticeDataSource implements IDataSource {
  private dataArray: PracticeMode[] = [];
  private listeners: DataChangeListener[] = [];

  constructor(dataArray: PracticeMode[]) {
    for (let i = 0; i < dataArray.length; i++) {
      this.dataArray.push(dataArray[i]);
    }
  }

  /**
   * 获取索引对应的数据
   * @param index 数组索引
   * @returns
   */
  public getData(index: number): PracticeMode {
    return this.dataArray[index];
  }

  /**
   * 获取数据总数
   * @returns
   */
  public totalCount(): number {
    return this.dataArray.length;
  }

  /**
   * 注册改变数据的控制器
   * @param listener 数据控制器
   */
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  /**
   * 注销改变数据的控制器
   * @param listener 数据控制器
   */
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  /**
   * 通知控制器数据重新加载
   */
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  /**
   * 通知控制器数据增加
   * @param index 数组索引
   */
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  /**
   * 通知控制器数据变化
   * @param index 数组索引
   */
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  /**
   * 通知控制器数据删除
   * @param index 数组索引
   */
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  /**
   * 通知控制器数据位置变化
   * @param from 起始位置
   * @param to 最终位置
   */
  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }
}

/**
 *  科目练习
 */
export class SubjectExercises {
  // 选项图片
  imageSrc: ResourceStr;
  // 标题
  name: string;
  // 进度
  progress: number = 0;
  // 总数
  total: number = 0;
  type: string = 'pdf';
  url: string = '';

  constructor(imageSrc: ResourceStr, name: string, progress: number, total: number, type: string,
    url: string) {
    this.imageSrc = imageSrc;
    this.name = name;
    this.progress = progress;
    this.total = total;
    this.type = type;
    this.url = url;
  }
}

export const SUB_EXERCISES_DATA: SubjectExercises[] = [
  new SubjectExercises($r('app.media.ic_public_pdf_file_textured'), '建筑工程经济', 80, 100, 'pdf',
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-nkths' +
      '/test.pdf?token=9ef66402-ae35-4ba9-9507-caaf44513015' ),
  new SubjectExercises($r('app.media.ic_public_compressed_file_textured'), '建筑工程项目统筹', 10, 3411, 'zip', ''),
  new SubjectExercises($r('app.media.ic_public_word_file_textured'), '建筑工程项目管理', 20, 200, 'word',
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-nkths/' +
      'test1.docx?token=22a882b6-6818-4adb-9386-7aad59838806'),
]