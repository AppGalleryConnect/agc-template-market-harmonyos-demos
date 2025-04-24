export interface Category {
  imageUrl: string,
  text: string,
  categoryId: string
}

export interface VideoCard {
  id: string,
  title: string,
  describe: string,
  tags: Array<string>,
  videoType: number, // 0 视频， 1 音频
  plateType?: string,
  updateCount: number,
  totalCount: number,
  imageUrl: string,
  isVip: boolean
}


export interface VideoCardDetail {
  id: string,
  cardId: string,
  title: string,
  imageUrl: string,
  videoNumber: number,
  iconUrl: string,
  videoUrl: string,
  isVip: boolean
}


/**
 * 观看历史
 */
export interface History {
  lastWatch: object,
  videoCard: VideoCard,
  videoCardList: Array<VideoCardDetail>
}

