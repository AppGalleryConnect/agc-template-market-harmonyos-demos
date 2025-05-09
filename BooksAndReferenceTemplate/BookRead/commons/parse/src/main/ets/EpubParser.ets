//
// Created by tyx on 2025/1/16.
//
import libparse from 'libparse.so'
import { Catalog } from './Catalog';
import { PageRect } from './PgaeRect';

export class EpubParser {
  public static setEpub(name: string, path: string) {
    libparse.setEpub(name, path);
  }

  public static getChapterIds(name: string): string[] {
    return libparse.getChapterIds(name);
  }

  public static getContentByChapterId(name: string, id: string): string {
    return libparse.getContentByChapterId(name, id);
  }

  public static initManager(ww: number, wh: number, rect: PageRect, fontSize: number) {
    libparse.initManager(ww, wh, rect.mRowSize, rect.mPadding, rect.mTop, rect.mBottom, fontSize);
  }

  public static loadEpubChapter(name: string): number {
    return libparse.loadEpubChapter(name);
  }

  public static modifyFont(name: string, pageNum: number, fontSize: number): number {
    return libparse.modifyFont(name, pageNum, fontSize);
  }

  public static modifyWindow(name: string, windowHeight: number, windowWidth: number, pageNum: number): number {
    return libparse.modifyWindowSize(name, windowHeight, windowWidth, pageNum);
  }

  public static getEpubPageTotal(name: string): number {
    return libparse.getEpubPageTotal(name);
  }

  public static drawEpubPage(name: string, pageNum: number, context: DrawContext): void {
    libparse.drawEpubPage(name, pageNum, context);
  }

  public static getEpubCatalog(name: string): Array<Catalog> {
    return libparse.getEpubCatalog(name);
  }
}