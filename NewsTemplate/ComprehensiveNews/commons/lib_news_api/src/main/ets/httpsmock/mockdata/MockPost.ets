import { NewsEnum } from '../../constants/Constants';
import { BaseNews } from '../../database/NewsType';
import { RequestListData } from '../../params/response/LayoutResponse';

export class MockPost {
  static mineList: BaseNews[] = [
    {
      id: 'post_mine_0',
      type: NewsEnum.Post,
      likeCount: 12,
      commentCount: 15,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_11',
        newsType: 1,
      }, {
        newsId: 'article_12',
        newsType: 1,
      }],
      shareCount: 120,
      markCount: 45,
      title: '假期的旅行碎片已加载完毕～。旅行哪里是逃离呀',
      tags: ['假期', '旅行', '毕业', '休假'],
      richContent: '',
      authorId: '001',
      createTime: 1751076002000,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/suo%2Fmoving_image1.jpg',
          surfaceUrl: '',
          movingVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/suo%2FMoving%20Video.mp4',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/suo%2Fmoving_image2.jpg',
          surfaceUrl: '',
          movingVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/suo%2FMoving%20Video(1).mp4',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_mine_1',
      type: NewsEnum.Post,
      likeCount: 12,
      commentCount: 15,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_11',
        newsType: 1,
      }, {
        newsId: 'article_12',
        newsType: 1,
      }],
      shareCount: 120,
      markCount: 45,
      title: '假期的旅行碎片已加载完毕～。旅行哪里是逃离呀',
      tags: ['假期', '旅行', '毕业', '休假'],
      richContent: '',
      authorId: '001',
      createTime: 1751076002000,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/suo%2F1.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/suo%2F11.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/suo%2F3.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/suo%2F4.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/suo%2F5.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/suo%2F6.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/suo%2F10.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/suo%2F12.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/suo%2F11.jpg',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_mine_2',
      type: NewsEnum.Post,
      likeCount: 12,
      commentCount: 15,
      isLiked: false,
      isMarked: false,
      recommends: [{
        newsId: 'article_11',
        newsType: 1,
      }, {
        newsId: 'article_12',
        newsType: 1,
      }],
      shareCount: 120,
      markCount: 45,
      tags: ['假期', '旅行', '毕业', '休假'],
      title: '假期的旅行碎片已加载完毕～。旅行哪里是逃离呀，分明是让你在人山人海里，重新找到自己的位置，原来旅行的意义，真的藏在那些不期而遇里，走在陌生的街道，看当地人慢悠悠地喝茶，突然懂了 “慢下来” 不是浪费时，原来自己比想象中更有韧性呀。',
      richContent: '',
      authorId: '001',
      createTime: 1751076002000,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_2.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_3.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_4.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_5.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_6.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_7.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_8.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_9.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_10.jpg',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_mine_3',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      isMarked: false,
      isLiked: false,
      markCount: 4500,
      shareCount: 12000,
      title: '[{"text":"在路上","type":"default"},{"text":"#旅行的意义#","type":"topic"}]',
      tags: ['旅行', '毕业', '在路上'],
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_13',
        newsType: 1,
      }],
      richContent: '',
      authorId: '001',
      createTime: 1750557602000,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_11.jpg',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
  ];
  static list: BaseNews[] = [
    ...MockPost.mineList,
    {
      id: 'post_1',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      shareCount: 12000,
      isLiked: true,
      isMarked: true,
      markCount: 4500,
      recommends: [{
        newsId: 'video6',
        newsType: 1,
      }, {
        newsId: 'video5',
        newsType: 1,
      }],
      tags: ['假期', '旅行', '毕业', '休假'],
      title: '[{"text":"#假期的旅行碎片已加载完毕#","type":"topic"},{"text":"旅行哪里是逃离呀，分明是让你在人山人海里，重新找到自己的位置，原来旅行的意义，真的藏在那些不期而遇里，走在陌生的街道，看当地人慢悠悠地喝茶，突然懂了 “慢下来” 不是浪费时，原来自己比想象中更有韧性呀。","type":"default"}]',
      richContent: '',
      authorId: 'author_6',
      createTime: 1751089800000,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_2.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_8.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_3.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_5.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_4.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_6.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_10.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_7.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_9.jpg',
          surfaceUrl: '',
        },

      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_2',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      markCount: 4500,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_13',
        newsType: 1,
      }],
      tags: ['旅行', '毕业', '在路上'],
      title: '[{"text":"让我康康谁在路上","type":"default"},{"text":"#旅行的意义#","type":"topic"}]',
      richContent: '',
      authorId: 'author_6',
      createTime: 1751089800000,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_11.jpg',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_3',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      markCount: 4500,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_13',
        newsType: 1,
      }],
      tags: ['好好学习', '中美局势', '天下', '福建'],
      title: '[{"text":"#好好学习、天天向上#","type":"topic"},{"text":"#福建持续推进生态治理#","type":"topic"},{"text":"#中方决定同意与美方进行接触#","type":"topic"},{"text":"#伊朗猛砸高超弹，400秒击中以色列，撕裂世界第一防空网#","type":"topic"},{"text":"#美国取消对中国小额包裹免税政策正在实施中#","type":"topic"},{"text":"#中俄两国走出一条合作共赢的崭新道路#","type":"topic"},{"text":"#2025年社会物流总额将超360万亿元#","type":"topic"},{"text":"#住建部称住宅层高标准将提至不低于3米#","type":"topic"},{"text":"学而时习之","type":"default"}]',
      richContent: '',
      authorId: 'author_6',
      createTime: 1751089800000,
      postImgList: [
        {
          picVideoUrl: 'https://e-file.huawei.com/mediares/Video_MCD/EBG/PUBLIC/zh/2025/04/3c04b872-197d-4551-a353-0eb99def6ca2.png',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://e-file.huawei.com/mediares/Video_MCD/EBG/PUBLIC/zh/2025/05/43f01339-48e0-4e5d-a433-ccb8c423cdfe.png',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/2644ff4ada00431f91c7d31209cf5f9b.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_4',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      markCount: 4500,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_13',
        newsType: 1,
      }],
      tags: ['假期', '旅行', '毕业', '休假'],
      title: '[{"text":"#旅行的意义#","type":"topic"},{"text":"#假期的旅行碎片已加载完毕#","type":"topic"},{"text":"清晨的阳光总是带着点懒意，悄悄爬上窗帘缝隙时，先别急着掀开被子。听会儿窗外的鸟鸣，是麻雀在树枝上跳来跳去的碎语，还是鸽子带着哨音从楼顶掠过？","type":"default"}]',
      richContent: '',
      authorId: 'author_5',
      createTime: 1751089800000,
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_5',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      markCount: 4500,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_13',
        newsType: 1,
      }],
      tags: ['假期', '旅行', '毕业', '休假'],
      title: '[{"text":"#旅行的意义#","type":"topic"},{"text":"#假期的旅行碎片已加载完毕#","type":"topic"},{"text":"雨后黄山现 “佛光” 奇观，云海之上光晕环绕宛如仙境，梯田云雾缭绕如 “天梯”，农人耕作身影勾勒出秋日农耕画卷","type":"default"}]',
      richContent: '',
      authorId: 'author_2',
      createTime: 1751089800000,
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F4_2514153291_huge.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F94_2103664649_huge%E5%B0%8F.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F38_hellorf_hi2241563890%E5%B0%8F.jpg',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_6',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      markCount: 4500,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_13',
        newsType: 1,
      }],
      tags: ['假期', '旅行', '毕业', '休假'],
      title: '[{"text":"#旅行的意义#","type":"topic"},{"text":"江南古镇入梅：雨打芭蕉润青瓦，水墨画里藏初夏","type":"default"}]',
      richContent: '',
      authorId: 'author_5',
      createTime: 1751089800000,
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_7',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      markCount: 4500,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_13',
        newsType: 1,
      }],
      tags: ['假期', '旅行', '毕业', '休假'],
      title: '[{"text":"#旅行的意义#","type":"topic"},{"text":"塞北草原秋意浓，千亩胡杨林披 “金衣”，每日吸引超千名摄影爱好者，东北雪乡迎来今冬初雪，雪蘑菇、雪蛋糕造型憨态可掬成网红打卡点","type":"default"}]',
      richContent: '',
      authorId: 'author_9',
      createTime: 1751089800000,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F18_2549393977_huge%E5%B0%8F.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F20_hellorf_2239003531.jpg',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_8',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      markCount: 4500,
      recommends: [{
        newsId: 'article_6',
        newsType: 1,
      }, {
        newsId: 'article_14',
        newsType: 1,
      }],
      tags: ['假期', '旅行', '毕业', '休假'],
      title: '[{"text":"#旅行的意义#","type":"topic"},{"text":"春色与红韵交织，独好园焕新颜。春风拂过会昌山麓，风景独好园内红梅竞放，与青砖黛瓦的毛泽东旧居与粤赣省委旧址群相映成趣。这里是毛泽东盛赞 “风景这边独好” 的地方，更是红色历史的鲜活见证。春日里，游客漫步园区，既可在古树下赏花拍照，又能在革命旧址中触摸历史的温度。一树红梅，一墙标语，皆是革命精神与自然生机的共舞","type":"default"}]',
      richContent: '',
      authorId: 'author_8',
      createTime: 1751089800000,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F38_hellorf_hi2241563890%E5%B0%8F.jpg?token=4a1b3c5f-ae0d-4115-bd1a-67315fa59910',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F94_2103664649_huge%E5%B0%8F.jpg?token=46fd270e-1c53-4a1b-8bb2-fabba4fa70d3',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_9',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      markCount: 4500,
      recommends: [{
        newsId: 'article_6',
        newsType: 1,
      }, {
        newsId: 'article_14',
        newsType: 1,
      }],
      tags: ['福建', '旅行', '毕业', '休假'],
      title: '[{"text":"#福建持续推进生态治理#","type":"topic"},{"text":"夏日的福建安溪金谷村溪流清澈、绿树成荫、游人如织。近年来，当地持续推进生态治理，让曾经环境脏乱的小村庄，水变清了、岸也更绿了。走进金谷村，清澈的金谷溪穿村而过，两岸绿树成荫，风格艺术感满满的设施错落有致地分布。游客们有的在溪边戏水，有的在岸边喝茶聊天、休憩纳凉，享受惬意的午后时光","type":"default"}]',
      richContent: '',
      authorId: 'author_8',
      createTime: 1751089800000,
      postImgList: [
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F29_2590322759_huge.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F97_hellorf_hi2244493932.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2Fhellorf_hi2239368115%E5%B0%8F.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F41_1734189599_huge%E5%B0%8F.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F20_hellorf_2239003531.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F2387811837_huge%E5%B0%8F.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F2_2302601201_huge.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F97_hellorf_hi2244493932.jpg',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/new%2F97_hellorf_hi2244493932.jpg',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_10',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      markCount: 4500,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_13',
        newsType: 1,
      }],
      tags: ['美国', '免税', '政策', '小额包裹'],
      title: '[{"text":"#美国取消对中国小额包裹免税政策正在实施中#","type":"topic"},{"text":"#好好学习、天天向上#","type":"topic"},{"text":"看后面的政策如何演进，我爱学习","type":"default"}]',
      richContent: '',
      authorId: 'author_6',
      createTime: 1751089800000,
      postImgList: [
        {
          picVideoUrl: 'https://e-file.huawei.com/mediares/Video_MCD/EBG/PUBLIC/zh/2025/04/3c04b872-197d-4551-a353-0eb99def6ca2.png',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_11',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      markCount: 4500,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_13',
        newsType: 1,
      }],
      tags: ['伊朗', '以色列', '导弹', '战争'],
      title: '[{"text":"#伊朗猛砸高超弹，400秒击中以色列，撕裂世界第一防空网#","type":"topic"},{"text":"#好好学习、天天向上#","type":"topic"},{"text":"看天下局势，一起来学习","type":"default"}]',
      richContent: '',
      authorId: 'author_6',
      createTime: 1751089800000,
      postImgList: [
        {
          picVideoUrl: 'https://e-file.huawei.com/mediares/Video_MCD/EBG/PUBLIC/zh/2025/05/43f01339-48e0-4e5d-a433-ccb8c423cdfe.png',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_12',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      markCount: 4500,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_13',
        newsType: 1,
      }],
      tags: ['美国', '免税', '政策', '小额包裹'],
      title: '[{"text":"#美国取消对中国小额包裹免税政策正在实施中#","type":"topic"},{"text":"#好好学习、天天向上#","type":"topic"},{"text":"一起来看免税政策  每日学习打卡","type":"default"}]',
      richContent: '',
      authorId: 'author_6',
      createTime: 1751089800000,
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/2644ff4ada00431f91c7d31209cf5f9b.jpg',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_13',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      markCount: 4500,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_13',
        newsType: 1,
      }],
      tags: ['美国', '局势', '政策', '外交'],
      title: '[{"text":"#中方决定同意与美方进行接触#","type":"topic"},{"text":"#好好学习、天天向上#","type":"topic"},{"text":"中美局势，又来学习国际局势啦","type":"default"}]',
      richContent: '',
      authorId: 'author_6',
      createTime: 1751089800000,
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_14',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      markCount: 4500,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_13',
        newsType: 1,
      }],
      tags: ['俄罗斯', '合作', '周边国家', '国际局势'],
      title: '[{"text":"#中俄两国走出一条合作共赢的崭新道路#","type":"topic"},{"text":"#好好学习、天天向上#","type":"topic"},{"text":"中俄局势，周边国家学习","type":"default"}]',
      richContent: '',
      authorId: 'author_6',
      createTime: 1751089800000,
      postImgList: [
        {
          picVideoUrl: 'https://e-file.huawei.com/mediares/Video_MCD/EBG/PUBLIC/zh/2025/04/3c04b872-197d-4551-a353-0eb99def6ca2.png',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_15',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      markCount: 4500,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_13',
        newsType: 1,
      }],
      tags: ['物流', '社会新闻', '运输'],
      title: '[{"text":"#2025年社会物流总额将超360万亿元#","type":"topic"},{"text":"#好好学习、天天向上#","type":"topic"},{"text":"物流运输，社会新闻学习","type":"default"}]',
      richContent: '',
      authorId: 'author_6',
      createTime: 1751089800000,
      postImgList: [
        {
          picVideoUrl: 'https://e-file.huawei.com/mediares/Video_MCD/EBG/PUBLIC/zh/2025/05/43f01339-48e0-4e5d-a433-ccb8c423cdfe.png',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_16',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      markCount: 4500,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_13',
        newsType: 1,
      }],
      tags: ['住房', '标准', '民生', '房产'],
      title: '[{"text":"#住建部称住宅层高标准将提至不低于3米#","type":"topic"},{"text":"#好好学习、天天向上#","type":"topic"},{"text":"房产新闻，住房民生学习","type":"default"}]',
      richContent: '',
      authorId: 'author_6',
      createTime: 1751089800000,
      postImgList: [
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/2644ff4ada00431f91c7d31209cf5f9b.jpg',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_17',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      markCount: 4500,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_13',
        newsType: 1,
      }],
      tags: ['课堂', '竞赛', '学校'],
      title: '[{"text":"#好好学习、天天向上#","type":"topic"},{"text":"通过趣味课堂、知识竞赛等形式，激发学生学习热情，营造积极向上的校园氛围。","type":"default"}]',
      richContent: '',
      authorId: 'author_6',
      createTime: 1751089800000,
      postImgList: [
        {
          picVideoUrl: 'https://e-file.huawei.com/mediares/Video_MCD/EBG/PUBLIC/zh/2025/04/3c04b872-197d-4551-a353-0eb99def6ca2.png',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/2644ff4ada00431f91c7d31209cf5f9b.jpg',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
    {
      id: 'post_18',
      type: NewsEnum.Post,
      likeCount: 36,
      commentCount: 175,
      shareCount: 12000,
      isLiked: false,
      isMarked: false,
      markCount: 4500,
      recommends: [{
        newsId: 'article_8',
        newsType: 1,
      }, {
        newsId: 'article_13',
        newsType: 1,
      }],
      tags: ['课堂', '竞赛', '学校'],
      title: '[{"text":"#好好学习、天天向上#","type":"topic"},{"text":"学习打卡活动，吸引众多青少年参与，大家纷纷表示要在新一年里努力学习、不断进步。","type":"default"}]',
      richContent: '',
      authorId: 'author_6',
      createTime: 1751089800000,
      postImgList: [
        {
          picVideoUrl: 'https://e-file.huawei.com/mediares/Video_MCD/EBG/PUBLIC/zh/2025/05/43f01339-48e0-4e5d-a433-ccb8c423cdfe.png',
          surfaceUrl: '',
        },
        {
          picVideoUrl: 'https://www-file.huawei.com/admin/asset/v1/pro/view/ca03b4509af94cadbdde656fd9cd23ef.jpg',
          surfaceUrl: '',
        },
      ],
      navInfo: {
        setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","padding-top":"12"}}]}]}',
      },
    },
  ];
  static default: RequestListData = {
    navInfo: {
      setting: '{"type":"view","children":[{"type":"view","children":[{"type":"List","children":[{"type":"native","showType":"FeedDetailsCard","name":"帖子详情"}],"style":{"backgroundColor":"#FFFFFF","padding-bottom":"12","margin-top":"12"}}]}]}',
    },
    articles: [
      {
        id: 'article_13',
        type: NewsEnum.Post,
        likeCount: 0,
        commentCount: 0,
        comments: [],
        shareCount: 0,
        isLiked: false,
        isMarked: false,
        markCount: 0,
        tags: [],
        title: '',
        author: {
          authorId: '7',
          authorNickName: '7号选手',
          authorIcon: 'app.media.ic_user_default',
          authorDesc: '',
          authorIp: '北京',
          watchersCount: 12724,
          followersCount: 11712,
          likeNum: 12172,
        },
        createTime: new Date().getTime(),
        postImgList: [
          {
            picVideoUrl: '',
            surfaceUrl: '',
          },
        ],
      },
    ],
    extraInfo: {},
  };
}