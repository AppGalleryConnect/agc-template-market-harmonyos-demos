import { NewsEnum, VideoEnum } from '../../constants/Constants';
import { BaseNews } from '../../database/NewsType';

export class MockVideo {
  static mineList: BaseNews[] = [
    {
      id: 'video_mine_1',
      type: NewsEnum.Video,
      title: '《华为逆行者》科摩罗篇：驻守火山岛，他们是联接科摩罗群岛的信使',
      tags: ['华为', '海外', '火山岛', '逆行者'],
      authorId: '001',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_9',
        newsType: 1,
      }, {
        newsId: 'article_11',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/73253951779340a39a7763e29f40ccb8.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/73253951779340a39a7763e29f40ccb8.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 405504,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'video_mine_2',
      type: NewsEnum.Video,
      title: '在马达加斯加，和盘古一起与风暴赛跑',
      tags: ['马达加斯加', '盘古', '风暴', '海外'],
      authorId: '001',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_6',
        newsType: 1,
      }, {
        newsId: 'article_7',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/1fe450a626db4fc9ad86a960c60ea993.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/2644ff4ada00431f91c7d31209cf5f9b.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/1fe450a626db4fc9ad86a960c60ea993.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/2644ff4ada00431f91c7d31209cf5f9b.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 425386,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
  ];
  // 正在直播2条、即将直播4条、精彩回放8条
  static liveVideoList: BaseNews[] = [
    // 正在直播
    {
      id: 'live_video1',
      type: NewsEnum.Video,
      title: '新技术通话，让每一次连接超越想象',
      tags: ['新科技', '通话', '链接', '科技'],
      authorId: 'author_1',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 1,
      shareCount: 0,
      isLiked: true,
      isMarked: false,
      recommends: [{
        newsId: 'article_10',
        newsType: 1,
      }, {
        newsId: 'article_11',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/a20e0965e56a4dc498fc33ee23750c0d.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/a20e0965e56a4dc498fc33ee23750c0d.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 134506,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      liveStartTime: Date.now() - 2 * 60 * 1000, // 2分钟前开始
      liveEndTime: Date.now() - 2 * 60 * 1000 + 60 * 60 * 1000, // 直播60分钟
    },
    // 正在直播
    {
      id: 'live_video2',
      type: NewsEnum.Video,
      title: 'AI技术，让科技与自然共生',
      tags: ['AI', '科技', '自然', '进步'],
      authorId: 'author_2',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 1,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: true,
      recommends: [{
        newsId: 'article_10',
        newsType: 1,
      }, {
        newsId: 'article_11',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/daa381bc66604878bd403ef77c1c458d.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/935d7a0c9e4a41db95de250a004ce6a7.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/daa381bc66604878bd403ef77c1c458d.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/935d7a0c9e4a41db95de250a004ce6a7.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 204800,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      liveStartTime: Date.now() - 5 * 60 * 1000, // 5分钟前开始
      liveEndTime: Date.now() - 5 * 60 * 1000 + 90 * 60 * 1000, // 直播90分钟
    },
    // 即将直播
    {
      id: 'live_video3',
      type: NewsEnum.Video,
      title: '用高新科技，为黄河三角洲鸟类生态保护开创更多可能',
      tags: ['高新科技', '黄河三角洲', '鸟类生态', '新场景'],
      authorId: 'author_3',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_10',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/95c55588cbdb4b999eeae0c069dbc5d9.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/eb8efe3c1000428e8619a47c1e110922.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/95c55588cbdb4b999eeae0c069dbc5d9.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/eb8efe3c1000428e8619a47c1e110922.jpg',
      videoType: VideoEnum.Landscape,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      liveStartTime: Date.now() + 1 * 60 * 1000, // 1分钟后开始
      liveEndTime: Date.now() + 1 * 60 * 1000 + 60 * 60 * 1000, // 直播60分钟
    },
    // 即将直播
    {
      id: 'live_video4',
      type: NewsEnum.Video,
      title: '《海外逆行者》科摩罗篇：驻守火山岛，他们是联接科摩罗群岛的信使',
      tags: ['华为', '海外', '火山岛', '逆行者'],
      authorId: 'author_4',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_9',
        newsType: 1,
      }, {
        newsId: 'article_11',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/73253951779340a39a7763e29f40ccb8.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/73253951779340a39a7763e29f40ccb8.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 405504,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      liveStartTime: Date.now() + 5 * 60 * 1000, // 5分钟后开始
      liveEndTime: Date.now() + 5 * 60 * 1000 + 90 * 60 * 1000, // 直播90分钟
    },
    // 即将直播
    {
      id: 'live_video5',
      type: NewsEnum.Video,
      title: '在冰岛，和盘古一起与风暴赛跑',
      tags: ['冰岛', '盘古', '风暴'],
      authorId: 'author_5',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_6',
        newsType: 1,
      }, {
        newsId: 'article_7',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/1fe450a626db4fc9ad86a960c60ea993.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/2644ff4ada00431f91c7d31209cf5f9b.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/1fe450a626db4fc9ad86a960c60ea993.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/2644ff4ada00431f91c7d31209cf5f9b.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 425386,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      liveStartTime: Date.now() + 30 * 60 * 1000, // 30分钟后开始
      liveEndTime: Date.now() + 30 * 60 * 1000 + 60 * 60 * 1000, // 直播60分钟
    },
    // 即将直播
    {
      id: 'live_video6',
      type: NewsEnum.Video,
      title: 'AI提取的所谓综合排名以“开创性+跨学科影响+方法论',
      tags: ['AI', '跨学科', '综合排名'],
      authorId: 'author_6',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_6',
        newsType: 1,
      }, {
        newsId: 'article_7',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
        },
      ],
      videoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
      videoDuration: 134506,
      videoType: VideoEnum.Landscape,
      playCount: '1700',
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
      liveStartTime: Date.now() + 90 * 60 * 1000, // 90分钟后开始
      liveEndTime: Date.now() + 90 * 60 * 1000 + 60 * 60 * 1000, // 直播60分钟
    },
    // 剩下都是精彩回放
    {
      id: 'live_video7',
      type: NewsEnum.Video,
      title: '综合排名以“开创性+跨学科影响+方法论',
      tags: ['AI', '跨学科', '综合排名'],
      authorId: 'author_7',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_2',
        newsType: 1,
      }, {
        newsId: 'article_5',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
        },
      ],
      videoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
      videoDuration: 134506,
      videoType: VideoEnum.Landscape,
      playCount: '45000',
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
      liveEndTime: Date.now() - 60 * 60 * 1000,
    },
    {
      id: 'live_video8',
      type: NewsEnum.Video,
      title: '第12波！伊朗猛砸高超弹，400秒击中以色列，撕裂世界第一防空网',
      tags: ['伊朗', '战争', '以色列', '导弹'],
      authorId: 'author_4',
      markCount: 0,
      createTime: 1751089800000,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_10',
        newsType: 1,
      }],
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
        },
      ],
      videoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
      videoDuration: 134506,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
      liveEndTime: Date.now() - 60 * 60 * 1000,
    },
    {
      id: 'live_video9',
      type: NewsEnum.Video,
      title: '新通话，让每一次连接超越想象',
      tags: ['新通话', '链接', '科技'],
      authorId: 'author_1',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 1,
      shareCount: 0,
      isLiked: true,
      isMarked: false,
      recommends: [{
        newsId: 'article_10',
        newsType: 1,
      }, {
        newsId: 'article_11',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/a20e0965e56a4dc498fc33ee23750c0d.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/a20e0965e56a4dc498fc33ee23750c0d.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 134506,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      liveEndTime: Date.now() - 60 * 60 * 1000,
    },
    {
      id: 'live_video10',
      type: NewsEnum.Video,
      title: '以行践言，让科技与自然共生',
      tags: ['科技', '自然', '实践'],
      authorId: 'author_2',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 1,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: true,
      recommends: [{
        newsId: 'article_10',
        newsType: 1,
      }, {
        newsId: 'article_11',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/daa381bc66604878bd403ef77c1c458d.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/935d7a0c9e4a41db95de250a004ce6a7.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/daa381bc66604878bd403ef77c1c458d.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/935d7a0c9e4a41db95de250a004ce6a7.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 204800,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      liveEndTime: Date.now() - 60 * 60 * 1000,
    },
    {
      id: 'live_video11',
      type: NewsEnum.Video,
      title: '用科技为黄河三角洲鸟类生态保护开创更多可能',
      tags: ['科技', '黄河三角洲', '鸟类保护'],
      authorId: 'author_3',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_10',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/95c55588cbdb4b999eeae0c069dbc5d9.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/eb8efe3c1000428e8619a47c1e110922.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/95c55588cbdb4b999eeae0c069dbc5d9.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/eb8efe3c1000428e8619a47c1e110922.jpg',
      videoType: VideoEnum.Landscape,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      liveEndTime: Date.now() - 60 * 60 * 1000,
    },
    {
      id: 'live_video12',
      type: NewsEnum.Video,
      title: '《华为逆行者》科摩罗篇：驻守火山岛，他们是联接科摩罗群岛的信使',
      tags: ['华为', '海外', '火山岛', '逆行者'],
      authorId: 'author_4',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_9',
        newsType: 1,
      }, {
        newsId: 'article_11',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/73253951779340a39a7763e29f40ccb8.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/73253951779340a39a7763e29f40ccb8.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 405504,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      liveEndTime: Date.now() - 60 * 60 * 1000,
    },
    {
      id: 'live_video13',
      type: NewsEnum.Video,
      title: '在马达加斯加，和盘古一起与风暴赛跑',
      tags: ['马达加斯加', '盘古', '风暴', '海外'],
      authorId: 'author_5',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_6',
        newsType: 1,
      }, {
        newsId: 'article_7',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/1fe450a626db4fc9ad86a960c60ea993.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/2644ff4ada00431f91c7d31209cf5f9b.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/1fe450a626db4fc9ad86a960c60ea993.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/2644ff4ada00431f91c7d31209cf5f9b.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 425386,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      liveEndTime: Date.now() - 60 * 60 * 1000,
    },
    {
      id: 'live_video14',
      type: NewsEnum.Video,
      title: 'DeepSeek的所谓综合排名以“开创性+跨学科影响+方法论',
      tags: ['DeepSeek', '综合排名', '跨学科', '影响力'],
      authorId: 'author_6',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_6',
        newsType: 1,
      }, {
        newsId: 'article_7',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
        },
      ],
      videoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
      videoDuration: 134506,
      videoType: VideoEnum.Landscape,
      playCount: '1700',
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
      liveEndTime: Date.now() - 60 * 60 * 1000,
    },
  ]
  static list: BaseNews[] = [
    ...MockVideo.mineList,
    ...MockVideo.liveVideoList,
    {
      id: 'video1',
      type: NewsEnum.Video,
      title: '新通话，让每一次连接超越想象',
      tags: ['新通话', '链接', '科技'],
      authorId: 'author_1',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 1,
      shareCount: 0,
      isLiked: true,
      isMarked: false,
      recommends: [{
        newsId: 'article_10',
        newsType: 1,
      }, {
        newsId: 'article_11',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/a20e0965e56a4dc498fc33ee23750c0d.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/a20e0965e56a4dc498fc33ee23750c0d.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 134506,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'video2',
      type: NewsEnum.Video,
      title: '以行践言，让科技与自然共生',
      tags: ['科技', '自然', '实践'],
      authorId: 'author_2',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 1,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: true,
      recommends: [{
        newsId: 'article_10',
        newsType: 1,
      }, {
        newsId: 'article_11',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/daa381bc66604878bd403ef77c1c458d.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/935d7a0c9e4a41db95de250a004ce6a7.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/daa381bc66604878bd403ef77c1c458d.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/935d7a0c9e4a41db95de250a004ce6a7.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 204800,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'video3',
      type: NewsEnum.Video,
      title: '用科技为黄河三角洲鸟类生态保护开创更多可能',
      tags: ['科技', '黄河三角洲', '鸟类保护'],
      authorId: 'author_3',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_10',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/95c55588cbdb4b999eeae0c069dbc5d9.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/eb8efe3c1000428e8619a47c1e110922.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/95c55588cbdb4b999eeae0c069dbc5d9.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/eb8efe3c1000428e8619a47c1e110922.jpg',
      videoType: VideoEnum.Landscape,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
      videoDuration: 371605,
    },
    {
      id: 'video4',
      type: NewsEnum.Video,
      title: '《华为逆行者》科摩罗篇：驻守火山岛，他们是联接科摩罗群岛的信使',
      tags: ['华为', '海外', '火山岛', '逆行者'],
      authorId: 'author_4',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_9',
        newsType: 1,
      }, {
        newsId: 'article_11',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/73253951779340a39a7763e29f40ccb8.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/73253951779340a39a7763e29f40ccb8.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 405504,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'video5',
      type: NewsEnum.Video,
      title: '在马达加斯加，和盘古一起与风暴赛跑',
      tags: ['马达加斯加', '盘古', '风暴', '海外'],
      authorId: 'author_5',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_6',
        newsType: 1,
      }, {
        newsId: 'article_7',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/1fe450a626db4fc9ad86a960c60ea993.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/2644ff4ada00431f91c7d31209cf5f9b.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/1fe450a626db4fc9ad86a960c60ea993.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/2644ff4ada00431f91c7d31209cf5f9b.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 425386,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomVideoCard","name":"视频"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
      },
    },
    {
      id: 'video6',
      type: NewsEnum.Video,
      title: 'DeepSeek的所谓综合排名以“开创性+跨学科影响+方法论',
      tags: ['DeepSeek', '综合排名', '跨学科', '影响力'],
      authorId: 'author_6',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_6',
        newsType: 1,
      }, {
        newsId: 'article_7',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
        },
      ],
      videoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 134506,
      playCount: '1700',
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
    {
      id: 'video7',
      type: NewsEnum.Video,
      title: '综合排名以“开创性+跨学科影响+方法论',
      tags: ['综合排名', '跨学科', '影响力'],
      authorId: 'author_7',
      createTime: new Date().getTime(),
      commentCount: 10,
      markCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_2',
        newsType: 1,
      }, {
        newsId: 'article_5',
        newsType: 1,
      }],
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/daa381bc66604878bd403ef77c1c458d.mp4',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/935d7a0c9e4a41db95de250a004ce6a7.jpg',
        },
      ],
      videoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/daa381bc66604878bd403ef77c1c458d.mp4',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/935d7a0c9e4a41db95de250a004ce6a7.jpg',
      videoType: VideoEnum.Landscape,
      videoDuration: 204800,
      playCount: '45000',
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
    {
      id: 'video8',
      type: NewsEnum.Video,
      title: '第13波！伊朗猛砸高超弹，400秒击中以色列，撕裂世界第一防空网',
      tags: ['伊朗', '战争', '以色列', '导弹'],
      authorId: 'author_4',
      markCount: 0,
      createTime: 1751089800000,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_10',
        newsType: 1,
      }],
      commentCount: 25,
      likeCount: 6000,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30',
          surfaceUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
        },
      ],
      videoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-o7oax/template_source%2Fvideo_1.mp4?token=6504c93e-6dc3-423b-aff1-1e594711ba30',
      coverUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/6c813cb0874744f4b54fd61f1f9e8f24.jpg',
      videoDuration: 134506,
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"TopTextBottomBigImageCard","name":"上文下大图"}],"style":{"backgroundColor":"#FFFFFF","padding-top":"12","padding-bottom":"12"}}]}]}',
      },
    },
  ];
}