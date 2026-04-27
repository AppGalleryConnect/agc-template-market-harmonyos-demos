import { Type } from '@kit.ArkUI';
import { WorkViewModel } from './WorkViewModel';

@ObservedV2
export class WorkListViewModel {
  @Type(WorkViewModel)
  @Trace public lists: WorkViewModel[] = [];

  // 新增
  addList(newWork: WorkViewModel): void {
    this.lists.push(newWork);
  }

  // 删除
  removeList(index: number): void {
    this.lists.splice(index, 1);
  }

  // 获取视频作品列表--过滤已完成数据
  getFinishWorkList() {
    return this.lists.filter(item => item.status === 'finish').reverse();
  }

  //获取草稿列表--过滤未完成数据
  getUnFinishWorkList() {
    return this.lists.filter(item => item.status === 'unFinish').reverse();
  }
}