import ConstantsUtil from '../utils/ConstantsUtil';
import { CommonSize, getTopEiditTextPosition } from '../utils/EditTextUtil';
import { EditTextVM } from './EditTextVM';
import { VideoEditDetailVM } from './VideoEditDetailVM';

interface PrompterRes {
  code: number;
  msg: string;
}

@ObservedV2
export class PrompterListVM {
  private static _instance: PrompterListVM
  @Trace editTexts: EditTextVM[] = []
  @Trace activeIndex: number = -1

  @Monitor('activeIndex')
  onNameChange(monitor: IMonitor) {
    if (this.editTexts.length > 0) {
      this.editTexts.forEach(item => {
        item.resetPrompterZIndex()
      });
    }
    if (this.activeIndex > -1) {
      this.editTexts[this.activeIndex].activePrompterZIndex()
    }
  }

  @Trace editStatus: boolean = false //是否处于编辑状态
  @Trace colorSelectStatus: boolean = false

  public static get instance() {
    if (!PrompterListVM._instance) {
      PrompterListVM._instance = new PrompterListVM();
    }
    return PrompterListVM._instance;
  }

  //添加编辑框
  addEditText(vm: VideoEditDetailVM, tempObj?: EditTextVM) {
    if (this.editTexts.length > 0) { //暂时仅支持添加一个提词器
      return ({ code: 1, msg: '仅支持添加一个示例提词器' } as PrompterRes)
    }
    let editTextVM: EditTextVM | undefined = new EditTextVM()
    let position =
      getTopEiditTextPosition(px2vp(ConstantsUtil.BASIC_VIDEO_WIDTH), px2vp(ConstantsUtil.BASIC_VIDEO_HEIGHT),
        editTextVM.width, editTextVM.height)
    editTextVM.setX(position?.x as number)
    editTextVM.setY(position?.y as number)
    if (tempObj) {
      editTextVM.setProps(tempObj)
    }
    editTextVM.setId(this.editTexts.length)
    if (this.editTexts.length > 0) {
      let vm: VideoEditDetailVM | undefined = VideoEditDetailVM.instance
      //获取上个元素占位结束点，新元素放在它后面
      let lastEndX =
        this.editTexts[this.editTexts.length - 1].prompterX + this.editTexts[this.editTexts.length - 1].prompterWidth +
        CommonSize.PROMPTER_TEXT_DIS
      if ((vm.childListRightWidth - lastEndX) < CommonSize.PROMPTER_MIN_WIDTH) { //如果剩余宽度不够使用
        vm = undefined;
        editTextVM = undefined
        return ({ code: 1, msg: '超出视频时长' } as PrompterRes)
      }
      if ((vm.childListRightWidth - lastEndX) < CommonSize.PROMPTER_DEFAULT_WIDTH) { //如果剩余宽度小于元素所需默认宽度
        editTextVM.setPrompterWidth(vm.childListRightWidth - lastEndX) //以剩余宽度展示
      }
      editTextVM.setPrompterX(lastEndX) //设置文本框x坐标位置
      editTextVM.setPrompterStartTIme(lastEndX / CommonSize.ONE_SECOND_WIDTH) //设置文本框开始出现时间
    }

    this.editTexts.push(editTextVM)
    this.activeIndex = this.editTexts.length - 1 //选中当前对象为活动对象
    return ({ code: 0, msg: '添加成功' } as PrompterRes)
  }

  //删除元素
  delEditText(index: number) {
    this.editTexts.splice(index, 1)
    this.activeIndex = -1
    this.editStatus = false
  }

  clearAll() {
    this.editTexts = []
    this.activeIndex = -1
    this.editStatus = false
  }
}