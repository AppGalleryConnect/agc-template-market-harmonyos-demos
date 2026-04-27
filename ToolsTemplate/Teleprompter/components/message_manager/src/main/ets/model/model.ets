import { util } from '@kit.ArkTS';

export interface TabButtonData {
  activeBgColor?: string | Resource;
  defaultBgColor?: string | Resource;
  activeFontColor?: string | Resource;
  defaultFontColor?: string | Resource;
}

@ObservedV2
export class MessageItem {
  @Trace title: string = '';
  @Trace time: string = '';
  @Trace hasRead: boolean = false;
  content: string = '';
  id: string;
  constructor(title: string, time: string, content: string) {
    this.id = util.generateRandomUUID(true);
    this.title = title;
    this.time = time;
    this.content = content;
  }

  read() {
    this.hasRead = true;
  }
}

export interface CardStyle {
  bgColor?: string | Resource;
  borderRadius?: number | Resource;
  titleFontSize?: number | Resource;
  titleColor?: string | Resource;
  timeFontSize?: number | Resource;
  timeColor?: string | Resource;
  descriptionFontSize?: number | Resource;
  descriptionColor?: string | Resource;
  contentFontSize?: number | Resource;
  contentColor?: string | Resource;
  maxLines?:number;
}



export class CardData {
  title: string = '';
  time: string = '';
  description: string = '';
  mark: string[] = [];
  content: string = '';
  salary: string = '';
  constructor(title:string, content: string, time: string, description?:string, mark?:string[], salary?:string) {
    this.title = title;
    this.content = content;
    this.time = time;
    this.description = description || '';
    this.mark = mark || [];
    this.salary = salary || '';
  }
}

const mockContent = `恭喜您！您的简历已经通过了我们的人力资源部门审查我们很荣幸邀请您进行面试。我们想在面对面的交流中，详细了解您的专业知识和个人能力。期待和您面谈，祝您一切顺利！`;

export const messDataList: MessageItem[] = [
  new MessageItem('这是一段标题', '17:56', '这是一段正文内容'),
  new MessageItem('某某技术有限公司面试邀请', '08:56', mockContent),
  new MessageItem('面试邀请', '14:54', mockContent),
  new MessageItem('发布了新的职位', '昨天', mockContent),
]

const mockRequirementsData = `1.统招本科以上学所，3年及以上互联网公司/广告公司/媒体等行业品牌广告直客销售经验，
2.熟悉销售工作流程，能够融立有效的管理全流程；
3.出色的沟通表达能力&跨邮门协作能力，较强的提案汇报/presentation能力；
4.具备一定的数据分析能力；
5. 具备较强的自驱力/创新意识，乐于探索和思考。`

export const cardDataList: CardData[] = [
  new CardData('UX交互设计师',mockRequirementsData, '2015-01-24', 'XXX  ·  未融资', ['南京 江南', '3年以上', ' 本科'], '15-20k·13薪'),
  new CardData('产品经理',mockRequirementsData, '2015-01-24', 'XXX  ·  未融资', ['南京 江南', '3年以上', ' 本科'],'15-20k·13薪'),
  new CardData('Java开发工程师',mockRequirementsData, '2015-01-24', 'XXX  ·  未融资', ['南京 江南', '3年以上', ' 本科'],'15-20k·13薪'),
  new CardData('Web开发工程师',mockRequirementsData, '2015-01-24', 'XXX  ·  未融资', ['南京 江南', '3年以上', ' 本科'],'15-20k·13薪'),
]