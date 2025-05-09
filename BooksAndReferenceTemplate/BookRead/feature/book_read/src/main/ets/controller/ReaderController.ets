import { BookInfo, LazyDataVM } from 'common';
import { Catalog, EpubParser } from 'parse';
import { NativeTextNode } from '../node/TextNode';
import { TextNodeController } from '../node/TextNodeController';

// 阅读器控制，章节粒度
export class ReaderController {
  private book: BookInfo;
  private curPageNum: number = 1;
  private totalNum: number = 1;
  private ncVm: LazyDataVM<TextNodeController> = new LazyDataVM();

  constructor(info: BookInfo) {
    this.book = info;
    EpubParser.setEpub(info.name, info.localPath);
  }

  // 获取书籍事例
  public getBook(): BookInfo {
    return this.book;
  }

  // 加载目录
  public getCatalog(): LazyDataVM<Catalog> {
    const catalog: Array<Catalog> = EpubParser.getEpubCatalog(this.book.name);
    const cvm: LazyDataVM<Catalog> = new LazyDataVM(catalog);
    return cvm;
  }

  // 根据章节加载内容非常耗时的操作
  public getContent(c: Catalog): string {
    return EpubParser.getContentByChapterId(this.book.name, c.id);
  }

  // 加载章节
  public loadAllChapter(): number {
    EpubParser.loadEpubChapter(this.book.name);
    // 构造 controller 节点
    this.totalNum = EpubParser.getEpubPageTotal(this.book.name);
    this.loadTextPage();
    return this.totalNum;
  }

  // 获取挂载节点
  public getNodeController(): LazyDataVM<TextNodeController> {
    return this.ncVm;
  }

  // 加载页面
  public loadTextNode(vm: TextNodeController, pageNum: number) {
    const node = new NativeTextNode(pageNum, this.book.name);
    vm.addNode(node);
    this.curPageNum = pageNum;
  }

  // 首次挂载节点
  private loadTextPage() {
    for (let i = 1; i <= this.totalNum; i++) {
      const nc: TextNodeController = new TextNodeController();
      this.ncVm.pushData(nc);
    }
  }

  // 调整字体
  public modifyFont(pageNum: number, fontSize: number) {
    // 重绘制所有章节，并返回当前页在新字体下的新页码
    this.curPageNum = EpubParser.modifyFont(this.book.name, pageNum, fontSize);
    const vm = this.ncVm.getData(pageNum - 1);
    // 重绘当前 node
    vm.clearNodes();
    const node = new NativeTextNode(this.curPageNum, this.book.name);
    vm.addNode(node);

    this.totalNum = EpubParser.getEpubPageTotal(this.book.name);
  }

  public modifyWindowSize(windowHeight: number, windowWidth: number, pageNum: number) {
    // 重绘制所有章节，并返回当前页在新字体下的新页码
    const curPageNum = EpubParser.modifyWindow(this.book.name, windowHeight, windowWidth, pageNum);
    const vm = this.ncVm.getData(pageNum - 1);
    // 重绘当前 node
    vm.clearNodes();
    const node = new NativeTextNode(curPageNum, this.book.name);
    vm.addNode(node);

    this.totalNum = EpubParser.getEpubPageTotal(this.book.name);
  }

  public getTotalNum(): number {
    return this.totalNum;
  }

  public getCurPageNum(): number {
    return this.curPageNum;
  }
}