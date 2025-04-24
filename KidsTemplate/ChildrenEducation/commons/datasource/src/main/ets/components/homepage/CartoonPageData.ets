import { VideoCard, VideoCardDetail } from '../../model/Video';
import { cloudUrl, VideoDetail } from './SelectedPageData';

interface CartoonPageData {
  superCar: VideoDetail,
  domiParadise: VideoDetail,
  funEncyclopedia: Array<VideoCard>, // 趣味百科
}

/**
 * 看动画
 */
export const cartoonPageData: CartoonPageData = {
  superCar: {
    videoCard: {
      id: '',
      title: '超级汽车第四季',
      describe: '超级汽车，守护正义与美好',
      tags: ['变身', '救援', '勇敢正义'],
      videoType: 0,
      updateCount: 52,
      totalCount: 52,
      imageUrl: cloudUrl + 'v0/children-education-kqxc3/common%2Fhellorf_2239162006.jpg?token=cbaaca3d-e3b7-4005-8c27-36fa87224b86',
      isVip: true,
    },
    videoCardDetail: [],
  },
  domiParadise: {
    videoCard: {
      id: '',
      title: '宝贝多米益智乐园第二季',
      describe: '多米与朋友们的精彩生活',
      plateType: '动画',
      tags: ['童趣', '快乐成长'],
      videoType: 0,
      updateCount: 52,
      totalCount: 52,
      imageUrl: cloudUrl + 'v0/children-education-kqxc3/common%2F%E7%9F%A9%E5%BD%A2%203416(27).png?token=25b8be8c-b6b8-453b-9be1-da347fb07619',
      isVip: true,
    },
    videoCardDetail: [],
  },
  funEncyclopedia: [
    {
      id: '',
      title: '长城的作用是什么',
      describe: '',
      tags: [],
      videoType: 0,
      updateCount: 52,
      totalCount: 52,
      imageUrl: cloudUrl + 'v0/children-education-kqxc3/common%2F1.png?token=4a55b1ab-f0bf-46fa-a438-a2a4bb670a36',
      isVip: true,
    },
    {
      id: '',
      title: '珍珠是从哪儿来的',
      describe: '',
      tags: [],
      videoType: 0,
      updateCount: 47,
      totalCount: 52,
      imageUrl: cloudUrl + 'v0/children-education-kqxc3/common%2F6.png?token=d99b20a6-472a-497e-8296-8686e77a8074',
      isVip: true,
    },
    {
      id: '',
      title: '恐龙的诞生',
      describe: '',
      tags: [],
      videoType: 0,
      updateCount: 36,
      totalCount: 52,
      imageUrl: cloudUrl +
        'v0/children-education-kqxc3/common%2F%E7%9F%A9%E5%BD%A2%203416(3).png?token=e82cbb3d-0e46-4ed2-957e-4a7e3c8b440f',
      isVip: true,
    },
    {
      id: '',
      title: '宇航员的日常',
      describe: '',
      tags: [],
      videoType: 0,
      updateCount: 10,
      totalCount: 52,
      imageUrl: cloudUrl + 'v0/children-education-kqxc3/common%2F7.png?token=b08b5509-18b6-4902-881a-006f3cdc35c9',
      isVip: true,
    },
  ],
};