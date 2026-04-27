import { RecipesTable } from '../types/Types';

export class CommonConstants {
  static readonly STATUS_BAR_HEIGHT: number = 40;
  // Space
  static readonly SPACE_XXS: number = 2;
  static readonly SPACE_XS: number = 4;
  static readonly SPACE_S: number = 8;
  static readonly SPACE_M: number = 12;
  static readonly SPACE_L: number = 16;
  static readonly SPACE_XL: number = 20;
  static readonly SPACE_XXL: number = 24;
  // Percent
  static readonly FULL_PERCENT: string = '100%';
  static readonly HALF_PERCENT: string = '50%';
  static readonly QUARTER_PERCENT: string = '25%';
  // Padding
  static readonly PADDING_XXS: number = 2;
  static readonly PADDING_XS: number = 4;
  static readonly PADDING_S: number = 8;
  static readonly PADDING_M: number = 12;
  static readonly PADDING_L: number = 16;
  static readonly PADDING_XL: number = 20;
  static readonly PADDING_XXL: number = 24;
  static readonly PADDING_PAGE: number = 16;
  // 域名
  public static readonly BASE_URL = '';
  // 全屏宽度
  public static readonly FULL_WIDTH = '100%';
  // 全屏高度
  public static readonly FULL_HEIGHT = '100%';
  // 首选项key
  public static readonly LIGHT_DARK_KEY = 'light_dark';
  public static readonly PRIVACY_POLICY_KEY = 'privacy policy';
  // 跳转搜索页前置页面
  public static readonly CLASSIFICATION_PAGE = 'ClassificationPage';
  // rdb开关，默认开启rdb(false 走接口)
  public static readonly RDB_FLAG = true;
  //Recipes表配置.
  static readonly RECIPES_TABLE: RecipesTable = {
    tableName: 'recipesTable',
    sqlCreate: 'CREATE TABLE IF NOT EXISTS recipesTable(id INTEGER, title TEXT, description TEXT, category TEXT, cookingTime INTEGER, difficulty TEXT, ' +
      'authorId INTEGER, author TEXT, authorAvatar TEXT, thumbnail TEXT, views INTEGER, likes INTEGER, isCollected INTEGER, video TEXT, heatness INTEGER, isVip INTEGER)',
    columns: ['id', 'title', 'description', 'category', 'cookingTime', 'difficulty', 'authorId', 'author',
      'authorAvatar', 'thumbnail', 'views', 'likes', 'isCollected', 'video', 'heatness', 'isVip'],
  };
  // 搜索历史首选项key
  public static readonly SEARCH_KEYS = 'searchKeys';
  public static readonly PRIVACY_CONTENT =
    '   欢迎您使用“xxxx”。“xxxx”采用收费与免费结合的方式。您须注册华为账号后，才能继续进行购买服务。通过购买程序支付费用后，您就可以使用会员所提供的收费服务。在开始购买程序之前，请您首先同意并接受以下服务条款。\n' +
      '   本协议是您与华为软件技术有限公司（以下统称“华为”）之间关于“xxxx"提供的各种付费服务签订的服务协议，描述了华为与xxxx付费服务用户之间关于软件许可以及服务使用及相关方面的权利义务。同意本协议，您可享受会员权益。 \n' +
      '   您同意本“xxxx"付费服务协议条款即表示同意遵守《xxxx用户协议》《关于xxxx与隐私的声明》（以下称“基础协议"），本协议未涉及事项以《xxxx用户协议》为准，若您拒绝接受本协议，不影响已同意的基础协议。 \n' +
      '   华为在此特别提醒，请事先仔细阅读本服务协议中各项条款，包括但不限于免除或者限制华为责任的免责条款以及对用户的权利限制条款。请您仔细审阅并决定接受或不接受本服务协议。';
  // todo 拉起应用内评论的最小时间间隔,根据业务需求调整 单位ms
  public static readonly COMMENT_DURATION = 3600000;
  // todo 应用前台需连续驻留时间，根据业务需求调整 单位ms
  public static readonly STAY_TIME = 1800000;
}

