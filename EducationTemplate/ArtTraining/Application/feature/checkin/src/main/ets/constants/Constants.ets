import { TaskIntroTabItem } from '../types/Index';
import { TaskIntroTabMap } from './Enums';


export const TASK_INTRO_TAB_LIST: TaskIntroTabItem[] = [
  {
    label: '介绍',
    type: TaskIntroTabMap.INTRO,
  },
  {
    label: '目录',
    type: TaskIntroTabMap.TOC,
  },
];