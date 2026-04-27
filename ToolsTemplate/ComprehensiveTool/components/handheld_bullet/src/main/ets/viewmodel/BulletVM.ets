import { LevelMode, PersistenceV2 } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { Constant } from '../constant/Constant';
import { Bullet, BulletHistoryList, ColorOption, GlowStick, Hint, SliderOption } from '../model/Index';
import { PromptActionUtil } from '../util/PromptActionUtil';

@ObservedV2
export class BulletVM {
  private static _instance: BulletVM;
  @Trace homeTabIndex: number = 0;
  @Trace colorIndex: number = 0;
  @Trace offsetX: number = 0;
  @Trace isShowFontSizePicker: boolean = false;
  @Trace isShowFontColorPicker: boolean = false;
  @Trace isShowBgColorPicker: boolean = false;
  @Trace isShowFlowSpeedPicker: boolean = false;
  @Trace isShowGlowStickerPicker: boolean = false;
  @Trace isAnimating: boolean = false;
  @Trace duration: number = 10;
  @Trace contentWidth: number = 0;
  @Trace hint: Hint = {
    message: '是否删除此条历史弹幕？',
    confirmCallBack: () => {
      this.getUniqueBullet();
    },
  };
  @Trace cloneFontSizeOption: SliderOption = new SliderOption();
  @Trace cloneFlowSpeedOption: SliderOption = new SliderOption();
  @Trace cloneBgColorOption: ColorOption = new ColorOption();
  @Trace cloneFontColorOption: ColorOption = new ColorOption();
  @Trace cloneGlowStickSpeedOption: SliderOption = new SliderOption();
  @Trace linearColors: Array<[ResourceColor, number]> = [['#FF1700', 0], ['#8A2BE2', 1]];
  @Trace bullet: Bullet = new Bullet();
  @Trace glowStick: GlowStick = new GlowStick();
  @Trace stack: NavPathStack = new NavPathStack();
  @Trace bulletHistoryList: BulletHistoryList =
    PersistenceV2.connect(BulletHistoryList, 'BulletHistoryList', () => new BulletHistoryList())!;
  @Trace time: number = 0;
  @Trace backTime: number = 0;
  @Trace glowInterval: number = 0;
  @Trace isLock: boolean = false;
  @Trace isShowBack: boolean = false;
  @Trace overflowLen: number = 0;
  @Trace isOverFlow: boolean = false;

  public static get instance() {
    if (!BulletVM._instance) {
      BulletVM._instance = new BulletVM();
    }
    return BulletVM._instance;
  }

  showHintDialog(uiContext: UIContext, node: ComponentContent<Object>) {
    PromptActionUtil.setContext(uiContext);
    PromptActionUtil.setContentNode(node);
    PromptActionUtil.setOptions({
      levelMode: LevelMode.EMBEDDED,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        UtilLog.info(0xFF00, 'BULLET', JSON.stringify(dismissDialogAction.reason));
      },
    });
    PromptActionUtil.openDialog();
  }

  updateHintDialog(uiContext: UIContext, node: ComponentContent<Object>, message: string, callback: () => void) {
    this.hint = {
      message: message,
      confirmCallBack: callback,
    };
    node.update(this.hint);
    this.showHintDialog(uiContext, node);
  }

  displayBullet(uiContext: UIContext) {
    if (!this.bullet.content) {
      uiContext.getPromptAction().showToast({
        message: '请填写弹幕内容',
      });
      return;
    } else {
      let date = new Date();
      let createTime = `${date.getFullYear()}-${(date.getMonth() +1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours()
        .toString()
        .padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}:${date.getSeconds()
        .toString()
        .padStart(2, '0')}`;
      this.bulletHistoryList.list.unshift({
        text: this.bullet.content,
        createTime: createTime,
      });
    }

    this.stack.pushPathByName('BulletDisplay', null);
  }

  startGlow() {
    this.glowInterval = setInterval(() => {
      // 每次间隔清空颜色
      this.linearColors = [];
      let len = Constant.stickLinearColors.length;
      if (this.colorIndex < len - 1) {
        this.colorIndex++;
      } else {
        this.colorIndex = 0;
      }
      let colors = Constant.stickLinearColors[this.colorIndex];
      this.linearColors = [[colors[0], 0], [colors[1], 1]];
    }, 3000 / this.bullet.speed);
  }

  getUniqueBullet() {
    this.bulletHistoryList.list = this.bulletHistoryList.list.filter((item, index) =>
    this.bulletHistoryList.list.findIndex(i => i.text === item.text) === index);
  }

  clearBullet() {
    this.bulletHistoryList.list = [];
  }

  deleteBulletByIndex(index: number) {
    this.bulletHistoryList.list.splice(index, 1);
  }

  cloneFontSizeOptions() {
    let cloneOptions: SliderOption = new SliderOption();
    cloneOptions.min = 10;
    cloneOptions.max = 500;
    cloneOptions.step = 10;
    cloneOptions.current = this.bullet.fontSize;
    cloneOptions.confirmCallBack = () => {
      this.bullet.fontSize = this.cloneFontSizeOption.current;
      this.isShowFontSizePicker = false;
    };
    cloneOptions.closeCallBack = () => {
      this.isShowFontSizePicker = false;
    };
    return cloneOptions;
  }

  cloneFlowSpeedOptions() {
    let cloneOptions: SliderOption = new SliderOption();
    cloneOptions.min = 1;
    cloneOptions.max = 10;
    cloneOptions.step = 1;
    cloneOptions.current = this.bullet.speed;
    cloneOptions.confirmCallBack = () => {
      this.bullet.speed = this.cloneFlowSpeedOption.current;
      this.isShowFlowSpeedPicker = false;
    };
    cloneOptions.closeCallBack = () => {
      this.isShowFlowSpeedPicker = false;
    };
    return cloneOptions;
  }

  cloneFontColorOptions() {
    let cloneOptions: ColorOption = new ColorOption();
    cloneOptions.color = this.bullet.textColor;
    cloneOptions.confirmCallBack = () => {
      this.bullet.textColor = this.cloneFontColorOption.color;
      this.isShowFontColorPicker = false;
    };
    cloneOptions.closeCallBack = () => {
      this.isShowFontColorPicker = false;
    };
    return cloneOptions;
  }

  cloneBgColorOptions() {
    let cloneOptions: ColorOption = new ColorOption();
    cloneOptions.color = this.bullet.bgColor;
    cloneOptions.confirmCallBack = () => {
      this.bullet.bgColor = this.cloneBgColorOption.color;
      this.isShowBgColorPicker = false;
    };
    cloneOptions.closeCallBack = () => {
      this.isShowBgColorPicker = false;
    };
    return cloneOptions;
  }

  cloneGlowSpeedOptions() {
    let cloneOptions: SliderOption = new SliderOption();
    cloneOptions.min = 1;
    cloneOptions.max = 10;
    cloneOptions.step = 1;
    cloneOptions.current = this.bullet.speed;
    cloneOptions.confirmCallBack = () => {
      this.bullet.speed = this.cloneGlowStickSpeedOption.current;
      this.isShowGlowStickerPicker = false;
    };
    cloneOptions.closeCallBack = () => {
      this.isShowGlowStickerPicker = false;
    };
    return cloneOptions;
  }

  startScrolling() {
    let overflow = this.contentWidth - (this.bullet.content.length * this.bullet.fontSize);
    if (overflow < 0) {
      this.isOverFlow = true;
      this.overflowLen = overflow - this.contentWidth;
      UtilLog.info(0xFF00, 'Bullet', `Bullet Display reset with offsetX: ${this.offsetX}, accurate: ${this.overflowLen}`);
    }
    this.isAnimating = true;
    this.animate();
  }

  startHideBack() {
    this.backTime = setTimeout(() => {
      this.isShowBack = false;
    }, 3000);
  }

  animate() {
    if (!this.isAnimating) {
      return;
    }
    this.time = setTimeout(() => {
      // 继续当前方向的滚动
      this.offsetX = this.offsetX - this.bullet.speed * 0.1;
      UtilLog.info(0xFF00, 'Bullet', `Bullet Display start with offsetX: ${this.offsetX}, speed: ${this.bullet.speed}`);

      // 检查是否需要重置位置
      if (this.offsetX <= this.overflowLen) {
        this.offsetX = this.contentWidth;
      }
      if (this.isAnimating) {
        this.animate();
      }
    }, this.duration);
  }
}