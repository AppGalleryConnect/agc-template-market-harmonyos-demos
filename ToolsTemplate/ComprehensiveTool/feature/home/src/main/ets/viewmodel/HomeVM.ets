import { PersistenceV2, AppStorageV2 } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { SelectedToolType, ToolTypeList, ToolTypeModule, ToolTypeModules, ShortCutParam } from '../model/Index';
import { TOOL_TYPE_MODULES } from '../constant/Index';
import { Category, ManageStatus } from '../constant/Enum';

@ObservedV2
export class HomeVM {
  @Trace homeToolTypes: ToolTypeList =
    PersistenceV2.connect(ToolTypeList, 'Home', () => new ToolTypeList())!;
  @Trace calculatorToolTypes: ToolTypeList =
    PersistenceV2.connect(ToolTypeList, 'Calculate', () => new ToolTypeList())!;
  @Trace lifeToolListTypes: ToolTypeList =
    PersistenceV2.connect(ToolTypeList, 'Life', () => new ToolTypeList())!;
  @Trace selectedToolType: SelectedToolType =
    PersistenceV2.connect(SelectedToolType, () => new SelectedToolType())!;
  @Trace homeToolList: ToolTypeModules = [];
  @Trace calculatorToolList: ToolTypeModules = [];
  @Trace lifeToolList: ToolTypeModules = [];
  @Trace hasPermission: boolean = false;
  @Trace pathStack: NavPathStack = new NavPathStack();
  private static _instance: HomeVM;

  public static get instance() {
    if (!HomeVM._instance) {
      HomeVM._instance = new HomeVM();
    }
    return HomeVM._instance;
  }

  changeIndex(toolIndex: number, insertIndex: number) {
    let temp: ToolTypeModule = this.homeToolList[toolIndex];
    this.homeToolList[toolIndex] = this.homeToolList[insertIndex];
    this.homeToolList[insertIndex] = temp;
  }

  init() {
    let list: ToolTypeModule[] = JSON.parse(this.homeToolTypes.list);
    if (!list.length) {
      this.homeToolTypes.list = JSON.stringify(TOOL_TYPE_MODULES.slice(1));
    }
    this.homeToolList = JSON.parse(this.homeToolTypes.list);
    this.calculatorToolList = JSON.parse(this.calculatorToolTypes.list);
    this.lifeToolList = JSON.parse(this.lifeToolListTypes.list);
    let shortCutKey: ShortCutParam = AppStorageV2.connect(ShortCutParam, () => new ShortCutParam())!;
    // 选择通过桌面快捷方式进入时，屏蔽默认打开功能
    if (this.selectedToolType.url && !shortCutKey.key) {
      UtilLog.info(`selectedToolType url is: ${this.selectedToolType.url}`);
      this.pathStack.pushPathByName(this.selectedToolType.url, null);
    }
  }

  handleToolLayout(uiContext: UIContext, state: ManageStatus, tool: ToolTypeModule, tools: ToolTypeModule[],
    index: number) {
    if (state === ManageStatus.NONE) {
      this.pathStack.pushPathByName(tool.url, null);
    } else if (state === ManageStatus.ADD) {
      // 添加到首页
      this.homeToolList.push(tools[index]);
      if (tool.category === Category.CALCULATE) {
        this.calculatorToolList =
          this.calculatorToolList.filter(type => type.title !== tool.title);
      } else if (tool.category === Category.LIFE) {
        this.lifeToolList =
          this.lifeToolList.filter(type => type.title !== tool.title);
      }
    } else {
      // 从首页删除
      if (this.homeToolList.length > 1) {
        this.homeToolList = this.homeToolList.filter(type => type.title !== tool.title);
      } else {
        uiContext.getPromptAction().showToast({ message: '至少需要保留一个工具哦~', duration: 1000 });
        return;
      }
      if (tool.category === Category.CALCULATE) {
        this.calculatorToolList.push(tool);
      } else if (tool.category === Category.LIFE) {
        this.lifeToolList.push(tool);
      }
    }
  }
}