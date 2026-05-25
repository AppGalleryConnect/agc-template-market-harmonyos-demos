export class BookInfo {
  id: string = '';
  name: string = '';
  coverUrl?: PixelMap | ResourceStr | DrawableDescriptor;
  rankUrl?: PixelMap | ResourceStr | DrawableDescriptor;
  rate: string = '';
  description: string = '';
  author: string = '';
  localPath: string = '';
  epubUrl: string = '';
  category: string = '';
  isFree?: string; // 付费类型 0：免费、1：会员、2：付费
  count?: string;
  popular?: string;
  gender?: string; // 区分男生女生频道 '1':女生 '2':男生
  groupName: string = ''; //分组名字
  groupType: string = ''; //是否在分组中 0不在 1在
  status?: string; // 书籍状态 '0':连载中、'1':已完结
  usageMemory?: string = '0'
  isDownload?: boolean = false; // 是否已下载
  downloadProgress?: number = 0; // 下载进度
  isSelect?: boolean = false; // 是否被选中
  readProgress?: string = '未读过' // 阅读进度
  isBuy?: boolean;
}

export interface rankListInfo {
  id: string;
  rankName: string;
  detailBooks: Array<BookInfo>;
}


@ObservedV2
export class GroupBook {
  // 是否选中
  @Trace isSelect?: boolean
  @Trace groupName?: string;
  @Trace iconString?: string;
  @Trace groupBooks?: BookInfo[] = [];
  @Trace bookName?: string;
  @Trace singleBook?: BookInfo;
  @Trace usageMemory?: string = '0'
  @Trace isDownload?: boolean = false; // 是否已下载
  @Trace downloading?: boolean = false; // 是否正在下载
  @Trace timestamp: number;
  @Trace isPin?: boolean = false // 是否置顶
  constructor() {
    this.timestamp = Date.now()
  }
}

// 弹窗参数
export class DialogParams {
  title: string = '';
  content: string = '';
  input: boolean = false;
  leftButtonText: string = '';
  rightButtonText: string = '';
  leftEvent: () => void = () => {
  };
  rightEvent: (text?: string) => void = (text?: string) => {
  };

  constructor(title: string, content: string, input: boolean, leftButtonText: string, rightButtonText: string,
    leftEvent: () => void,
    rightEvent: (text?: string) => void) {
    this.title = title;
    this.content = content;
    this.input = input;
    this.leftButtonText = leftButtonText;
    this.rightButtonText = rightButtonText;
    this.leftEvent = leftEvent;
    this.rightEvent = rightEvent;
  }
}
