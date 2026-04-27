import { FrameController } from '../factory/FrameNodeFactory'
import { JSONObject, LayoutParams, LayoutSetting } from '../model/CommonModel'
import { BreakpointModel} from '../model/Model'
import { NodeBuilderRegister } from '../utils/NodeBuilderConfig'

@ObservedV2
export class FlexLayoutEngine {
  @Trace setting: LayoutSetting = new LayoutSetting()
  @Trace articles: JSONObject = ''
  @Trace breakpointModel: BreakpointModel = new BreakpointModel()
  @Trace extraInfo: Record<string, number | string | boolean | Record<string, string | boolean>[] | Function> = {}
  @Trace frameController: FrameController = new FrameController()

  /*
   * 初始化动态布局模版数据
   * @param setting 布局数据
   * @param articles 卡片数据
   * @param extraInfo 额外参数
   * */
  public createJsonLoader(setting: LayoutSetting, articles: JSONObject,
    extraInfo: Record<string, number | string | boolean | Record<string, string | boolean>[] | Function>) {
    this.setting = setting
    this.articles = articles
    this.extraInfo = extraInfo
  }

  /*
   * 调用rebuild接口通知NodeContainer组件重新回调makeNode方法，更新子节点。
   * */
  public reBuildFrameNode() {
    this.frameController.rebuild();
  }

  /*
   * 调用rebuild接口通知NodeContainer组件重新回调makeNode方法，更新子节点。
   * */
  public setBreakpointModel(breakpointModel:JSONObject) {
    this.breakpointModel = breakpointModel
  }
}


export class CardRegister {
  private static nodeBuilderRegister: NodeBuilderRegister = NodeBuilderRegister.instance
  private static _instance: CardRegister

  public static get instance() {
    if (!CardRegister._instance) {
      CardRegister._instance = new CardRegister()
    }
    return CardRegister._instance
  }

  /*
   * 初始化注册卡片
   * */
  public registerCard(key: string, value: WrappedBuilder<[LayoutParams]>) {
    CardRegister.nodeBuilderRegister.registerBuilderCard(key, value)
  }
}


