// PreferencesManager.ets（数据存储）
import preferences from '@ohos.data.preferences';
import { TaskItem } from '../types/Types';

export class DataManager {
  private static DATA_MAP: Map<string, TaskItem[]> = new Map();
  private static ID: number = 1000;
  private static readonly KEY: string = 'todos';

  static init() {
  }

  static getId() {
    return '' + DataManager.ID++;
  }

  static saveTodo(todo: TaskItem) {
    let taskItems: TaskItem[] = DataManager.loadTodos();
    if (todo.taskID) {
      const newTaskItems: TaskItem[] = [];
      newTaskItems.push(todo);
      taskItems.forEach(t => {
        if (todo.taskID !== t.taskID) {
          newTaskItems.push(t);
        }
      });
      DataManager.saveTodos(newTaskItems);
    } else {
      todo.taskID = DataManager.getId();
      taskItems.push(todo);
      DataManager.saveTodos(taskItems);
    }
  }

  static queryById(id: string): TaskItem | undefined {
    let taskItems: TaskItem[] = DataManager.loadTodos();
    let target: TaskItem[] = taskItems.filter(t => {
      return t.taskID === id
    });
    if (target?.length > 0) {
      return target[0]
    }
    return undefined;
  }

  static querySubTasks(id: string): TaskItem[] {
    let taskItems: TaskItem[] = DataManager.loadTodos();
    return taskItems.filter(t => {
      return t.parentID === id
    });
  }

  static queryTasks(name: string, isFinished: boolean): TaskItem[] {
    let taskItems: TaskItem[] = DataManager.loadTodosByState(isFinished);
    return taskItems.filter(t => {
      if (t.title) {
        return t.title?.indexOf(name) >= 0;
      }
      return -1;
    });
  }

  static deleteById(id: string) {
    const newTaskItems: TaskItem[] = [];
    let taskItems: TaskItem[] = DataManager.loadTodos();
    taskItems.forEach(t => {
      if (id !== t.taskID) {
        newTaskItems.push(t);
      }
    });
    DataManager.saveTodos(newTaskItems);
  }

  static async saveTodos(todos: TaskItem[]) {
    DataManager.DATA_MAP.set(DataManager.KEY, todos)
  }

  static loadTodos(): TaskItem[] {
    let data = DataManager.DATA_MAP.get(DataManager.KEY) as TaskItem[];
    if (data) {
      return data;
    }
    return [];
  }

  static loadTodosByState(isFinished: boolean): TaskItem[] {
    let taskItems: TaskItem[] = DataManager.loadTodos();
    return taskItems.filter(t => {
      return t.isFinished === isFinished
    });
  }
}