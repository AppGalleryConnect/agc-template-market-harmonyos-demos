import { PreferenceModel, RouterMap, RouterModule } from 'commonlib';
import { MainPageVM } from '../viewModels/MainPageVM';
import { window } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';

class NewsData{
  title:string=''
  content:string=''
  image?: Resource
  comment:string=''
  good:boolean=false
  collect:boolean=false
  share:number=0
}

export interface KeywordItem {
  desc: string;
  count: number;
}

class CommentList{
  keyWordList: KeywordItem[] = [
    {
      desc: '服务周到',
      count: 4.6,
    },
    {
      desc: '环境卫生',
      count: 4.3,
    },
    {
      desc: '设施设备',
      count: 4.4,
    },
    {
      desc: '综合体验',
      count: 4.5,
    },
  ];
}

@Builder
export function myCommentBuilder() {
  MyComment();
}

class CommentInfo {
  key: string = util.generateRandomUUID(true);
  name: string;
  comment: string;

  constructor(name: string, comment: string) {
    this.name = name;
    this.comment = comment;
  }
}

// @Entry
@ComponentV2
export struct MyComment {
  vm: MainPageVM = MainPageVM.instance;
  @Local isShowSheet: boolean = false;
  @Local customHeight: number = 300;
  @Local heartFlag: boolean = false;
  @Local collectFlag: boolean = false;
  @Local comment: string = '';
  @Local firstComment: string = ''
  @Local isStateEffect: boolean = false
  @Local num: number = 0.4
  @Local newsData: NewsData = new NewsData();
  @Local counts: number = 0;
  @Local likeFlag: boolean = false;
  private commenList: Array<object> = [
    new CommentInfo('我的昵称', 'hello world'),
    new CommentInfo('我的昵称', '真是一个好消息'),
  ]
  textAreaController: TextAreaController = new TextAreaController();

  aboutToAppear(): void {

  }

  aboutToDisappear(): void {
    window.getLastWindow(getContext(this)).then((windowClass)=>{
      windowClass.setPreferredOrientation(window.Orientation.PORTRAIT)
    })
  }

  @Builder
  AllComment() {
    Column() {
      Row() {
        Image($r('app.media.ic_person'))
          .width(20)
          .height(20)
          .borderRadius('24vp')
        Text(this.vm.userInfo.name || '网友7890')
          .fontSize(`${12 + this.vm.changeFontSize}`)
          .margin({left:8})
          .textAlign(TextAlign.Start)
          .height(20)
          .fontColor('#99000000')
      }
      .width('100%')
      Row() {
        Text(`${this.vm.comment||'真是一个好消息～哈哈哈～'}`)
          .fontSize(`${14 + this.vm.changeFontSize}`)
          .borderRadius(12)
          .fontFamily('鸿蒙黑体')
      }
      .margin({top: 10, left:56})
      .width('100%')
      Row() {
        Flex({justifyContent:FlexAlign.SpaceBetween}) {
          Row(){
            Text('5分钟前')
              .margin({right:16})
              .fontColor(Color.Gray)
              .fontSize(`${10 + this.vm.changeFontSize}`)
            Text('南京')
              .fontColor(Color.Gray)
              .fontSize(`${10 + this.vm.changeFontSize}`)
          }
          .width('50%')
        }
      }
      .margin({top: 10,left:30})
    }
    .margin({ left:16,top:16,bottom:20,right:10 })
    .onClick(() => {
      RouterModule.push({ url: RouterMap.COMMENT_DETAIL, param: null });
    })
  }

  @Builder commentItem() {
    Column() {
      Row() {
        Text('住建部称住宅层高标准将提至不低于3米，层高低的房子不值钱了？')
          .fontSize(`${16 + this.vm.changeFontSize}`)
          .fontFamily('鸿蒙黑体')
          .fontWeight('bold')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({top: 20, left:14, right:14})
      }
      .width('100%')
      .height(40)
      .onClick(() => {
        RouterModule.push({ url: RouterMap.NEWS_DETAIL, param: null });
      })
      Scroll() {
        this.AllComment()
      }
      .margin({top:20})
      Divider()
        .margin({ top: 12 })
        .strokeWidth(8)
        .color('#F1F3F5')
    }
  }

  build() {
    NavDestination(){
      Column() {
        List() {
          ForEach(this.commenList, (item: CommentInfo) => {
            ListItem() {
              this.commentItem()
            }
          })
        }.margin({ top: 8,bottom:16 })
      }
      .width('100%')
    }
    .title('我的评论')}
}
