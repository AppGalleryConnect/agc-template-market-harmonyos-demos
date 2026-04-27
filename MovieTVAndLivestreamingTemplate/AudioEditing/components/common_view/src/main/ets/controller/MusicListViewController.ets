export interface MusicParam {
  uri: string //音频uri，
  title: string //音频标题
  duration: number //音频时长（毫秒）
  size: string //音频大小（KB）
  format: string //音频格式
  path: string //音频沙箱路径
}

export class MusicListViewController {
  //添加数据
  addData = (musicData: MusicParam, type: 'music' | 'work') => {

  }
  //筛选数据
  filterData = (val: string) => {

  }

  filterSelect = () =>{

  }
}