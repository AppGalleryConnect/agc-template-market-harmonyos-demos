import { container } from '@agctemplate/utils';
import { RequestAPI } from '@agctemplate/server';
import { LiveCard, LiveCardModel } from '@agctemplate/widgets';
import { getMedia } from '@agctemplate/resources';

export async function getTipInfos(searchText:string): Promise<Array<string>> {
  let list = await container.resolve(RequestAPI).getSearchTipList(searchText)
  return Promise.resolve(list.getBody().data)
}

export async function getSearchList(searchText: string, pageNum: number): Promise<Array<LiveCardModel>> {
  let list = await container.resolve(RequestAPI).getSearchLiveList({
    searchText: searchText,
    pageSize: 10,
    pageNum: pageNum
  })
  const result = list.getBody().liveList
    .map(live => {
      const item = new LiveCardModel({} as LiveCard)
      item.id = live.id
      item.cover = getMedia(live.cover)
      item.title = live.title
      item.streamer = live.streamer.nickName
      item.category = live.category
      item.watching = live.watching
      item.avatar = getMedia(live.streamer.avatar)
      item.status = live.status
      return item
    })
  return Promise.resolve(result)
}
