import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { CommonConstants } from '../constants/CommonConstants';
import { recipesData } from '../types/Types';
import { Logger } from './Logger';

export class RdbManager {
  private rdbStore: relationalStore.RdbStore | null = null;
  context: common.UIAbilityContext | null = null;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  async initDatabase(context: Context) {
    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: 'database.recipesdbV3',
      securityLevel: relationalStore.SecurityLevel.S1
    }
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      await this.rdbStore.executeSql(CommonConstants.RECIPES_TABLE.sqlCreate);
    } catch (error) {
      Logger.error(`Failed to get RdbStore. Code:${error.code}, message:${error.message}`);
    }
  }

  async insertData(data: recipesData, collectStatus: number) {
    const value: relationalStore.ValuesBucket = this.generateBucket(data, collectStatus);
    let rowId: number = -1;
    if (this.rdbStore) {
      try {
        const rowId = await this.rdbStore?.insert(CommonConstants.RECIPES_TABLE.tableName, value);
        Logger.info(`Succeeded in inserting data. rowId:${rowId}`);
      } catch (error) {
        Logger.error(`Failed to insert data. Code:${error.code}, message:${error.message}`);
      }
    }
    return rowId;
  }

  async deleteData(data: recipesData) {
    let rows: number = 0;
    if (this.rdbStore) {
      try {
        let predicates = new relationalStore.RdbPredicates(CommonConstants.RECIPES_TABLE.tableName);
        predicates.equalTo('id', data.id);
        rows = await this.rdbStore.delete(predicates);
      } catch (error) {
        Logger.error(`Failed to insert data. Code:${error.code}, message:${error.message}`);
      }
    }
    return rows;
  }

  async updateData(data: recipesData, collectStatus: number) {
    const valueBucket: relationalStore.ValuesBucket = this.generateBucket(data, collectStatus);
    let rows = 0;
    if (this.rdbStore) {
      try {
        let predicates = new relationalStore.RdbPredicates(CommonConstants.RECIPES_TABLE.tableName);
        predicates.equalTo('id', data.id);
        rows = await this.rdbStore.update(valueBucket, predicates);
        Logger.info(`Succeeded in updating data. row count: ${rows}`);
      } catch (error) {
        Logger.error(`Failed to update data. Code:${error.code}, message:${error.message}`);
      }
    }
    return rows;
  }

  async query(searchValue: string, isAll: boolean = true) {
    let result: recipesData[] = [];
    if (this.rdbStore) {
      try {
        let predicates = new relationalStore.RdbPredicates(CommonConstants.RECIPES_TABLE.tableName);
        if (!isAll) {
          predicates.equalTo('title', searchValue);
        }
        const resultSet: relationalStore.ResultSet =
          await this.rdbStore.query(predicates, CommonConstants.RECIPES_TABLE.columns);
        result = this.formatData(resultSet);
        Logger.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);
        if (result.length > 0) {
          resultSet.close();
        }
      } catch (error) {
        Logger.error(`Failed to query data. Code:${error.code}, message:${error.message}`);
      }
    }
    return result;
  }

  generateBucket(recipes: recipesData, collectStatus: number = 0): relationalStore.ValuesBucket {
    let obj: relationalStore.ValuesBucket = {};
    obj.id = recipes.id
    obj.title = recipes.title;
    obj.category = recipes.category;
    obj.cookingTime = recipes.cookingTime;
    obj.difficulty = recipes.difficulty!;
    obj.authorId = recipes.authorId;
    obj.author = recipes.author;
    obj.authorAvatar = recipes.authorAvatar;
    obj.thumbnail = recipes.thumbnail;
    obj.views = recipes.views;
    obj.likes = recipes.likes;
    obj.isCollected = collectStatus;
    obj.video = recipes.video;
    obj.heatness = recipes.heatness!;
    obj.isVip = recipes.isVip!;
    return obj;
  }


  formatData(resultSet: relationalStore.ResultSet) {
    let list: recipesData[] = [];
    let count: number = resultSet.rowCount;
    if (count !== 0 && typeof count !== 'string') {
      try {
        resultSet.goToFirstRow();
        for (let i = 0; i < count; i++) {
          let tmp: recipesData = {
            id: 0,
            title: '',
            description: '',
            category: '',
            cookingTime: 0,
            difficulty: '',
            authorId: 0,
            author: '',
            authorAvatar: '',
            thumbnail: '',
            views: 0,
            likes: 0,
            isCollected: 0,
            video: '',
            heatness: 0,
            isVip: 0
          };
          tmp.id = resultSet.getLong(resultSet.getColumnIndex('id'));
          tmp.title = resultSet.getString(resultSet.getColumnIndex('title'));
          tmp.description = resultSet.getString(resultSet.getColumnIndex('description'));
          tmp.category = resultSet.getString(resultSet.getColumnIndex('category'));
          tmp.cookingTime = resultSet.getLong(resultSet.getColumnIndex('cookingTime'));
          tmp.authorId = resultSet.getLong(resultSet.getColumnIndex('authorId'));
          tmp.difficulty = resultSet.getString(resultSet.getColumnIndex('difficulty'));
          tmp.author = resultSet.getString(resultSet.getColumnIndex('author'));
          tmp.authorAvatar = resultSet.getString(resultSet.getColumnIndex('authorAvatar'));
          tmp.thumbnail = resultSet.getString(resultSet.getColumnIndex('thumbnail'));
          tmp.views = resultSet.getLong(resultSet.getColumnIndex('views'));
          tmp.likes = resultSet.getLong(resultSet.getColumnIndex('likes'));
          tmp.isCollected = resultSet.getLong(resultSet.getColumnIndex('isCollected'));
          tmp.video = resultSet.getString(resultSet.getColumnIndex('video'));
          tmp.heatness = resultSet.getLong(resultSet.getColumnIndex('heatness'));
          tmp.isVip = resultSet.getLong(resultSet.getColumnIndex('isVip'));
          list[i] = tmp;
          resultSet.goToNextRow();
        }
      } catch (error) {
        Logger.error(`Failed to query data. Code:${error.code}, message:${error.message}`);
      }
    }
    return list;
  }
}