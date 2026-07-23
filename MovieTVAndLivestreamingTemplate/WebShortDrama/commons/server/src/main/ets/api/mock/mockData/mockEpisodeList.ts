import { Episode } from "./bean";

let urls: Array<string> = [
  'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/3.m3u8',
  'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/2.m3u8',
  'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/3.m3u8'
]
let videoDuration = [
  30000,
  23720,
  29840
]
export const getEpisodeList = (): Array<Episode> => {
  let episodeList: Array<Episode> = new Array;
  for (let i = 0; i < 80; i++) {
    episodeList.push({
      id: i + 1,
      url: urls[i%3],
      duration:videoDuration[i%3],
      desc: '非常好，加1',
      dramaId: 'drama_1',
      socialInfo: {
        likeCount: '123',
        favoriteCount: '456',
        shareCount: '789',
        commentCount: '3'
      }
    },)
  }
  return episodeList;
}