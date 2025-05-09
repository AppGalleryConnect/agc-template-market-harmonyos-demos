import {DrawContext} from "@ohos.arkui.node";
import {Catalog} from "../../../ets/Catalog"

export const getChapterIds: (name: string) => string[];

export const getContentByChapterId: (name: string, id: string) => string;

// 首次初始化引擎
export const initManager: (
    windowHeight: number,
    windowWidth: number,
    mRowSize: number,
    mPadding: number,
    mTop: number,
    mBottom: number,
    fontSize: number) => void;

export const setEpub: (name: string, path: string) => void;

export const loadEpubChapter: (name: string) => number;

export const modifyFont: (name: string, pageNum: number, fontSize: number) => number;

export const drawEpubPage: (name: string, pageNum: number, context: DrawContext) => void;

export const getEpubPageTotal: (name: string) => number;

export const getEpubCatalog: (name: string) => Array<Catalog>;

export const modifyWindowSize: (name: string, windowHeight: number, windowWidth: number, pageNum: number) => number;