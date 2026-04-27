import { common } from '@kit.AbilityKit';
import { BuilderNode, NodeController, PiPWindow, UIContext, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { PrompterConfig, PrompterConfigOptions } from '../model/PrompterConfigModel';
import { Countdown } from 'countdown';
import hilog from '@ohos.hilog';

@ObservedV2
export class PrompterController {
  private TAG = '[PrompterController]'
  private static _instance: PrompterController;

  public static get instance() {
    if (!PrompterController._instance) {
      PrompterController._instance = new PrompterController();
    }
    return PrompterController._instance;
  }

  // Scroller控制器
  scrollController: Scroller = new Scroller();
  // 提词文本
  @Trace text: string =
    '你是否也曾经历过这样的时刻？在电脑前奋战数小时后，试图站起身，却感觉腰部一阵僵硬酸痛，仿佛被无形的锁链捆住；脖子沉重，肩膀紧绷得像两块石头。我们总以为这是努力工作的勋章，但殊不知，这其实是身体在发出无声的抗议。\n' +
      '\n' +
      '我们一天中有超过三分之一的时间是与椅子为伴的。一张普通的椅子，看似是休息的港湾，实则是健康的“隐形杀手”。它让你弯腰驼背，让你的腰椎承受不该承受的压力，让你的颈椎在不知不觉中错位。日积月累，带来的不仅是当下的不适，更是未来可能爆发的椎间盘突出、颈椎病等终身困扰。你为事业拼搏，为生活奋斗，难道最终要输给一张椅子吗？\n' +
      '\n' +
      '是时候做出改变，为你的健康投资一份真正的保障了！今天，我要向你郑重推荐这款颠覆你坐感体验、守护你脊椎健康的【旗舰款智能人体工学椅】。它不仅仅是一把椅子，更像是一位时刻陪伴在你身边的“私人理疗师”，用科技与匠心，为你撑起一片健康的天空。\n' +
      '\n' +
      '一、 顶托级腰枕，给腰椎“稳稳的幸福”\n' +
      '\n' +
      '腰椎是人体承上启下的核心，也是最容易出问题的部位。我们这款工学椅的核心奥秘，就在于其四维动态自适应腰枕系统。\n' +
      '\n' +
      '与传统椅子一块死板的靠垫不同，我们的腰枕能够实现上下5档、前后3cm深度的精准调节。无论你是娇小的女生还是高大的男士，无论你习惯正坐还是后仰休息，它都能精准地找到并贴合你的腰椎生理曲度，实现“人动腰动，时刻贴合”的动态支撑。就像有一双温暖的手，始终托住你的后腰，有效分散腰椎压力，让你无论是专注工作还是后仰小憩，腰部都能得到最妥帖的承托，从根源上告别腰酸背痛。\n' +
      '\n' +
      '二、 灵动仿生椅背，宛如“第二层脊柱”\n' +
      '\n' +
      '我们的椅背并非一块铁板，而是采用了S形仿生脊椎曲线设计，完美复刻了人体脊柱的自然形态。高弹性的进口网布材质，不仅透气舒爽，更能带来“张弛有度”的支撑感。\n' +
      '\n' +
      '更值得一提的是其4档后仰锁定功能。90°标准坐姿用于高效工作；110°微后仰适合放松阅读；125°大角度后仰，搭配可伸缩的脚踏（选配），瞬间化身午休小床，让你在办公室也能享受媲美沙发的舒适小憩。后仰过程顺滑流畅，底盘稳固不侧翻，给你满满的安全感。\n' +
      '\n' +
      '三、 全方位可调节，打造你的“专属定制”\n' +
      '\n' +
      '世界上没有两片相同的树叶，也没有两个完全相同的身形。因此，极致的个性化调节是我们设计的核心理念。\n' +
      '\n' +
      '3D联动扶手：扶手不仅可以升降，还能内外调节宽度，甚至可以实现75°左右旋转和前后滑动。无论你是打字、阅读，还是使用手机、平板，手臂都能找到最自然的支撑点，彻底解放肩颈压力。\n' +
      '\n' +
      '智能颈托：头枕同样支持升降和角度旋转。当你后仰休息时，它能稳稳托住你的头部和颈部，避免颈部悬空带来的酸痛，有效预防颈椎劳损。\n' +
      '\n' +
      '气压棒与底盘：我们采用通过SGS国际认证的四级防爆气压棒，安全可靠。加上坚固的尼龙五星脚和静音耐磨滚轮，移动顺滑，承重超强，安全细节处处可见用心。\n' +
      '\n' +
      '四、 匠心品质，于细节处见真章\n' +
      '\n' +
      '我们深知，一把好椅子要用上好多年。因此，在选材和工艺上，我们绝不含糊。高弹性进口网布，通过了10万次耐久性测试，久坐不塌陷，同时具备优异的透气性，夏天不闷热，冬天不冰凉。所有调节功能都采用精钢材质内核与直观的操控拨片，手感扎实，调节顺滑，杜绝廉价感。\n' +
      '\n' +
      '算一笔健康账，它到底值不值？\n' +
      '\n' +
      '也许你会觉得，一把人体工学椅价格不菲。但让我们来算一笔账：一次盲人按摩需要上百元，一套理疗课程动辄数千，而因腰颈问题去医院所花费的金钱、时间和精力成本更是无法估量。这把椅子，是你未来5年、10年，甚至更长时间的健康伴侣。平均到每一天，成本不过几元钱，却能为你的身体建立起一道坚实的防线。这笔投资，关乎你的工作效率，更关乎你的生活品质，绝对是物超所值！\n' +
      '\n' +
      '不要再犹豫，也不要再忍受！你的身体，值得被更好地对待。每一次正确的坐姿，都是对未来自己的一份馈赠。\n' +
      '\n' +
      '现在下单，我们还将赠送您原装抗菌脚踏与高档皮质护颈枕！数量有限，赠完即止！同时享受7天无理由退换货，5年质保，只换不修的至尊服务，让您买得放心，坐得安心。\n' +
      '\n' +
      '点击下方链接，立即将这位“私人健康管家”带回家！告别腰酸背痛，从拥有一把真正的人体工学椅开始。为自己，为健康，投资一个更舒适、更高效的未来！';
  // 是否横屏
  @Trace isLandscapeMode: boolean = false;
  // 是否打开设置弹框
  @Trace isShowConfigSheet: boolean = false;
  // 是否翻转
  @Trace isPause: boolean = false;
  // 提词器当前设置选项
  @Trace configList: PrompterConfigOptions = new PrompterConfigOptions();
  // 提词器当前设置
  @Trace config: PrompterConfig =
    new PrompterConfig(this.configList.backgroundColorList[0], this.configList.fontColorList[0]);
  // 提词器默认滚动速度
  private scrollVp: number = 10
  private pipController?: PiPWindow.PiPController = undefined;

  start() {
    let speed = this.scrollVp * this.config.speechRate
    this.scrollController.scrollEdge(Edge.Bottom, { velocity: speed })
    this.isPause = false
    if (this.pipController) {
      this.setPiPControlEnabled(true)
    }
  }

  pause() {
    if (!this.isAtEnd()) {
      this.isPause = true
    }
  }

  restart() {
    this.scrollController.scrollTo({ yOffset: 0, xOffset: 0, animation: false })
    this.start()
  }

  setRotationMode(context: common.UIAbilityContext) {
    try {
      let windowClass = context.windowStage.getMainWindowSync()
      if (windowClass) {
        let mode =
          this.isLandscapeMode ? window.Orientation.USER_ROTATION_PORTRAIT : window.Orientation.USER_ROTATION_LANDSCAPE
        windowClass.setPreferredOrientation(mode); // 切换为横屏
        this.isLandscapeMode = !this.isLandscapeMode
        this.setFullScreen(context, this.isLandscapeMode)
      }
    } catch (err) {
      hilog.error(0x0000, this.TAG, `设置横屏失败: ${err.code}, ${err.message}`);
    }
  }

  setStatusFontColor(color?: string) {
    try {
      let w: window.Window = (getContext() as common.UIAbilityContext).windowStage.getMainWindowSync()
      let sysBarProps: window.SystemBarProperties = {
        statusBarContentColor: color ? color : this.isDeepBack() ? '#E5FFFFFF' : '#000000', // 状态栏文字/图标颜色（ffffff为白色）
      }
      w.setWindowSystemBarProperties(sysBarProps)
        .then(() => {
          hilog.info(0x0000, this.TAG, '状态栏样式设置成功');
        }).catch((err: BusinessError) => {
        hilog.error(0x0000, this.TAG, `失败代码: ${err.code}, 错误信息: ${err.message}`);
      });
    } catch (err) {
      hilog.error(0x0000, this.TAG, `设置状态栏样式失败: ${err.code}, ${err.message}`);
    }
  }

  fastForward() {
    // fastOrBackTime
    let dy = this.config.fastOrBackTime * this.scrollVp * this.config.speechRate
    this.scrollController.scrollBy(0, dy)
    if (!this.isPause) {
      this.start()
    }
  }

  fastBackward() {
    // fastOrBackTime
    let dy = this.config.fastOrBackTime * this.scrollVp * this.config.speechRate
    this.scrollController.scrollBy(0, -dy)
    if (!this.isPause) {
      this.start()
    }
  }

  isAtEnd() {
    return this.scrollController.isAtEnd()
  }

  isDeepBack() {
    if (this.configList.deepColorList.includes(this.config.backgroundColor)) {
      return true
    }
    return false
  }

  startPip(config: PiPWindow.PiPConfiguration) {
    if (!PiPWindow.isPiPEnabled()) {
      hilog.warn(0x0000, this.TAG, `picture in picture disabled for current OS`);
      return;
    }

    // 步骤1：创建画中画控制器，通过create接口创建画中画控制器实例
    PiPWindow.create(config).then((controller: PiPWindow.PiPController) => {
      this.pipController = controller;
      // 步骤1：初始化画中画控制器
      this.initPipController();
      // 步骤2：通过startPiP接口启动画中画
      this.pipController.startPiP().then(() => {
        console.info(`Succeeded in starting pip.`);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, this.TAG, `Failed to start pip. Cause:${err.code}, message:${err.message}`);
      });
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, this.TAG, `Failed to create pip controller. Cause:${err.code}, message:${err.message}`);
    });
  }

  private setFullScreen(context: common.UIAbilityContext, isFull: boolean) {
    let areas: ('status' | 'navigation')[] = isFull ? [] : ['status', 'navigation']
    try {
      window.getLastWindow(context).then((w) => {
        w.setWindowSystemBarEnable(areas)
      })
    } catch (e) {
    }
  }

  private initPipController() {
    if (!this.pipController) {
      return;
    }
    // 步骤1：通过setAutoStartEnabled接口设置是否需要在应用返回桌面时自动启动画中画，注册stateChange和controlPanelActionEvent回调
    this.pipController.setAutoStartEnabled(false); // 默认为false
    this.pipController.on('stateChange', (state: PiPWindow.PiPState, reason: string) => {
      this.onPipStateChange(state, reason);
    });
    this.pipController.on('controlPanelActionEvent', (event: PiPWindow.PiPActionEventType, status?: number) => {
      this.onPipActionEvent(event, status);
    });
    this.setPiPControlEnabled(false)
  }

  private onPipStateChange(state: PiPWindow.PiPState, reason: string) {
    let curState: string = '';
    switch (state) {
      case PiPWindow.PiPState.ABOUT_TO_START:
        curState = 'ABOUT_TO_START';
        break;
      case PiPWindow.PiPState.STARTED:
        curState = 'STARTED';
        break;
      case PiPWindow.PiPState.ABOUT_TO_STOP:
        curState = 'ABOUT_TO_STOP';
        break;
      case PiPWindow.PiPState.STOPPED:
        curState = 'STOPPED';
        break;
      case PiPWindow.PiPState.ABOUT_TO_RESTORE:
        curState = 'ABOUT_TO_RESTORE';
        break;
      case PiPWindow.PiPState.ERROR:
        curState = 'ERROR';
        break;
      default:
        break;
    }
    hilog.info(0x0000, this.TAG, `onStateChange: ${curState}, reason: ${reason}`);
  }

  private onPipActionEvent(event: PiPWindow.PiPActionEventType, status?: number) {
    switch (event) {
      case 'playbackStateChanged':
        // 开始或停止视频
        if (status === 0) {
          this.pause()
          // 停止视频
        } else if (status === 1) {
          // 播放视频
          this.start()
        }
        break;
      case 'fastForward':
        // 快进
        this.fastForward()
        break;
      case 'fastBackward':
        // 快退
        this.fastBackward()
        break;
      default:
        break;
    }
  }

  private setPiPControlEnabled(enabled: boolean) {
    let controlTypeList: PiPWindow.PiPControlType[] =
      [PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE, PiPWindow.PiPControlType.FAST_FORWARD,
        PiPWindow.PiPControlType.FAST_BACKWARD];
    controlTypeList.forEach((controlType) => {
      this.pipController?.setPiPControlEnabled(controlType, enabled);
    })
  }
}

// 开发者可以通过@Builder装饰器实现布局构建
@Builder
function buildPrompter(controller: PrompterController) {
  Column() {
    Scroll(controller.scrollController) {
      Text(controller.text)
        .width('100%')
        .fontSize(controller.config.fontSize)
        .fontColor(controller.config.fontColor)
        .rotate({ y: 2, angle: controller.config.isFlip ? 180 : 0, perspective: 200 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .align(Alignment.TopStart)
    .onWillScroll((xOffset: number, yOffset: number) => {
      if (controller.isPause) { // 条件判断
        return { xOffset: 0, yOffset: 0 } // 强制不滚动
      }
      return { xOffset: xOffset, yOffset: yOffset }
    })

    Countdown({
      time: controller.config.countdown,
      onFinish: () => {
        controller.start()
      }
    })
      .position({ top: 0, left: 0 })
  }
  .width('100%') // 宽度方向充满画中画窗口
  .height('100%') // 高度方向充满画中画窗口
  .backgroundColor(controller.config.backgroundColor)
  .padding({
    top: 45,
    left: 20,
    right: 20,
    bottom: 40
  })
}

// 开发者可通过继承NodeController实现自定义UI控制器
export class PrompterNodeController extends NodeController {
  private prompterNode: BuilderNode<[PrompterController]> | null = null;

  constructor() {
    super();
  }

  // 通过BuilderNode加载自定义布局
  makeNode(context: UIContext): FrameNode | null {
    this.prompterNode = new BuilderNode(context);
    this.prompterNode.build(wrapBuilder<[PrompterController]>(buildPrompter), PrompterController.instance);
    return this.prompterNode.getFrameNode();
  }
}