import { VideoCard } from '../../model/Video';
import { cloudUrl, VideoDetail } from './SelectedPageData';

interface ChinesePageData {
  singStory: Array<VideoDetail>; // 听故事 学叙事
  threeCharacter: Array<VideoCard>; // 三字经 磨耳朵
}

/**
 * 汉语启蒙首页
 */
export const chinesePageData: ChinesePageData = {
  singStory: [
    {
      videoCard: {
        id: '',
        title: '世界名人故事',
        describe: '儿歌 经典音乐视频',
        tags: ['3-6岁', '人文表达'],
        plateType: '互动',
        videoType: 0,
        updateCount: 52,
        totalCount: 52,
        imageUrl: cloudUrl +
          'v0/children-education-kqxc3/common%2F1756539491_huge.png?token=451028ba-72e5-4a8d-a4af-0aa54e5a761a',
        isVip: true,
      },
      videoCardDetail: [],
    },
    {
      videoCard: {
        id: '',
        title: '听Alex老师讲故事，轻松学习200+高频词',
        describe: '互动视频',
        tags: ['3-6岁', '高频词汇'],
        videoType: 0,
        plateType: '互动',
        updateCount: 52,
        totalCount: 52,
        imageUrl: cloudUrl +
          'v0/children-education-kqxc3/common%2F1756539491_huge.png?token=451028ba-72e5-4a8d-a4af-0aa54e5a761a',
        isVip: true,
      },
      videoCardDetail: [],
    },
  ],
  threeCharacter: [{
    id: '',
    title: '两只老虎',
    describe: '',
    tags: ['儿歌', '儿童', '音乐'],
    videoType: 0,
    updateCount: 52,
    totalCount: 52,
    plateType: '视频',
    imageUrl: cloudUrl + 'v0/children-education-kqxc3/common%2F9.png?token=9bb42244-316a-4a34-873e-5e918bb95d53',
    isVip: true,

  },
    {
      id: '',
      title: '宝贝多米',
      describe: '',
      tags: ['儿歌', '儿童', '音乐'],
      videoType: 0,
      plateType: '视频',
      updateCount: 52,
      totalCount: 52,
      imageUrl: cloudUrl + 'v0/children-education-kqxc3/common%2F9.png?token=9bb42244-316a-4a34-873e-5e918bb95d53',
      isVip: true,
    },
    {
      id: '',
      title: '好宝宝',
      describe: '',
      tags: ['儿歌', '儿童', '音乐'],
      videoType: 0,
      plateType: '视频',
      updateCount: 52,
      totalCount: 52,
      imageUrl: cloudUrl + 'v0/children-education-kqxc3/common%2F9.png?token=9bb42244-316a-4a34-873e-5e918bb95d53',
      isVip: true,
    },
    {
      id: '',
      title: '春天在哪里',
      describe: '',
      tags: ['儿歌', '儿童', '音乐'],
      videoType: 0,
      plateType: '视频',
      updateCount: 52,
      totalCount: 52,
      imageUrl: cloudUrl + 'v0/children-education-kqxc3/common%2F9.png?token=9bb42244-316a-4a34-873e-5e918bb95d53',
      isVip: true,
    },
  ],
};