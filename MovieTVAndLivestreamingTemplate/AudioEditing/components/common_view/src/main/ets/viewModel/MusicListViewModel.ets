import { MusicViewModel } from './MusicViewModel';
import { Type } from '@kit.ArkUI';
import { MusicParam } from '../controller/MusicListViewController';
import { FileUtil, PersistenceV2Util } from 'audio_common';
import { GlobalContext } from 'common';


@ObservedV2
export class MusicViewModelArray extends Array<MusicViewModel> {
}

@ObservedV2
export class MusicListViewModel {
  @Type(MusicViewModelArray)
  @Trace list: MusicViewModelArray = new MusicViewModelArray()
  persistenceV2Util = new PersistenceV2Util()

  /*
   * 从本地获取持久化的数据
   * type: music(音乐库的数据)， work(作品集的数据)
   */
  loadData(type: 'music' | 'work') {
    let tempStr = this.persistenceV2Util.getData(type);
    this.clear()
    if (tempStr) {
      const tmepData = JSON.parse(tempStr) as MusicViewModelArray
      for (let index = 0; index < tmepData.length; index++) {
        const element = tmepData[index];
        const tempMusicViewModel =
          new MusicViewModel(element.uri, element.title, element.duration, element.size, element.format,
            element.sourcePath)
        this.list.push(tempMusicViewModel)
      }
    }
  }

  /*
   * 清空数据
   */
  clear() {
    this.list = new MusicViewModelArray()
  }

  addData(musicData: MusicParam, type: 'music' | 'work') {
    if (this.list.findIndex(item => item.uri === musicData.uri) < 0) { //列表中没有该元素
      let tempMusic =
        new MusicViewModel(musicData.uri, musicData.title, musicData.duration, musicData.size, musicData.format,
          musicData.path)
      const tempList = JSON.parse(JSON.stringify(this.list)) as MusicViewModelArray
      // 优化：将新数据插入到列表头部
      tempList.unshift(tempMusic)
      if (!this.persistenceV2Util.setData(JSON.stringify(tempList), type)) {
        GlobalContext.getUIContext().getPromptAction().showToast({
          message: '数据存储超出限制'
        })
        return
      }

      this.list.unshift(tempMusic)
    }

  }

  //全选
  checkedAll() {
    this.list.forEach((item) => {
      item.setCheckBoxStatus(true)
    })
  }

  //取消全选
  unCheckAll() {
    this.list.forEach((item) => {
      item.setCheckBoxStatus(false)
    })
  }

  //删除数据
  delData(data: MusicViewModelArray, isMusic?: boolean) {
    data.forEach((item: MusicViewModel) => {
      FileUtil.deleteFile(item.sourcePath)
      this.list = this.list.filter(val => val.sourcePath !== item.sourcePath)
    })
    if (isMusic) {
      this.persistenceV2Util.setData(JSON.stringify(this.list), 'music')
    } else {
      this.persistenceV2Util.setData(JSON.stringify(this.list), 'work')
    }
  }

  setTitle(index: number, title: string) {
    this.list[index].setTitle(title)
  }
}
