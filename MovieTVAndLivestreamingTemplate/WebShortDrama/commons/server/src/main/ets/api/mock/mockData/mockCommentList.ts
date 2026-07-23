import { CommentItem, Replying, ReplyLike } from "./bean";

const commentLists: CommentItem[] = [
  {
    id: 1,
    drama: {
      id: 'drama_5',
      coverUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/pic1.png',
      promotionalUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/3.m3u8',
      name: '锦鲤萌宝闹大观园',
      description: '一口气看完大结局，一部让你熬夜看完的短剧，怕你情绪把控不住 #轮到你看我爱别人短剧',
      totalCount: 80,
      curIndex: 3,
      latestUpdate: 80,
      category: ['权谋', '古装'],
      popular: '230万',
      actorInfo: [{
        id: '1',
        name: '徐梦圆',
        avatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/woman1.png'
      }],
      episodeList: [],
      isFavorite: false,
      favoriteCount: 122,
      isLike: false,
      likeCount: 98,
      isSelect: false
    },
    coverUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/pic1.png',
    avatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/man1.png',
    name: '瓜瓜',
    commentContent: '男主人设绝对人夫赛道天花板了，看的过瘾啊～',
    timeAgo: 120,
    isLike: false,
    likeCount: 99,
    likeList: [
      {
        likeAvatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/ic_avatar4.png',
        likeName: '米雪秉承',
        likeTime: 1
      },
      {
        likeAvatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/ic_avatar6.png',
        likeName: 'QWERT',
        likeTime: 5
      }
    ],
    replyList: [
      {
        replyAvatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/ic_avatar2.png',
        replyName: 'QWERT',
        replyContent: '看啦～好绝',
        replyTimeAgo: 0,
        replyIsLike: false,
        replyLikeCount: 6,
        replyLikeList: [],
        replyPeople: '瓜瓜',
        replyComment: '男主人设绝对人夫赛道天花板了，看的过瘾啊～'
      },
      {
        replyAvatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/ic_avatar3.png',
        replyName: '小磊哥',
        replyContent: '同感同感！',
        replyTimeAgo: 5,
        replyIsLike: false,
        replyLikeCount: 2,
        replyLikeList: [],
        replyPeople: '米雪秉承',
        replyComment: '这部短剧真的绝了呀！猛地一下就抓住了你的心！真的太震撼了！'
      },
      {
        replyAvatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/ic_avatar4.png',
        replyName: '米雪秉承',
        replyContent: '这部短剧真的绝了呀！猛地一下就抓住了你的心！真的太震撼了！',
        replyTimeAgo: 10,
        replyIsLike: false,
        replyLikeCount: 13,
        replyLikeList: [],
        replyPeople: '瓜瓜',
        replyComment: '男主人设绝对人夫赛道天花板了，看的过瘾啊～'
      },
      {
        replyAvatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/ic_avatar5.png',
        replyName: '赵公子生命粉',
        replyContent: '昨晚熬到临晨3点看完～',
        replyTimeAgo: 60,
        replyIsLike: false,
        replyLikeCount: 25,
        replyLikeList: [],
        replyPeople: '瓜瓜',
        replyComment: '男主人设绝对人夫赛道天花板了，看的过瘾啊～'
      },
      {
        replyAvatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/ic_avatar6.png',
        replyName: '天降奇缘',
        replyContent: '快去给我看顺恨！',
        replyTimeAgo: 120,
        replyIsLike: false,
        replyLikeCount: 6,
        replyLikeList: [],
        replyPeople: '瓜瓜',
        replyComment: '男主人设绝对人夫赛道天花板了，看的过瘾啊～'
      },
      {
        replyAvatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/ic_avatar7.png',
        replyName: 'DUDUlook',
        replyContent: '男主就是演《绝对臣服》的西门礼臣啊！演的太好了，真的是剧抛脸，一开始都没认出来～哈哈哈，' +
          '希望赵公子以后能多接点好本子啊～',
        replyTimeAgo: 300,
        replyIsLike: false,
        replyLikeCount: 6,
        replyLikeList: [],
        replyPeople: '瓜瓜',
        replyComment: '男主人设绝对人夫赛道天花板了，看的过瘾啊～'
      },
      {
        replyAvatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/ic_avatar7.png',
        replyName: 'DUDUlook',
        replyContent: '男主就是演《绝对臣服》的西门礼臣啊！演的太好了，真的是剧抛脸',
        replyTimeAgo: 600,
        replyIsLike: false,
        replyLikeCount: 6,
        replyLikeList: [],
        replyPeople: '夕阳西下',
        replyComment: '男主就是演《绝对臣服》的西门礼臣啊！演的太好了，真的是剧抛脸'
      },
      {
        replyAvatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/ic_avatar7.png',
        replyName: 'DUDUlook',
        replyContent: '男主就是演《绝对臣服》的西门礼臣啊！演的太好了，真的是剧抛脸',
        replyTimeAgo: 600,
        replyIsLike: false,
        replyLikeCount: 6,
        replyLikeList: [],
        replyPeople: '夕阳西下',
        replyComment: '男主就是演《绝对臣服》的西门礼臣啊！演的太好了，真的是剧抛脸'
      },
      {
        replyAvatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/ic_avatar7.png',
        replyName: '夕阳西下',
        replyContent: '男主就是演《绝对臣服》的西门礼臣啊！演的太好了，真的是剧抛脸',
        replyTimeAgo: 600,
        replyIsLike: false,
        replyLikeCount: 6,
        replyLikeList: [],
        replyPeople: '瓜瓜',
        replyComment: '男主人设绝对人夫赛道天花板了，看的过瘾啊～'
      }
    ]
  },
  {
    id: 2,
    drama: {
      id: 'drama_4',
      coverUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/pic2.png',
      promotionalUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/2.m3u8',
      name: '锦鲤萌宝闹大观园',
      description: '一口气看完大结局，一部让你熬夜看完的短剧，怕你情绪把控不住 #轮到你看我爱别人短剧',
      totalCount: 80,
      curIndex: 3,
      latestUpdate: 80,
      category: ['权谋', '古装'],
      popular: '260万',
      actorInfo: [{
        id: '1',
        name: '徐梦圆',
        avatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/woman1.png'
      }],
      episodeList: [],
      isFavorite: false,
      favoriteCount: 210,
      isLike: false,
      likeCount: 155,
      isSelect: false
    },
    coverUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/pic2.png',
    avatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/ic_avatar.png',
    name: 'DUDUlook',
    commentContent: '男主人设绝对人夫赛道天花板了，看的过瘾啊～',
    timeAgo: 180,
    isLike: false,
    likeCount: 99,
    likeList: [],
    replyList: []
  },
  {
    id: 3,
    drama: {
      id: 'drama_3',
      coverUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/pic3.png',
      promotionalUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/drama_video/3.m3u8',
      name: '锦鲤萌宝闹大观园',
      description: '一口气看完大结局，一部让你熬夜看完的短剧，怕你情绪把控不住 #轮到你看我爱别人短剧',
      totalCount: 80,
      curIndex: 3,
      latestUpdate: 80,
      category: ['权谋', '古装'],
      popular: '230万',
      actorInfo: [{
        id: '1',
        name: '徐梦圆',
        avatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/woman1.png'
      }],
      episodeList: [],
      isFavorite: false,
      favoriteCount: 122,
      isLike: false,
      likeCount: 98,
      isSelect: false
    },
    coverUrl: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/pic3.png',
    avatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/ic_avatar5.png',
    name: '西楚霸王',
    commentContent: '完全不够看啊',
    timeAgo: 360,
    isLike: false,
    likeCount: 99,
    likeList: [],
    replyList: [
      {
        replyAvatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/ic_avatar5.png',
        replyName: '赵公子生命粉',
        replyContent: '昨晚熬到临晨3点看完～',
        replyTimeAgo: 1,
        replyIsLike: false,
        replyLikeCount: 25,
        replyLikeList: [],
        replyPeople: '西楚霸王',
        replyComment: '完全不够看啊'
      },
      {
        replyAvatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/ic_avatar5.png',
        replyName: '公子哥',
        replyContent: '快更新快更新！！！',
        replyTimeAgo: 5,
        replyIsLike: false,
        replyLikeCount: 25,
        replyLikeList: [],
        replyPeople: '西楚霸王',
        replyComment: '完全不够看啊'
      },
      {
        replyAvatar: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/app-d45y3/avatar/ic_avatar5.png',
        replyName: '瓜瓜',
        replyContent: '剧情真的很棒，很吸引人',
        replyTimeAgo: 60,
        replyIsLike: false,
        replyLikeCount: 25,
        replyLikeList: [],
        replyPeople: '西楚霸王',
        replyComment: '完全不够看啊'
      }
    ]
  }
]

class CommentListFactory {
  commentListData: CommentItem[] = []

  constructor() {
    this.commentListData = commentLists
  }

  getCommentList(): Array<CommentItem> {
    return this.commentListData
  }

  addComment(commentItem: CommentItem): void {
    this.commentListData.unshift(commentItem)
  }

  addReply(replying: Replying): void {
    let index: number = -1
    this.commentListData.forEach((item) => {
      if(item.id === replying.id) {
        index = this.commentListData.indexOf(item)
      }
    })
    this.commentListData[index].replyList.unshift(replying.reply)
  }

  onCommentLike(id: number): void {
    let index: number = -1
    this.commentListData.forEach((item) => {
      if(item.id === id) {
        index = this.commentListData.indexOf(item)
      }
    })
    if(this.commentListData[index].isLike) {
      this.commentListData[index].likeCount--
      this.commentListData[index].isLike = false
    }else {
      this.commentListData[index].likeCount++
      this.commentListData[index].isLike = true
    }
  }

  onReplyLike(replyLike: ReplyLike): void {
    let index: number = -1
    this.commentListData.forEach((item) => {
      if(item.id === replyLike.id) {
        index = this.commentListData.indexOf(item)
      }
    })
    if(this.commentListData[index].replyList[replyLike.index].replyIsLike) {
      this.commentListData[index].replyList[replyLike.index].replyLikeCount--
    }else {
      this.commentListData[index].replyList[replyLike.index].replyLikeCount++
    }
    this.commentListData[index].replyList[replyLike.index].replyIsLike =
      !this.commentListData[index].replyList[replyLike.index].replyIsLike
  }
}

let commentListFactory: CommentListFactory = new CommentListFactory()

export const getCommentList = (): Array<CommentItem> => {
  return commentListFactory.getCommentList();
}

export const addComment = (commentItem: CommentItem): void => {
  commentListFactory.addComment(commentItem)
}

export const addReply = (replying: Replying): void => {
  commentListFactory.addReply(replying)
}

export const onCommentLike = (id: number): void => {
  commentListFactory.onCommentLike(id)
}

export const onReplyLike = (replyLike: ReplyLike): void => {
  commentListFactory.onReplyLike(replyLike)
}