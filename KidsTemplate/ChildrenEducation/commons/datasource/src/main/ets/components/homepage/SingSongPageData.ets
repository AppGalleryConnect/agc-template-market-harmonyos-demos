import { VideoCard } from '../../../../../Index';
import { cloudUrl } from './SelectedPageData';

interface SingSongPageData {
  childrenSong: Array<VideoCard>;
}

/**
 * 儿歌首页
 */
export const singSongPageData: SingSongPageData = {
  childrenSong: [{
    id: '',
    title: '两只老虎',
    describe: '',
    tags: ['儿歌', '儿童', '音乐'],
    videoType: 0,
    updateCount: 52,
    totalCount: 52,
    imageUrl: cloudUrl + 'v0/children-education-kqxc3/common%2F5.png?token=53ef30f8-c649-4765-9c89-49ad9360a19d',
    isVip: true,
  },
    {
      id: '',
      title: '宝贝多米',
      describe: '',
      tags: ['儿歌', '儿童', '音乐'],
      videoType: 0,
      updateCount: 52,
      totalCount: 52,
      imageUrl: cloudUrl +
        'v0/children-education-kqxc3/common%2Fshutterstock_1682700667_1024.jpg?token=8abbee46-9b9a-40a7-bc40-fe766bce1137',
      isVip: true,
    },

    {
      id: '',
      title: '好宝宝',
      describe: '',
      tags: ['儿歌', '儿童', '音乐'],
      videoType: 0,
      updateCount: 52,
      totalCount: 52,
      imageUrl: cloudUrl +
        'v0/children-education-kqxc3/common%2Fshutterstock_1682700667_1024.jpg?token=8abbee46-9b9a-40a7-bc40-fe766bce1137',
      isVip: true,
    },
    {
      id: '',
      title: '春天在哪里',
      describe: '',
      tags: ['儿歌', '儿童', '音乐'],
      videoType: 0,
      updateCount: 52,
      totalCount: 52,
      imageUrl: cloudUrl + 'v0/children-education-kqxc3/common%2F5.png?token=53ef30f8-c649-4765-9c89-49ad9360a19d',
      isVip: true,
    },
  ]
};
